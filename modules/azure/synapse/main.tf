# -----------------------------------------------------------------------------
# Azure Synapse Analytics Module
# Workspace, dedicated SQL pool, Spark pool, firewall, managed identity
# -----------------------------------------------------------------------------

locals {
  name_prefix    = "${var.project_name}-${var.environment}"
  workspace_name = "${replace(local.name_prefix, "-", "")}synapse"
}

# -----------------------------------------------------------------------------
# Random Password for SQL Admin
# -----------------------------------------------------------------------------

resource "random_password" "sql_admin" {
  length           = 32
  special          = true
  override_special = "!#$%&*()-_=+[]{}<>:?"
}

# -----------------------------------------------------------------------------
# Synapse Workspace
# -----------------------------------------------------------------------------

resource "azurerm_synapse_workspace" "main" {
  name                                 = local.workspace_name
  resource_group_name                  = var.resource_group_name
  location                             = var.location
  storage_data_lake_gen2_filesystem_id = var.filesystem_id
  sql_administrator_login              = var.sql_admin_user
  sql_administrator_login_password     = random_password.sql_admin.result

  identity {
    type = "SystemAssigned"
  }

  managed_virtual_network_enabled      = true
  public_network_access_enabled        = false
  data_exfiltration_protection_enabled = var.environment == "prd"

  tags = merge(var.tags, {
    Name = local.workspace_name
  })
}

# -----------------------------------------------------------------------------
# Firewall Rules
# -----------------------------------------------------------------------------

resource "azurerm_synapse_firewall_rule" "allow_azure" {
  name                 = "AllowAllWindowsAzureIps"
  synapse_workspace_id = azurerm_synapse_workspace.main.id
  start_ip_address     = "0.0.0.0"
  end_ip_address       = "0.0.0.0"
}

# -----------------------------------------------------------------------------
# Dedicated SQL Pool
# -----------------------------------------------------------------------------

resource "azurerm_synapse_sql_pool" "main" {
  name                 = replace("${local.name_prefix}_sqlpool", "-", "_")
  synapse_workspace_id = azurerm_synapse_workspace.main.id
  sku_name             = var.sql_pool_sku
  create_mode          = "Default"
  storage_account_type = var.environment == "prd" ? "GRS" : "LRS"
  data_encrypted       = true

  geo_backup_policy_enabled = var.environment == "prd"

  tags = merge(var.tags, {
    Name = "${local.name_prefix}-sqlpool"
  })
}

# -----------------------------------------------------------------------------
# Spark Pool
# -----------------------------------------------------------------------------

resource "azurerm_synapse_spark_pool" "main" {
  name                 = replace("${local.name_prefix}spark", "-", "")
  synapse_workspace_id = azurerm_synapse_workspace.main.id
  node_size_family     = "MemoryOptimized"
  node_size            = var.spark_node_count <= 5 ? "Small" : "Medium"
  spark_version        = "3.4"
  cache_size           = 50

  auto_scale {
    min_node_count = 3
    max_node_count = var.spark_node_count
  }

  auto_pause {
    delay_in_minutes = 15
  }

  session_level_packages_enabled = true

  tags = merge(var.tags, {
    Name = "${local.name_prefix}-spark"
  })
}

# -----------------------------------------------------------------------------
# Role Assignment - Storage Blob Data Contributor
# -----------------------------------------------------------------------------

resource "azurerm_role_assignment" "synapse_storage" {
  scope                = var.storage_account_id
  role_definition_name = "Storage Blob Data Contributor"
  principal_id         = azurerm_synapse_workspace.main.identity[0].principal_id
}

# -----------------------------------------------------------------------------
# Diagnostic Settings
# -----------------------------------------------------------------------------

resource "azurerm_monitor_diagnostic_setting" "synapse" {
  name                       = "${local.name_prefix}-synapse-diag"
  target_resource_id         = azurerm_synapse_workspace.main.id
  log_analytics_workspace_id = azurerm_log_analytics_workspace.synapse.id

  enabled_log {
    category = "SynapseRbacOperations"
  }

  enabled_log {
    category = "GatewayApiRequests"
  }

  metric {
    category = "AllMetrics"
    enabled  = true
  }
}

resource "azurerm_log_analytics_workspace" "synapse" {
  name                = "${local.name_prefix}-synapse-law"
  location            = var.location
  resource_group_name = var.resource_group_name
  sku                 = "PerGB2018"
  retention_in_days   = var.environment == "prd" ? 90 : 30

  tags = var.tags
}
