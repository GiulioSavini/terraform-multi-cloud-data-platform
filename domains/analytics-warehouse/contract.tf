# ------------------------------------------------------------------------------
# Bounded context: analytics-warehouse
#
# Owns the stores analysts query: Redshift, Synapse, BigQuery. It reads the
# analytics zone of the data lake and never writes to raw or curated — that is
# the data-pipeline context's job, and the separation is what keeps a bad query
# from corrupting source data.
# ------------------------------------------------------------------------------

locals {
  aws_enabled   = contains(var.clouds, "aws")
  azure_enabled = contains(var.clouds, "azure")
  gcp_enabled   = contains(var.clouds, "gcp")
}

resource "terraform_data" "guards" {
  lifecycle {
    precondition {
      condition     = length(setsubtract(toset(var.clouds), toset(keys(var.networks)))) == 0
      error_message = "Every cloud in clouds must exist in networks."
    }
    precondition {
      condition     = !local.aws_enabled || var.lake_zone_arns != null
      error_message = "lake_zone_arns is required when aws is in scope. Redshift Spectrum reads the analytics zone, and without the ARN the external schema resolves to nothing."
    }
    precondition {
      condition     = !local.azure_enabled || var.azure_storage != null
      error_message = "azure_storage is required when azure is in scope. Synapse is backed by the data lake's storage account."
    }
    precondition {
      condition     = !local.aws_enabled || length(var.aws_security_group_ids) > 0
      error_message = "aws_security_group_ids is required when aws is in scope."
    }
  }
}

module "aws" {
  count  = local.aws_enabled ? 1 : 0
  source = "./aws"

  project_name       = var.landing_zone
  environment        = var.environment
  subnet_ids         = var.networks["aws"].private_subnets
  security_group_ids = var.aws_security_group_ids
  s3_data_lake_arn   = var.lake_zone_arns.analytics

  depends_on = [terraform_data.guards]
}

module "azure" {
  count  = local.azure_enabled ? 1 : 0
  source = "./azure"

  project_name        = var.landing_zone
  environment         = var.environment
  location            = var.placement.azure.location
  resource_group_name = var.placement.azure.resource_group_name
  storage_account_id  = var.azure_storage.account_id
  filesystem_id       = var.azure_storage.filesystem_id

  depends_on = [terraform_data.guards]
}

module "gcp" {
  count  = local.gcp_enabled ? 1 : 0
  source = "./gcp"

  project_name = var.landing_zone
  environment  = var.environment

  depends_on = [terraform_data.guards]
}
