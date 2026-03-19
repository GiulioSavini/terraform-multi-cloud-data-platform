# =============================================================================
# GCP BigQuery Analytics Example
# Deploys: CloudSQL + GCS Data Lake + BigQuery + Dataflow + Pub/Sub
# =============================================================================
#
# Usage:
#   terraform init
#   terraform apply -var="gcp_project_id=YOUR_PROJECT"
#
# Estimated cost: ~$50/month (dev, BigQuery on-demand)
# Deploy time: ~10 minutes
# =============================================================================

terraform {
  required_version = ">= 1.9.0"
  required_providers {
    google = { source = "hashicorp/google", version = "~> 5.0" }
    random = { source = "hashicorp/random", version = "~> 3.0" }
  }
}

provider "google" {
  project = var.gcp_project_id
  region  = "europe-west1"
}

variable "gcp_project_id" { type = string }

locals {
  project     = "gcp-analytics"
  environment = "dev"
  labels      = { project = local.project, environment = local.environment }
}

# --- Network ---
module "networking" {
  source         = "../../modules/gcp/networking"
  project        = local.project
  environment    = local.environment
  gcp_project_id = var.gcp_project_id
}

# --- CloudSQL PostgreSQL ---
module "cloudsql" {
  source         = "../../modules/gcp/cloudsql"
  project        = local.project
  environment    = local.environment
  gcp_project_id = var.gcp_project_id
  network_id     = module.networking.network_id
  tier           = "db-f1-micro"
  disk_size      = 10
  labels         = local.labels
}

# --- GCS Data Lake ---
module "data_lake" {
  source         = "../../modules/gcp/data-lake"
  project        = local.project
  environment    = local.environment
  gcp_project_id = var.gcp_project_id
  labels         = local.labels
}

# --- BigQuery ---
module "bigquery" {
  source         = "../../modules/gcp/bigquery"
  project        = local.project
  environment    = local.environment
  gcp_project_id = var.gcp_project_id
  labels         = local.labels
}

# --- Pub/Sub (Kafka alternative) ---
module "pubsub" {
  source         = "../../modules/gcp/kafka"
  project        = local.project
  environment    = local.environment
  gcp_project_id = var.gcp_project_id
  bq_dataset_id  = module.bigquery.raw_dataset_id
  labels         = local.labels
}

# --- Dataflow ---
module "dataflow" {
  source         = "../../modules/gcp/dataflow"
  project        = local.project
  environment    = local.environment
  gcp_project_id = var.gcp_project_id
  region         = "europe-west1"
  network_id     = module.networking.network_id
  subnet_id      = module.networking.subnet_id
  labels         = local.labels
}

output "cloudsql_connection" { value = module.cloudsql.connection_name }
output "bq_analytics_dataset" { value = module.bigquery.analytics_dataset_id }
output "gcs_raw_bucket" { value = module.data_lake.raw_bucket }
output "pubsub_events_topic" { value = module.pubsub.events_topic_id }
output "dataflow_sa" { value = module.dataflow.service_account_email }
