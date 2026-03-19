# -----------------------------------------------------------------------------
# Azure Data Factory Module
# ADF instance, linked services, pipeline, managed identity, diagnostics
# -----------------------------------------------------------------------------

locals {
  name_prefix = "${var.project_name}-${var.environment}"
}

# -----------------------------------------------------------------------------
# Data Factory
# -----------------------------------------------------------------------------

resource "azurerm_data_factory" "main" {
  name                = "${local.name_prefix}-adf"
  location            = var.location
  resource_group_name = var.resource_group_name

  identity {
    type = "SystemAssigned"
  }

  managed_virtual_network_enabled = true
  public_network_enabled          = false

  tags = merge(var.tags, {
    Name = "${local.name_prefix}-adf"
  })
}

# -----------------------------------------------------------------------------
# Linked Services
# -----------------------------------------------------------------------------

resource "azurerm_data_factory_linked_service_data_lake_storage_gen2" "adls" {
  name                 = "${local.name_prefix}-ls-adls"
  data_factory_id      = azurerm_data_factory.main.id
  url                  = var.storage_account_url
  use_managed_identity = true
}

resource "azurerm_data_factory_linked_service_cosmosdb" "cosmos" {
  name            = "${local.name_prefix}-ls-cosmos"
  data_factory_id = azurerm_data_factory.main.id
  account_endpoint = var.cosmosdb_endpoint
  database        = "${local.name_prefix}-db"
}

resource "azurerm_data_factory_linked_service_synapse" "synapse" {
  name            = "${local.name_prefix}-ls-synapse"
  data_factory_id = azurerm_data_factory.main.id
  connection_string = "Integrated Security=False;Data Source=${lookup(var.synapse_endpoint, "sql", "")};Initial Catalog=master"
}

# -----------------------------------------------------------------------------
# Sample Pipeline
# -----------------------------------------------------------------------------

resource "azurerm_data_factory_pipeline" "ingest" {
  name            = "${local.name_prefix}-ingest-pipeline"
  data_factory_id = azurerm_data_factory.main.id
  description     = "Pipeline to ingest data from CosmosDB to ADLS"

  activities_json = jsonencode([
    {
      name = "CopyCosmosToADLS"
      type = "Copy"
      dependsOn = []
      policy = {
        timeout                = "7.00:00:00"
        retry                  = 3
        retryIntervalInSeconds = 30
        secureOutput           = false
      }
      inputs  = [{ referenceName = "CosmosDBSource", type = "DatasetReference" }]
      outputs = [{ referenceName = "ADLSSink", type = "DatasetReference" }]
      typeProperties = {
        source = {
          type             = "CosmosDbSqlApiSource"
          preferredRegions = []
        }
        sink = {
          type = "ParquetSink"
          storeSettings = {
            type = "AzureBlobFSWriteSettings"
          }
          formatSettings = {
            type = "ParquetWriteSettings"
          }
        }
        enableStaging = false
      }
    }
  ])
}

resource "azurerm_data_factory_trigger_schedule" "daily" {
  name            = "${local.name_prefix}-daily-trigger"
  data_factory_id = azurerm_data_factory.main.id
  pipeline_name   = azurerm_data_factory_pipeline.ingest.name
  interval        = 1
  frequency       = "Day"
  start_time      = "2026-01-01T06:00:00Z"
  time_zone       = "UTC"
}

# -----------------------------------------------------------------------------
# Diagnostic Settings
# -----------------------------------------------------------------------------

resource "azurerm_monitor_diagnostic_setting" "adf" {
  name                       = "${local.name_prefix}-adf-diag"
  target_resource_id         = azurerm_data_factory.main.id
  log_analytics_workspace_id = azurerm_log_analytics_workspace.adf.id

  enabled_log {
    category = "ActivityRuns"
  }

  enabled_log {
    category = "PipelineRuns"
  }

  enabled_log {
    category = "TriggerRuns"
  }

  metric {
    category = "AllMetrics"
    enabled  = true
  }
}

resource "azurerm_log_analytics_workspace" "adf" {
  name                = "${local.name_prefix}-adf-law"
  location            = var.location
  resource_group_name = var.resource_group_name
  sku                 = "PerGB2018"
  retention_in_days   = var.environment == "prd" ? 90 : 30

  tags = var.tags
}
