# -----------------------------------------------------------------------------
# Staging Environment - GCP Modules
# Networking, Cloud SQL, Data Lake, BigQuery, Dataflow, Kafka (Pub/Sub)
# -----------------------------------------------------------------------------

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
