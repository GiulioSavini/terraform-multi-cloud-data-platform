locals {
  name_prefix = "${var.project}-${var.environment}"
}

resource "azurerm_data_factory" "main" {
  name                = "${local.name_prefix}-adf"
  location            = var.location
  resource_group_name = var.resource_group_name

  identity { type = "SystemAssigned" }

  managed_virtual_network_enabled = true
  public_network_enabled          = false

  tags = var.tags
}

resource "azurerm_data_factory_linked_service_data_lake_storage_gen2" "adls" {
  count = var.adls_endpoint != "" ? 1 : 0

  name                 = "${local.name_prefix}-ls-adls"
  data_factory_id      = azurerm_data_factory.main.id
  url                  = var.adls_endpoint
  use_managed_identity = true
}

resource "azurerm_data_factory_linked_service_cosmosdb" "cosmos" {
  count = var.cosmos_connection_string != "" ? 1 : 0

  name              = "${local.name_prefix}-ls-cosmos"
  data_factory_id   = azurerm_data_factory.main.id
  connection_string = var.cosmos_connection_string
  database          = "${local.name_prefix}-db"
}

resource "azurerm_data_factory_pipeline" "ingest" {
  name            = "${local.name_prefix}-ingest-pipeline"
  data_factory_id = azurerm_data_factory.main.id

  activities_json = jsonencode([
    {
      name = "CopyCosmosToADLS"
      type = "Copy"
      inputs = [{ referenceName = "CosmosDBSource", type = "DatasetReference" }]
      outputs = [{ referenceName = "ADLSSink", type = "DatasetReference" }]
      typeProperties = {
        source = { type = "CosmosDbSqlApiSource", preferredRegions = [] }
        sink   = { type = "ParquetSink" }
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
  start_time      = "2024-01-01T06:00:00Z"
}
