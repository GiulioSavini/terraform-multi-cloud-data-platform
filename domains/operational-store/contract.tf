# ------------------------------------------------------------------------------
# Bounded context: operational-store
#
# Owns the transactional stores that applications write to: Aurora, Cosmos DB,
# Cloud SQL. Distinct from analytics-warehouse, which owns the stores that
# analysts query — different access patterns, different retention, different
# blast radius.
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
      condition     = !local.aws_enabled || length(var.aws_security_group_ids) > 0
      error_message = "aws_security_group_ids is required when aws is in scope. A cluster with no security group is unreachable, not open — but it is also not what was intended."
    }
    precondition {
      condition     = !local.gcp_enabled || length(var.gcp_network_id) > 0
      error_message = "gcp_network_id is required when gcp is in scope; Cloud SQL private service access needs it."
    }
    precondition {
      condition     = !local.azure_enabled || var.placement.azure != null
      error_message = "placement.azure is required when azure is in scope."
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
  master_username    = var.master_username

  depends_on = [terraform_data.guards]
}

module "azure" {
  count  = local.azure_enabled ? 1 : 0
  source = "./azure"

  project_name        = var.landing_zone
  environment         = var.environment
  location            = var.placement.azure.location
  resource_group_name = var.placement.azure.resource_group_name
  subnet_id           = var.placement.azure.subnet_id
  capabilities        = var.cosmos_capabilities

  depends_on = [terraform_data.guards]
}

module "gcp" {
  count  = local.gcp_enabled ? 1 : 0
  source = "./gcp"

  project_name = var.landing_zone
  environment  = var.environment
  network_id   = var.gcp_network_id

  depends_on = [terraform_data.guards]
}
