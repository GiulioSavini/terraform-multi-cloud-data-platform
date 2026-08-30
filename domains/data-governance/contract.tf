# ------------------------------------------------------------------------------
# Bounded context: data-governance
#
# Owns the cross-cloud view: the catalog, classification, and the keys and roles
# that make access auditable.
#
# There is one adapter, and it is cross-cloud, because governance that covers a
# single provider is not governance. A catalog listing one of three clouds is
# worse than no catalog: it looks complete.
# ------------------------------------------------------------------------------

resource "terraform_data" "guards" {
  lifecycle {
    precondition {
      condition     = length(var.clouds) >= 2
      error_message = "data-governance needs at least two clouds in scope. A cross-cloud catalog covering one cloud reports full coverage of a platform it only half sees."
    }
  }
}

module "cross_cloud" {
  source = "./cross-cloud"

  project_name = var.landing_zone
  environment  = var.environment

  azure_region              = var.placement.azure.location
  azure_resource_group_name = var.placement.azure.resource_group_name
  gcp_region                = var.placement.gcp.region
  gcp_project_id            = var.placement.gcp.project_id

  depends_on = [terraform_data.guards]
}
