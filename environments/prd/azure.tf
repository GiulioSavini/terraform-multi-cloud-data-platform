# -----------------------------------------------------------------------------
# Production Environment - Azure Modules
# Networking, Data Lake, CosmosDB, Synapse, Data Factory, Kafka (Event Hubs)
# -----------------------------------------------------------------------------

module "azure_networking" {
  source = "../../modules/azure/networking"

  project_name = var.project_name
  environment  = var.environment
  location     = var.azure_region
  vnet_cidr    = var.azure_vnet_cidr
  tags         = local.common_tags
}

module "azure_data_lake" {
  source = "../../modules/azure/data-lake"

  project_name        = var.project_name
  environment         = var.environment
  location            = var.azure_region
  resource_group_name = module.azure_networking.resource_group_name
  subnet_id           = module.azure_networking.storage_subnet_id
  tags                = local.common_tags
}

module "azure_cosmosdb" {
  source = "../../modules/azure/cosmosdb"

  project_name        = var.project_name
  environment         = var.environment
  location            = var.azure_region
  resource_group_name = module.azure_networking.resource_group_name
  subnet_id           = module.azure_networking.cosmosdb_subnet_id
  max_throughput      = var.cosmosdb_max_throughput
  geo_replication     = var.cosmosdb_geo_replication
  tags                = local.common_tags
}

module "azure_synapse" {
  source = "../../modules/azure/synapse"

  project_name        = var.project_name
  environment         = var.environment
  location            = var.azure_region
  resource_group_name = module.azure_networking.resource_group_name
  storage_account_id  = module.azure_data_lake.storage_account_id
  storage_account_url = module.azure_data_lake.primary_dfs_endpoint
  filesystem_id       = module.azure_data_lake.raw_container_id
  subnet_id           = module.azure_networking.synapse_subnet_id
  sql_pool_sku        = var.synapse_sql_pool_sku
  spark_node_count    = var.synapse_spark_node_count
  tags                = local.common_tags
}

module "azure_data_factory" {
  source = "../../modules/azure/data-factory"

  project_name        = var.project_name
  environment         = var.environment
  location            = var.azure_region
  resource_group_name = module.azure_networking.resource_group_name
  storage_account_url = module.azure_data_lake.primary_dfs_endpoint
  cosmosdb_endpoint   = module.azure_cosmosdb.endpoint
  synapse_endpoint    = module.azure_synapse.connectivity_endpoints
  tags                = local.common_tags
}

module "azure_kafka" {
  source = "../../modules/azure/kafka"

  project_name        = var.project_name
  environment         = var.environment
  location            = var.azure_region
  resource_group_name = module.azure_networking.resource_group_name
  capacity            = var.eventhubs_capacity
  storage_account_id  = module.azure_data_lake.storage_account_id
  tags                = local.common_tags
}
