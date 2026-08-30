# ------------------------------------------------------------------------------
# Bounded context: data-pipeline
#
# Owns movement and transformation: Glue, Data Factory, Dataflow. This is the
# only context that writes to the raw and curated zones of the lake.
#
# It is deliberately the most connected context in the platform — it reads from
# the operational stores, writes to the lake, and feeds the warehouse — which is
# exactly why the things it touches are passed in as contracts rather than
# discovered.
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
      condition     = length(setsubtract(toset(var.clouds), toset(keys(var.lake_zones)))) == 0
      error_message = "Every cloud in clouds must have lake zones. A pipeline with no destination zone is not a pipeline."
    }
    precondition {
      condition     = !local.aws_enabled || can(var.lake_encryption_keys["aws"])
      error_message = "lake_encryption_keys.aws is required when aws is in scope. Glue cannot read a KMS-encrypted lake without being granted the key, and the failure appears at job run time rather than at apply time."
    }
    precondition {
      condition     = !local.gcp_enabled || var.gcp_network != null
      error_message = "gcp_network is required when gcp is in scope; Dataflow workers must be placed on the private network rather than given public addresses."
    }
    precondition {
      condition     = !local.azure_enabled || var.azure_storage != null
      error_message = "azure_storage is required when azure is in scope."
    }
  }
}

module "aws" {
  count  = local.aws_enabled ? 1 : 0
  source = "./aws"

  project_name = var.landing_zone
  environment  = var.environment

  # Zones are addressed through the data-lake contract, never by reconstructing
  # a bucket name from a convention.
  s3_raw_path       = "s3://${var.lake_zones["aws"].raw}/"
  s3_curated_path   = "s3://${var.lake_zones["aws"].curated}/"
  s3_analytics_path = "s3://${var.lake_zones["aws"].analytics}/"

  data_lake_kms_key_arn = var.lake_encryption_keys["aws"]
  subnet_id             = var.networks["aws"].private_subnets[0]
  security_group_ids    = var.aws_security_group_ids

  depends_on = [terraform_data.guards]
}

module "azure" {
  count  = local.azure_enabled ? 1 : 0
  source = "./azure"

  project_name        = var.landing_zone
  environment         = var.environment
  location            = var.placement.azure.location
  resource_group_name = var.placement.azure.resource_group_name

  storage_account_url = var.azure_storage.dfs_endpoint
  cosmosdb_endpoint   = try(var.operational_endpoints["azure"].writer, "")
  synapse_endpoint    = try(var.warehouse_endpoints, "")

  depends_on = [terraform_data.guards]
}

module "gcp" {
  count  = local.gcp_enabled ? 1 : 0
  source = "./gcp"

  project_name = var.landing_zone
  environment  = var.environment
  network      = var.gcp_network.self_link
  subnetwork   = var.gcp_network.dataflow_subnet

  depends_on = [terraform_data.guards]
}
