# -----------------------------------------------------------------------------
# Azure Event Hubs (Kafka Protocol) Module
# Namespace, event hubs, consumer groups, capture to ADLS
# -----------------------------------------------------------------------------

locals {
  name_prefix = "${var.project_name}-${var.environment}"
}

# -----------------------------------------------------------------------------
# Event Hubs Namespace (Kafka-enabled)
# -----------------------------------------------------------------------------

resource "azurerm_eventhub_namespace" "main" {
  name                     = "${local.name_prefix}-ehns"
  location                 = var.location
  resource_group_name      = var.resource_group_name
  sku                      = "Standard"
  capacity                 = var.capacity
  auto_inflate_enabled     = var.environment == "prd"
  maximum_throughput_units = var.environment == "prd" ? 20 : null

  network_rulesets {
    default_action                 = "Deny"
    trusted_service_access_enabled = true
    public_network_access_enabled  = false
  }

  local_authentication_enabled  = false
  public_network_access_enabled = false
  minimum_tls_version           = "1.2"

  tags = merge(var.tags, {
    Name = "${local.name_prefix}-ehns"
  })
}

# -----------------------------------------------------------------------------
# Event Hubs
# -----------------------------------------------------------------------------

resource "azurerm_eventhub" "events" {
  name                = "events"
  namespace_name      = azurerm_eventhub_namespace.main.name
  resource_group_name = var.resource_group_name
  partition_count     = var.partition_count
  message_retention   = var.message_retention_days

  capture_description {
    enabled             = true
    encoding            = "Avro"
    interval_in_seconds = 300
    size_limit_in_bytes = 314572800

    destination {
      name                = "EventHubArchive.AzureBlockBlob"
      archive_name_format = "{Namespace}/{EventHub}/{PartitionId}/{Year}/{Month}/{Day}/{Hour}/{Minute}/{Second}"
      blob_container_name = "eventhub-capture"
      storage_account_id  = var.storage_account_id
    }
  }
}

resource "azurerm_eventhub" "metrics" {
  name                = "metrics"
  namespace_name      = azurerm_eventhub_namespace.main.name
  resource_group_name = var.resource_group_name
  partition_count     = var.partition_count
  message_retention   = var.message_retention_days
}

resource "azurerm_eventhub" "commands" {
  name                = "commands"
  namespace_name      = azurerm_eventhub_namespace.main.name
  resource_group_name = var.resource_group_name
  partition_count     = var.partition_count
  message_retention   = var.message_retention_days
}

# -----------------------------------------------------------------------------
# Consumer Groups
# -----------------------------------------------------------------------------

resource "azurerm_eventhub_consumer_group" "analytics" {
  name                = "analytics"
  namespace_name      = azurerm_eventhub_namespace.main.name
  eventhub_name       = azurerm_eventhub.events.name
  resource_group_name = var.resource_group_name
  user_metadata       = "Consumer group for analytics pipeline"
}

resource "azurerm_eventhub_consumer_group" "streaming" {
  name                = "streaming"
  namespace_name      = azurerm_eventhub_namespace.main.name
  eventhub_name       = azurerm_eventhub.events.name
  resource_group_name = var.resource_group_name
  user_metadata       = "Consumer group for real-time streaming"
}

resource "azurerm_eventhub_consumer_group" "replication" {
  name                = "cross-cloud-replication"
  namespace_name      = azurerm_eventhub_namespace.main.name
  eventhub_name       = azurerm_eventhub.events.name
  resource_group_name = var.resource_group_name
  user_metadata       = "Consumer group for cross-cloud Kafka replication"
}

# -----------------------------------------------------------------------------
# Authorization Rules
# -----------------------------------------------------------------------------

resource "azurerm_eventhub_namespace_authorization_rule" "send" {
  name                = "send-rule"
  namespace_name      = azurerm_eventhub_namespace.main.name
  resource_group_name = var.resource_group_name
  listen              = false
  send                = true
  manage              = false
}

resource "azurerm_eventhub_namespace_authorization_rule" "listen" {
  name                = "listen-rule"
  namespace_name      = azurerm_eventhub_namespace.main.name
  resource_group_name = var.resource_group_name
  listen              = true
  send                = false
  manage              = false
}

# -----------------------------------------------------------------------------
# Diagnostic Settings
# -----------------------------------------------------------------------------

resource "azurerm_monitor_diagnostic_setting" "eventhubs" {
  name                       = "${local.name_prefix}-eh-diag"
  target_resource_id         = azurerm_eventhub_namespace.main.id
  log_analytics_workspace_id = azurerm_log_analytics_workspace.eventhubs.id

  enabled_log {
    category = "ArchiveLogs"
  }

  enabled_log {
    category = "OperationalLogs"
  }

  enabled_log {
    category = "KafkaCoordinatorLogs"
  }

  enabled_log {
    category = "KafkaUserErrorLogs"
  }

  metric {
    category = "AllMetrics"
    enabled  = true
  }
}

resource "azurerm_log_analytics_workspace" "eventhubs" {
  name                = "${local.name_prefix}-eh-law"
  location            = var.location
  resource_group_name = var.resource_group_name
  sku                 = "PerGB2018"
  retention_in_days   = var.environment == "prd" ? 90 : 30

  tags = var.tags
}
