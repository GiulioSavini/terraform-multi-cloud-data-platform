locals {
  name_prefix = "${var.project}-${var.environment}"
}

resource "azurerm_eventhub_namespace" "main" {
  name                     = "${local.name_prefix}-ehns"
  location                 = var.location
  resource_group_name      = var.resource_group_name
  sku                      = var.sku
  capacity                 = var.capacity
  auto_inflate_enabled     = var.environment == "prd"
  maximum_throughput_units = var.environment == "prd" ? 20 : null

  network_rulesets {
    default_action                 = "Deny"
    trusted_service_access_enabled = true
  }

  tags = var.tags
}

resource "azurerm_eventhub" "events" {
  name                = "events"
  namespace_name      = azurerm_eventhub_namespace.main.name
  resource_group_name = var.resource_group_name
  partition_count     = var.partition_count
  message_retention   = var.message_retention_days
}

resource "azurerm_eventhub" "metrics" {
  name                = "metrics"
  namespace_name      = azurerm_eventhub_namespace.main.name
  resource_group_name = var.resource_group_name
  partition_count     = var.partition_count
  message_retention   = var.message_retention_days
}

resource "azurerm_eventhub_consumer_group" "analytics" {
  name                = "analytics"
  namespace_name      = azurerm_eventhub_namespace.main.name
  eventhub_name       = azurerm_eventhub.events.name
  resource_group_name = var.resource_group_name
}

resource "azurerm_eventhub_consumer_group" "streaming" {
  name                = "streaming"
  namespace_name      = azurerm_eventhub_namespace.main.name
  eventhub_name       = azurerm_eventhub.events.name
  resource_group_name = var.resource_group_name
}
