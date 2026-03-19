# -----------------------------------------------------------------------------
# Terragrunt root configuration
# Multi-Cloud Data Platform
# -----------------------------------------------------------------------------

locals {
  # Parse the environment from the directory path
  env_vars    = read_terragrunt_config(find_in_parent_folders("env.hcl", "env.hcl"), { locals = {} })
  environment = try(local.env_vars.locals.environment, "dev")
  project     = "data-platform"

  # Common tags applied to all resources
  common_tags = {
    Project     = local.project
    Environment = local.environment
    ManagedBy   = "terraform"
    Repository  = "terraform-multi-cloud-data-platform"
  }

  # Remote state configuration per cloud
  aws_region   = try(local.env_vars.locals.aws_region, "eu-west-1")
  azure_region = try(local.env_vars.locals.azure_region, "westeurope")
  gcp_region   = try(local.env_vars.locals.gcp_region, "europe-west1")
}

# Generate provider configurations
generate "provider" {
  path      = "provider.tf"
  if_exists = "overwrite_terragrunt"
  contents  = <<-EOF
    terraform {
      required_version = ">= 1.7.0"

      required_providers {
        aws = {
          source  = "hashicorp/aws"
          version = "~> 5.0"
        }
        azurerm = {
          source  = "hashicorp/azurerm"
          version = "~> 4.0"
        }
        google = {
          source  = "hashicorp/google"
          version = "~> 6.0"
        }
      }
    }

    provider "aws" {
      region = "${local.aws_region}"

      default_tags {
        tags = ${jsonencode(local.common_tags)}
      }
    }

    provider "azurerm" {
      features {
        resource_group {
          prevent_deletion_if_contains_resources = true
        }
        key_vault {
          purge_soft_delete_on_destroy = false
        }
      }
    }

    provider "google" {
      region = "${local.gcp_region}"
      default_labels = ${jsonencode(local.common_tags)}
    }
  EOF
}

# Remote state configuration - AWS S3 backend
remote_state {
  backend = "s3"
  config = {
    bucket         = "${local.project}-tfstate-${local.environment}"
    key            = "${path_relative_to_include()}/terraform.tfstate"
    region         = local.aws_region
    encrypt        = true
    dynamodb_table = "${local.project}-tflock-${local.environment}"

    s3_bucket_tags = local.common_tags
    dynamodb_table_tags = local.common_tags
  }
  generate = {
    path      = "backend.tf"
    if_exists = "overwrite_terragrunt"
  }
}

# Default inputs passed to all modules
inputs = {
  environment  = local.environment
  project_name = local.project
  common_tags  = local.common_tags
  aws_region   = local.aws_region
  azure_region = local.azure_region
  gcp_region   = local.gcp_region
}

# Terraform version constraint
terraform_version_constraint = ">= 1.7.0"

# Terragrunt version constraint
terragrunt_version_constraint = ">= 0.60.0"
