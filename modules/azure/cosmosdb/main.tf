# -----------------------------------------------------------------------------
# Azure CosmosDB Module
# SQL API account, database, containers, geo-replication, private endpoint
# -----------------------------------------------------------------------------

locals {
  name_prefix = "${var.project_name}-${var.environment}"

  geo_locations = var.geo_replication ? [
    {
      location          = var.location
      failover_priority = 0
      zone_redundant    = var.environment == "prd"
    },
    {
      location          = var.secondary_location
      failover_priority = 1
      zone_redundant    = false
    }
  ] : [
    {
      location          = var.location
      failover_priority = 0
      zone_redundant    = false
    }
  ]
}

# -----------------------------------------------------------------------------
# CosmosDB Account
# -----------------------------------------------------------------------------

resource "azurerm_cosmosdb_account" "main" {
  name                = "${local.name_prefix}-cosmos"
  location            = var.location
  resource_group_name = var.resource_group_name
  offer_type          = "Standard"
  kind                = "GlobalDocumentDB"

  consistency_policy {
    consistency_level       = "Session"
    max_interval_in_seconds = 5
    max_staleness_prefix    = 100
  }

  dynamic "geo_location" {
    for_each = local.geo_locations
    content {
      location          = geo_location.value.location
      failover_priority = geo_location.value.failover_priority
      zone_redundant    = geo_location.value.zone_redundant
    }
  }

  is_virtual_network_filter_enabled = true
  public_network_access_enabled     = false
  local_authentication_disabled     = true
  access_key_metadata_writes_enabled = false

  virtual_network_rule {
    id = var.subnet_id
  }

  backup {
    type                = var.environment == "prd" ? "Continuous" : "Periodic"
    interval_in_minutes = var.environment == "prd" ? null : 240
    retention_in_hours  = var.environment == "prd" ? null : 8
    storage_redundancy  = var.environment == "prd" ? null : "Local"
  }

  capabilities {
    name = "EnableServerless"
  }

  tags = merge(var.tags, {
    Name = "${local.name_prefix}-cosmos"
  })
}

# -----------------------------------------------------------------------------
# CosmosDB SQL Database
# -----------------------------------------------------------------------------

resource "azurerm_cosmosdb_sql_database" "main" {
  name                = "${local.name_prefix}-db"
  resource_group_name = var.resource_group_name
  account_name        = azurerm_cosmosdb_account.main.name

  autoscale_settings {
    max_throughput = var.max_throughput
  }
}

# -----------------------------------------------------------------------------
# Containers
# -----------------------------------------------------------------------------

resource "azurerm_cosmosdb_sql_container" "events" {
  name                = "events"
  resource_group_name = var.resource_group_name
  account_name        = azurerm_cosmosdb_account.main.name
  database_name       = azurerm_cosmosdb_sql_database.main.name
  partition_key_paths = ["/eventType"]

  indexing_policy {
    indexing_mode = "consistent"

    included_path {
      path = "/*"
    }

    excluded_path {
      path = "/\"_etag\"/?"
    }

    composite_index {
      index {
        path  = "/eventType"
        order = "ascending"
      }
      index {
        path  = "/timestamp"
        order = "descending"
      }
    }
  }

  default_ttl = 2592000 # 30 days

  autoscale_settings {
    max_throughput = var.max_throughput
  }
}

resource "azurerm_cosmosdb_sql_container" "entities" {
  name                = "entities"
  resource_group_name = var.resource_group_name
  account_name        = azurerm_cosmosdb_account.main.name
  database_name       = azurerm_cosmosdb_sql_database.main.name
  partition_key_paths = ["/tenantId"]

  indexing_policy {
    indexing_mode = "consistent"

    included_path {
      path = "/*"
    }

    excluded_path {
      path = "/\"_etag\"/?"
    }
  }

  unique_key {
    paths = ["/entityId"]
  }

  autoscale_settings {
    max_throughput = var.max_throughput
  }
}

resource "azurerm_cosmosdb_sql_container" "analytics" {
  name                = "analytics"
  resource_group_name = var.resource_group_name
  account_name        = azurerm_cosmosdb_account.main.name
  database_name       = azurerm_cosmosdb_sql_database.main.name
  partition_key_paths = ["/tenantId"]

  autoscale_settings {
    max_throughput = var.max_throughput
  }
}

# -----------------------------------------------------------------------------
# Diagnostic Settings
# -----------------------------------------------------------------------------

resource "azurerm_monitor_diagnostic_setting" "cosmosdb" {
  name                       = "${local.name_prefix}-cosmos-diag"
  target_resource_id         = azurerm_cosmosdb_account.main.id
  log_analytics_workspace_id = azurerm_log_analytics_workspace.cosmosdb.id

  enabled_log {
    category = "DataPlaneRequests"
  }

  enabled_log {
    category = "QueryRuntimeStatistics"
  }

  metric {
    category = "Requests"
    enabled  = true
  }
}

resource "azurerm_log_analytics_workspace" "cosmosdb" {
  name                = "${local.name_prefix}-cosmos-law"
  location            = var.location
  resource_group_name = var.resource_group_name
  sku                 = "PerGB2018"
  retention_in_days   = var.environment == "prd" ? 90 : 30

  tags = var.tags
}
