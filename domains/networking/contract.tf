# ------------------------------------------------------------------------------
# Bounded context: networking
#
# Owns the private fabric every data store is placed into. Nothing in this
# platform is internet-reachable by design: stores sit on private subnets and
# are reached through private endpoints, so this context is a prerequisite for
# every other one.
# ------------------------------------------------------------------------------

locals {
  aws_enabled   = contains(var.clouds, "aws")
  azure_enabled = contains(var.clouds, "azure")
  gcp_enabled   = contains(var.clouds, "gcp")

  # Three private subnets, one per availability zone, carved from the cloud's
  # allocation. Carving here keeps address allocation a single decision.
  aws_private_cidrs = [for i in range(3) : cidrsubnet(var.address_space.aws, 8, i + 1)]
}

resource "terraform_data" "guards" {
  lifecycle {
    precondition {
      condition     = !local.aws_enabled || var.placement.aws != null
      error_message = "placement.aws is required when aws is in scope."
    }
    precondition {
      condition     = !local.azure_enabled || var.placement.azure != null
      error_message = "placement.azure is required when azure is in scope."
    }
    precondition {
      condition = !(local.aws_enabled && local.azure_enabled) || (
        cidrhost(var.address_space.aws, 0) != cidrhost(var.address_space.azure, 0)
      )
      error_message = "address_space.aws and address_space.azure must not overlap; cross-cloud replication would blackhole at runtime with no build error."
    }
  }
}

module "aws" {
  count  = local.aws_enabled ? 1 : 0
  source = "./aws"

  project_name         = var.landing_zone
  environment          = var.environment
  vpc_cidr             = var.address_space.aws
  private_subnet_cidrs = local.aws_private_cidrs
  aws_region           = var.placement.aws.region
  tags                 = var.tags

  depends_on = [terraform_data.guards]
}

module "azure" {
  count  = local.azure_enabled ? 1 : 0
  source = "./azure"

  project_name = var.landing_zone
  environment  = var.environment
  location     = var.placement.azure.location
  tags         = var.tags

  depends_on = [terraform_data.guards]
}

module "gcp" {
  count  = local.gcp_enabled ? 1 : 0
  source = "./gcp"

  project_name = var.landing_zone
  environment  = var.environment

  depends_on = [terraform_data.guards]
}
