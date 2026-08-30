# ------------------------------------------------------------------------------
# Bounded context: stream-ingestion
#
# Owns the event backbone: MSK, Event Hubs, Pub/Sub, and optionally the
# connectors that mirror topics between clouds.
# ------------------------------------------------------------------------------

locals {
  aws_enabled   = contains(var.clouds, "aws")
  azure_enabled = contains(var.clouds, "azure")
  gcp_enabled   = contains(var.clouds, "gcp")

  replication_possible = local.aws_enabled && local.azure_enabled
  replication_enabled  = var.enable_cross_cloud_replication && local.replication_possible
}

resource "terraform_data" "guards" {
  lifecycle {
    precondition {
      condition     = length(setsubtract(toset(var.clouds), toset(keys(var.networks)))) == 0
      error_message = "Every cloud in clouds must exist in networks."
    }
    precondition {
      condition     = !local.aws_enabled || length(var.aws_security_group_ids) > 0
      error_message = "aws_security_group_ids is required when aws is in scope."
    }
    precondition {
      condition     = !local.azure_enabled || length(var.azure_storage_account_id) > 0
      error_message = "azure_storage_account_id is required when azure is in scope. Event Hubs Capture needs somewhere to land, and without it events past the retention window are gone."
    }
    precondition {
      condition     = !var.enable_cross_cloud_replication || local.replication_possible
      error_message = "enable_cross_cloud_replication requires both aws and azure in clouds; the mirror has no second endpoint otherwise."
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
  tags               = var.tags

  depends_on = [terraform_data.guards]
}

module "azure" {
  count  = local.azure_enabled ? 1 : 0
  source = "./azure"

  project_name        = var.landing_zone
  environment         = var.environment
  location            = var.placement.azure.location
  resource_group_name = var.placement.azure.resource_group_name
  storage_account_id  = var.azure_storage_account_id
  tags                = var.tags

  depends_on = [terraform_data.guards]
}

module "gcp" {
  count  = local.gcp_enabled ? 1 : 0
  source = "./gcp"

  project_name = var.landing_zone
  environment  = var.environment
  labels       = var.labels

  depends_on = [terraform_data.guards]
}

module "cross_cloud" {
  count  = local.replication_enabled ? 1 : 0
  source = "./cross-cloud"

  project_name = var.landing_zone
  environment  = var.environment

  msk_cluster_arn       = module.aws[0].cluster_arn
  msk_bootstrap_brokers = module.aws[0].bootstrap_brokers_sasl_iam

  eventhubs_namespace         = module.azure[0].namespace_name
  eventhubs_connection_string = module.azure[0].primary_connection_string
  tags                        = var.tags

}
