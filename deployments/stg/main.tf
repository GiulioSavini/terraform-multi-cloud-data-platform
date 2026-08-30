# ==============================================================================
# Deployment: stg
#
# Binds the data-platform application to one environment. Everything that
# varies between environments lives here; everything that does not lives in
# applications/data-platform.
# ==============================================================================

module "data_platform" {
  source = "../../applications/data-platform"

  landing_zone = "data-platform"
  environment  = "stg"
  clouds       = ["aws", "azure"]

  owner               = var.owner
  cost_center         = var.cost_center
  data_classification = var.data_classification

  aws_region     = var.aws_region
  azure_location = "westeurope"
  gcp_project_id = var.gcp_project_id
  gcp_region     = var.gcp_region

  master_username     = var.master_username
  cosmos_capabilities = []

  enable_cross_cloud_replication = false
  enable_governance              = true
}
