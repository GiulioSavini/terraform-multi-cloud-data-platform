# =============================================================================
# AWS Data Lake Example
# Deploys: Aurora PostgreSQL + S3 Data Lake + Glue ETL + Redshift
# =============================================================================
#
# Usage:
#   terraform init && terraform apply
#
# Estimated cost: ~$100/month (dev sizing)
# Deploy time: ~15 minutes
# =============================================================================

terraform {
  required_version = ">= 1.9.0"
  required_providers {
    aws = { source = "hashicorp/aws", version = "~> 5.0" }
  }
}

provider "aws" { region = "eu-west-1" }

locals {
  project     = "aws-datalake"
  environment = "dev"
  tags        = { Project = local.project, Environment = local.environment }
}

# --- S3 Data Lake (raw/curated/analytics zones) ---
module "data_lake" {
  source      = "../../modules/aws/data-lake"
  project     = local.project
  environment = local.environment
  tags        = local.tags
}

# --- Glue ETL (crawlers + jobs) ---
module "glue" {
  source              = "../../modules/aws/glue"
  project             = local.project
  environment         = local.environment
  raw_bucket_name     = module.data_lake.raw_bucket_name
  curated_bucket_name = module.data_lake.curated_bucket_name
  tags                = local.tags
}

# --- Redshift (analytics warehouse) ---
module "redshift" {
  source      = "../../modules/aws/redshift"
  project     = local.project
  environment = local.environment
  tags        = local.tags
}

output "s3_raw_bucket" { value = module.data_lake.raw_bucket_name }
output "s3_curated_bucket" { value = module.data_lake.curated_bucket_name }
output "glue_database" { value = module.glue.catalog_database_name }
output "glue_etl_job" { value = module.glue.etl_job_name }
