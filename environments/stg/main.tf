# -----------------------------------------------------------------------------
# Staging Environment - Multi-Cloud Data Platform
# Mid-range sizing for pre-production validation
# -----------------------------------------------------------------------------

locals {
  common_tags = {
    Project     = var.project_name
    Environment = var.environment
    Owner       = var.owner
    ManagedBy   = "terraform"
  }
}

# =============================================================================
# AWS Modules
# =============================================================================

module "aws_networking" {
  source = "../../modules/aws/networking"

  project_name         = var.project_name
  environment          = var.environment
  vpc_cidr             = var.aws_vpc_cidr
  private_subnet_cidrs = var.aws_private_subnet_cidrs
  aws_region           = var.aws_region
  tags                 = local.common_tags
}

module "aws_data_lake" {
  source = "../../modules/aws/data-lake"

  project_name = var.project_name
  environment  = var.environment
  tags         = local.common_tags
}

module "aws_aurora" {
  source = "../../modules/aws/aurora"

  project_name            = var.project_name
  environment             = var.environment
  vpc_id                  = module.aws_networking.vpc_id
  subnet_ids              = module.aws_networking.private_subnet_ids
  security_group_ids      = [module.aws_networking.aurora_security_group_id]
  instance_class          = var.aurora_instance_class
  instance_count          = var.aurora_instance_count
  engine_version          = var.aurora_engine_version
  backup_retention_period = var.aurora_backup_retention
  tags                    = local.common_tags
}

module "aws_redshift" {
  source = "../../modules/aws/redshift"

  project_name       = var.project_name
  environment        = var.environment
  vpc_id             = module.aws_networking.vpc_id
  subnet_ids         = module.aws_networking.private_subnet_ids
  security_group_ids = [module.aws_networking.redshift_security_group_id]
  node_type          = var.redshift_node_type
  number_of_nodes    = var.redshift_number_of_nodes
  s3_data_lake_arn   = module.aws_data_lake.raw_bucket_arn
  tags               = local.common_tags
}

module "aws_glue" {
  source = "../../modules/aws/glue"

  project_name          = var.project_name
  environment           = var.environment
  s3_raw_path           = "s3://${module.aws_data_lake.raw_bucket_name}"
  s3_curated_path       = "s3://${module.aws_data_lake.curated_bucket_name}"
  s3_analytics_path     = "s3://${module.aws_data_lake.analytics_bucket_name}"
  data_lake_kms_key_arn = module.aws_data_lake.kms_key_arn
  vpc_id                = module.aws_networking.vpc_id
  subnet_id             = module.aws_networking.private_subnet_ids[0]
  security_group_ids    = [module.aws_networking.glue_security_group_id]
  tags                  = local.common_tags
}

module "aws_msk" {
  source = "../../modules/aws/msk"

  project_name       = var.project_name
  environment        = var.environment
  vpc_id             = module.aws_networking.vpc_id
  subnet_ids         = module.aws_networking.private_subnet_ids
  security_group_ids = [module.aws_networking.msk_security_group_id]
  instance_type      = var.msk_instance_type
  number_of_brokers  = var.msk_number_of_brokers
  ebs_volume_size    = var.msk_ebs_volume_size
  tags               = local.common_tags
}

# =============================================================================
# Azure Modules
# =============================================================================

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

# =============================================================================
# GCP Modules
# =============================================================================

module "gcp_networking" {
  source = "../../modules/gcp/networking"

  project_name = var.project_name
  environment  = var.environment
  region       = var.gcp_region
  vpc_cidr     = var.gcp_vpc_cidr
}

module "gcp_data_lake" {
  source = "../../modules/gcp/data-lake"

  project_name = var.project_name
  environment  = var.environment
  region       = var.gcp_region
  labels       = local.common_tags
}

module "gcp_cloudsql" {
  source = "../../modules/gcp/cloudsql"

  project_name     = var.project_name
  environment      = var.environment
  region           = var.gcp_region
  tier             = var.cloudsql_tier
  ha_enabled       = var.cloudsql_ha_enabled
  backup_retention = var.cloudsql_backup_retention
  read_replicas    = var.cloudsql_read_replicas
  network_id       = module.gcp_networking.vpc_id
  private_ip_range = module.gcp_networking.private_ip_range_name
}

module "gcp_bigquery" {
  source = "../../modules/gcp/bigquery"

  project_name = var.project_name
  environment  = var.environment
  region       = var.gcp_region
  labels       = local.common_tags
}

module "gcp_dataflow" {
  source = "../../modules/gcp/dataflow"

  project_name = var.project_name
  environment  = var.environment
  region       = var.gcp_region
  network      = module.gcp_networking.vpc_name
  subnetwork   = module.gcp_networking.subnet_self_link
  machine_type = var.dataflow_machine_type
  max_workers  = var.dataflow_max_workers
}

module "gcp_kafka" {
  source = "../../modules/gcp/kafka"

  project_name = var.project_name
  environment  = var.environment
  region       = var.gcp_region
  labels       = local.common_tags
}

# =============================================================================
# Shared Modules
# =============================================================================

module "governance" {
  source = "../../modules/shared/governance"

  project_name              = var.project_name
  environment               = var.environment
  aws_region                = var.aws_region
  azure_region              = var.azure_region
  azure_resource_group_name = module.azure_networking.resource_group_name
  gcp_region                = var.gcp_region
  gcp_project_id            = var.gcp_project_id
  tags                      = local.common_tags
}

module "streaming" {
  source = "../../modules/shared/streaming"

  project_name               = var.project_name
  environment                = var.environment
  msk_cluster_arn            = module.aws_msk.cluster_arn
  msk_bootstrap_brokers      = module.aws_msk.bootstrap_brokers_tls
  eventhubs_namespace        = module.azure_kafka.namespace_name
  eventhubs_connection_string = module.azure_kafka.primary_connection_string
  pubsub_topics              = module.gcp_kafka.topic_ids
  tags                       = local.common_tags
}
