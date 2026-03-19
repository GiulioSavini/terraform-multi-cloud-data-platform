# =============================================================================
# Complete Data Platform Example
# Deploys the full stack across AWS + Azure + GCP with streaming
# =============================================================================
#
# Usage:
#   cp terraform.tfvars.example terraform.tfvars
#   terraform init && terraform apply
#
# Estimated cost: ~$400/month (dev sizing)
# Deploy time: ~30 minutes
# =============================================================================

terraform {
  required_version = ">= 1.9.0"
  required_providers {
    aws     = { source = "hashicorp/aws", version = "~> 5.0" }
    azurerm = { source = "hashicorp/azurerm", version = "~> 3.0" }
    google  = { source = "hashicorp/google", version = "~> 5.0" }
    random  = { source = "hashicorp/random", version = "~> 3.0" }
  }
}

provider "aws" { region = var.aws_region }
provider "azurerm" { features {}; subscription_id = var.azure_subscription_id }
provider "google" { project = var.gcp_project_id; region = var.gcp_region }

variable "aws_region" { type = string; default = "eu-west-1" }
variable "azure_subscription_id" { type = string }
variable "azure_location" { type = string; default = "westeurope" }
variable "gcp_project_id" { type = string }
variable "gcp_region" { type = string; default = "europe-west1" }
variable "synapse_password" { type = string; sensitive = true }

locals {
  project     = "dataplatform"
  environment = "dev"
  tags        = { Project = local.project, Environment = local.environment, ManagedBy = "terraform" }
}

resource "azurerm_resource_group" "main" {
  name     = "${local.project}-${local.environment}-rg"
  location = var.azure_location
  tags     = local.tags
}

# --- AWS Data Stack ---
module "aws_networking" {
  source      = "../../modules/aws/networking"
  project     = local.project
  environment = local.environment
  vpc_cidr    = "10.0.0.0/16"
  tags        = local.tags
}

module "aws_aurora" {
  source      = "../../modules/aws/aurora"
  project     = local.project
  environment = local.environment
  # Pass required vars from networking module
  tags = local.tags
}

module "aws_data_lake" {
  source      = "../../modules/aws/data-lake"
  project     = local.project
  environment = local.environment
  tags        = local.tags
}

module "aws_glue" {
  source             = "../../modules/aws/glue"
  project            = local.project
  environment        = local.environment
  raw_bucket_name    = module.aws_data_lake.raw_bucket_name
  curated_bucket_name = module.aws_data_lake.curated_bucket_name
  tags               = local.tags
}

# --- Azure Data Stack ---
module "azure_networking" {
  source              = "../../modules/azure/networking"
  project             = local.project
  environment         = local.environment
  resource_group_name = azurerm_resource_group.main.name
  location            = var.azure_location
  tags                = local.tags
}

module "azure_data_lake" {
  source              = "../../modules/azure/data-lake"
  project             = local.project
  environment         = local.environment
  resource_group_name = azurerm_resource_group.main.name
  location            = var.azure_location
  tags                = local.tags
}

module "azure_cosmosdb" {
  source              = "../../modules/azure/cosmosdb"
  project             = local.project
  environment         = local.environment
  resource_group_name = azurerm_resource_group.main.name
  location            = var.azure_location
  tags                = local.tags
}

module "azure_synapse" {
  source              = "../../modules/azure/synapse"
  project             = local.project
  environment         = local.environment
  resource_group_name = azurerm_resource_group.main.name
  location            = var.azure_location
  adls_id             = module.azure_data_lake.storage_account_id
  adls_filesystem_id  = module.azure_data_lake.raw_filesystem_id
  sql_admin_password  = var.synapse_password
  tags                = local.tags
}

# --- GCP Data Stack ---
module "gcp_networking" {
  source         = "../../modules/gcp/networking"
  project        = local.project
  environment    = local.environment
  gcp_project_id = var.gcp_project_id
  region         = var.gcp_region
}

module "gcp_cloudsql" {
  source         = "../../modules/gcp/cloudsql"
  project        = local.project
  environment    = local.environment
  gcp_project_id = var.gcp_project_id
  region         = var.gcp_region
  network_id     = module.gcp_networking.network_id
  tier           = "db-f1-micro"
}

module "gcp_data_lake" {
  source         = "../../modules/gcp/data-lake"
  project        = local.project
  environment    = local.environment
  gcp_project_id = var.gcp_project_id
}

module "gcp_bigquery" {
  source         = "../../modules/gcp/bigquery"
  project        = local.project
  environment    = local.environment
  gcp_project_id = var.gcp_project_id
}

# --- Outputs ---
output "aws_aurora_endpoint" { value = "See Aurora module outputs" }
output "aws_s3_buckets" { value = "raw: ${module.aws_data_lake.raw_bucket_name}" }
output "azure_cosmos_endpoint" { value = module.azure_cosmosdb.endpoint }
output "azure_synapse_name" { value = module.azure_synapse.workspace_name }
output "gcp_cloudsql_ip" { value = module.gcp_cloudsql.private_ip }
output "gcp_bigquery_dataset" { value = module.gcp_bigquery.analytics_dataset_id }
