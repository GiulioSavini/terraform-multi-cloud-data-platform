# ------------------------------------------------------------------------------
# Bounded context: data-lake
#
# Owns object storage and its zoning: raw, curated and analytics. Every other
# data context reads from or writes to these zones, so the zone vocabulary is
# the contract — not the bucket names, which differ per provider.
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
      condition     = !local.azure_enabled || var.placement.azure != null
      error_message = "placement.azure is required when azure is in scope."
    }
  }
}

module "aws" {
  count  = local.aws_enabled ? 1 : 0
  source = "./aws"

  project_name = var.landing_zone
  environment  = var.environment
  tags         = var.tags

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
