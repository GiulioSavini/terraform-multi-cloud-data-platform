# -----------------------------------------------------------------------------
# Azure Data Lake Module
# Storage account with HNS, containers, lifecycle, RBAC, private endpoint
# -----------------------------------------------------------------------------

locals {
  name_prefix  = "${var.project_name}-${var.environment}"
  storage_name = replace("${var.project_name}${var.environment}adls", "-", "")
}

# -----------------------------------------------------------------------------
# Storage Account (ADLS Gen2)
# -----------------------------------------------------------------------------

resource "azurerm_storage_account" "adls" {
  name                     = substr(local.storage_name, 0, 24)
  resource_group_name      = var.resource_group_name
  location                 = var.location
  account_tier             = "Standard"
  account_replication_type = var.environment == "prd" ? "GRS" : "LRS"
  account_kind             = "StorageV2"
  is_hns_enabled           = true
  min_tls_version          = "TLS1_2"
  allow_nested_items_to_be_public = false

  blob_properties {
    delete_retention_policy {
      days = var.environment == "prd" ? 90 : 30
    }
    container_delete_retention_policy {
      days = var.environment == "prd" ? 90 : 30
    }
    versioning_enabled       = true
    change_feed_enabled      = true
    last_access_time_enabled = true
  }

  network_rules {
    default_action             = "Deny"
    bypass                     = ["AzureServices"]
    virtual_network_subnet_ids = [var.subnet_id]
  }

  identity {
    type = "SystemAssigned"
  }

  tags = merge(var.tags, {
    Name = local.storage_name
  })
}

# -----------------------------------------------------------------------------
# Data Lake Gen2 Filesystems (Containers)
# -----------------------------------------------------------------------------

resource "azurerm_storage_data_lake_gen2_filesystem" "raw" {
  name               = "raw"
  storage_account_id = azurerm_storage_account.adls.id

  properties = {
    zone        = "raw"
    description = "Raw ingestion zone"
  }
}

resource "azurerm_storage_data_lake_gen2_filesystem" "curated" {
  name               = "curated"
  storage_account_id = azurerm_storage_account.adls.id

  properties = {
    zone        = "curated"
    description = "Curated/cleansed zone"
  }
}

resource "azurerm_storage_data_lake_gen2_filesystem" "analytics" {
  name               = "analytics"
  storage_account_id = azurerm_storage_account.adls.id

  properties = {
    zone        = "analytics"
    description = "Analytics/consumption zone"
  }
}

# -----------------------------------------------------------------------------
# Lifecycle Management
# -----------------------------------------------------------------------------

resource "azurerm_storage_management_policy" "lifecycle" {
  storage_account_id = azurerm_storage_account.adls.id

  rule {
    name    = "raw-lifecycle"
    enabled = true

    filters {
      prefix_match = ["raw/"]
      blob_types   = ["blockBlob"]
    }

    actions {
      base_blob {
        tier_to_cool_after_days_since_modification_greater_than    = var.cool_tier_days
        tier_to_archive_after_days_since_modification_greater_than = var.archive_tier_days
        delete_after_days_since_modification_greater_than          = 365
      }
      snapshot {
        delete_after_days_since_creation_greater_than = 90
      }
      version {
        delete_after_days_since_creation = 90
      }
    }
  }

  rule {
    name    = "curated-lifecycle"
    enabled = true

    filters {
      prefix_match = ["curated/"]
      blob_types   = ["blockBlob"]
    }

    actions {
      base_blob {
        tier_to_cool_after_days_since_modification_greater_than    = var.cool_tier_days * 2
        tier_to_archive_after_days_since_modification_greater_than = var.archive_tier_days * 2
      }
    }
  }
}

# -----------------------------------------------------------------------------
# Private Endpoint
# -----------------------------------------------------------------------------

resource "azurerm_private_endpoint" "adls_blob" {
  name                = "${local.name_prefix}-pe-adls-blob"
  location            = var.location
  resource_group_name = var.resource_group_name
  subnet_id           = var.subnet_id

  private_service_connection {
    name                           = "${local.name_prefix}-psc-adls-blob"
    private_connection_resource_id = azurerm_storage_account.adls.id
    subresource_names              = ["blob"]
    is_manual_connection           = false
  }

  tags = var.tags
}

resource "azurerm_private_endpoint" "adls_dfs" {
  name                = "${local.name_prefix}-pe-adls-dfs"
  location            = var.location
  resource_group_name = var.resource_group_name
  subnet_id           = var.subnet_id

  private_service_connection {
    name                           = "${local.name_prefix}-psc-adls-dfs"
    private_connection_resource_id = azurerm_storage_account.adls.id
    subresource_names              = ["dfs"]
    is_manual_connection           = false
  }

  tags = var.tags
}

# -----------------------------------------------------------------------------
# Diagnostic Settings
# -----------------------------------------------------------------------------

resource "azurerm_monitor_diagnostic_setting" "adls" {
  name                       = "${local.name_prefix}-adls-diag"
  target_resource_id         = "${azurerm_storage_account.adls.id}/blobServices/default"
  log_analytics_workspace_id = azurerm_log_analytics_workspace.adls.id

  enabled_log {
    category = "StorageRead"
  }

  enabled_log {
    category = "StorageWrite"
  }

  enabled_log {
    category = "StorageDelete"
  }

  metric {
    category = "Transaction"
    enabled  = true
  }
}

resource "azurerm_log_analytics_workspace" "adls" {
  name                = "${local.name_prefix}-adls-law"
  location            = var.location
  resource_group_name = var.resource_group_name
  sku                 = "PerGB2018"
  retention_in_days   = var.environment == "prd" ? 90 : 30

  tags = var.tags
}
