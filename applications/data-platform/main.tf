# ==============================================================================
# Application: data platform
#
# Composition root. The only place bounded contexts are wired together, and the
# only place that knows their dependency order:
#
#   networking
#     -> data-lake, operational-store, stream-ingestion
#     -> analytics-warehouse (reads the lake's analytics zone)
#     -> data-pipeline       (writes the lake, reads the stores, feeds the warehouse)
#     -> data-governance     (catalogs all of it)
#
# Contexts talk only through their published contracts. If a wiring below
# reaches into a provider adapter, that is a defect here, not a shortcut.
# ==============================================================================

locals {
  contexts = [
    "networking", "data-lake", "operational-store", "analytics-warehouse",
    "stream-ingestion", "data-pipeline", "data-governance",
  ]

  azure_enabled = contains(var.clouds, "azure")
  gcp_enabled   = contains(var.clouds, "gcp")

  governance_enabled = var.enable_governance && length(var.clouds) >= 2

  azure_placement = local.azure_enabled ? {
    location            = var.azure_location
    resource_group_name = module.networking.azure_resource_group_name
  } : null
}

module "tags" {
  for_each = toset(local.contexts)
  source   = "../../platform/tagging"

  landing_zone        = var.landing_zone
  environment         = var.environment
  context             = each.key
  owner               = var.owner
  cost_center         = var.cost_center
  data_classification = var.data_classification
}

module "networking" {
  source = "../../domains/networking"

  landing_zone  = var.landing_zone
  environment   = var.environment
  clouds        = var.clouds
  address_space = var.address_space

  placement = {
    aws   = { region = var.aws_region }
    azure = local.azure_enabled ? { location = var.azure_location } : null
  }

  tags = module.tags["networking"].tags
}

module "data_lake" {
  source = "../../domains/data-lake"

  landing_zone = var.landing_zone
  environment  = var.environment
  clouds       = var.clouds
  networks     = module.networking.networks

  placement = {
    azure = local.azure_enabled ? {
      location            = var.azure_location
      resource_group_name = module.networking.azure_resource_group_name
      subnet_id           = module.networking.azure_subnets.data_lake
    } : null
  }

  tags   = module.tags["data-lake"].tags
  labels = module.tags["data-lake"].labels
}

module "operational_store" {
  source = "../../domains/operational-store"

  landing_zone = var.landing_zone
  environment  = var.environment
  clouds       = var.clouds
  networks     = module.networking.networks

  placement = {
    azure = local.azure_enabled ? {
      location            = var.azure_location
      resource_group_name = module.networking.azure_resource_group_name
      subnet_id           = module.networking.azure_subnets.operational_store
    } : null
  }

  aws_security_group_ids = [module.networking.aws_security_groups.operational_store]
  gcp_network_id         = local.gcp_enabled ? module.networking.gcp_network.id : ""
  master_username        = var.master_username
  cosmos_capabilities    = var.cosmos_capabilities

  tags = module.tags["operational-store"].tags
}

module "analytics_warehouse" {
  source = "../../domains/analytics-warehouse"

  landing_zone = var.landing_zone
  environment  = var.environment
  clouds       = var.clouds
  networks     = module.networking.networks

  lake_zone_arns = module.data_lake.aws_zone_arns
  azure_storage  = module.data_lake.azure_storage

  aws_security_group_ids = [module.networking.aws_security_groups.analytics_warehouse]
  placement              = { azure = local.azure_placement }

  tags   = module.tags["analytics-warehouse"].tags
  labels = module.tags["analytics-warehouse"].labels
}

module "stream_ingestion" {
  source = "../../domains/stream-ingestion"

  landing_zone = var.landing_zone
  environment  = var.environment
  clouds       = var.clouds
  networks     = module.networking.networks

  aws_security_group_ids   = [module.networking.aws_security_groups.stream_ingestion]
  azure_storage_account_id = local.azure_enabled ? module.data_lake.azure_storage.account_id : ""
  placement                = { azure = local.azure_placement }

  enable_cross_cloud_replication = var.enable_cross_cloud_replication

  tags   = module.tags["stream-ingestion"].tags
  labels = module.tags["stream-ingestion"].labels
}

module "data_pipeline" {
  source = "../../domains/data-pipeline"

  landing_zone = var.landing_zone
  environment  = var.environment
  clouds       = var.clouds
  networks     = module.networking.networks

  lake_zones           = module.data_lake.zones
  lake_encryption_keys = module.data_lake.encryption_keys
  azure_storage        = module.data_lake.azure_storage

  operational_endpoints = module.operational_store.endpoints
  warehouse_endpoints   = module.analytics_warehouse.azure_endpoints

  aws_security_group_ids = [module.networking.aws_security_groups.data_pipeline]
  gcp_network            = local.gcp_enabled ? module.networking.gcp_network : null
  placement              = { azure = local.azure_placement }

  tags   = module.tags["data-pipeline"].tags
  labels = module.tags["data-pipeline"].labels
}

module "data_governance" {
  count  = local.governance_enabled ? 1 : 0
  source = "../../domains/data-governance"

  landing_zone = var.landing_zone
  environment  = var.environment
  clouds       = var.clouds

  placement = {
    azure = {
      location            = var.azure_location
      resource_group_name = module.networking.azure_resource_group_name
    }
    gcp = {
      project_id = var.gcp_project_id
      region     = var.gcp_region
    }
  }

  tags = module.tags["data-governance"].tags
}

module "controls" {
  source = "../../compliance/controls"
}
