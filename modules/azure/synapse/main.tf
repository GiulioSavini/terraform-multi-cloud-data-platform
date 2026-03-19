locals {
  name_prefix = "${var.project}-${var.environment}"
}

resource "azurerm_synapse_workspace" "main" {
  name                                 = "${replace(local.name_prefix, "-", "")}synapse"
  resource_group_name                  = var.resource_group_name
  location                             = var.location
  storage_data_lake_gen2_filesystem_id = var.adls_filesystem_id
  sql_administrator_login              = var.sql_admin_user
  sql_administrator_login_password     = var.sql_admin_password

  identity { type = "SystemAssigned" }

  managed_virtual_network_enabled = true
  public_network_access_enabled   = false

  tags = var.tags
}

resource "azurerm_synapse_firewall_rule" "allow_azure" {
  name                 = "AllowAllWindowsAzureIps"
  synapse_workspace_id = azurerm_synapse_workspace.main.id
  start_ip_address     = "0.0.0.0"
  end_ip_address       = "0.0.0.0"
}

resource "azurerm_synapse_sql_pool" "main" {
  name                 = replace("${local.name_prefix}_sqlpool", "-", "_")
  synapse_workspace_id = azurerm_synapse_workspace.main.id
  sku_name             = var.sql_pool_sku
  create_mode          = "Default"
  storage_account_type = var.environment == "prd" ? "GRS" : "LRS"
  tags                 = var.tags
}

resource "azurerm_synapse_spark_pool" "main" {
  name                 = replace("${local.name_prefix}spark", "-", "")
  synapse_workspace_id = azurerm_synapse_workspace.main.id
  node_size_family     = "MemoryOptimized"
  node_size            = var.spark_node_size
  spark_version        = "3.4"

  auto_scale {
    min_node_count = var.spark_min_nodes
    max_node_count = var.spark_max_nodes
  }

  auto_pause {
    delay_in_minutes = 15
  }

  tags = var.tags
}
