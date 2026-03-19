# -----------------------------------------------------------------------------
# Staging Environment - Shared Modules
# Cross-cloud governance and streaming integration
# -----------------------------------------------------------------------------

module "governance" {
  source = "../../modules/shared/governance"

  project_name              = var.project_name
  environment               = var.environment
  azure_region              = var.azure_region
  azure_resource_group_name = module.azure_networking.resource_group_name
  gcp_region                = var.gcp_region
  gcp_project_id            = var.gcp_project_id
  tags                      = local.common_tags
}

module "streaming" {
  source = "../../modules/shared/streaming"

  project_name               = var.project_name
  environment                = var.environment
  msk_cluster_arn            = module.aws_msk.cluster_arn
  msk_bootstrap_brokers      = module.aws_msk.bootstrap_brokers_tls
  eventhubs_namespace        = module.azure_kafka.namespace_name
  eventhubs_connection_string = module.azure_kafka.primary_connection_string
  tags                       = local.common_tags
}
