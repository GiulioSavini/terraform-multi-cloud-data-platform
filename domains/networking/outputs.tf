# ------------------------------------------------------------------------------
# Published contract of the networking context.
#
# `networks` is uniform. Security group ids are published separately and
# per-store, because AWS is the only provider that models them this way — Azure
# uses subnet-scoped private endpoints and GCP uses private service access.
# ------------------------------------------------------------------------------

output "networks" {
  description = "Uniform per-cloud fabric: id, cidr and the private subnets stores are placed in."
  value = merge(
    local.aws_enabled ? { aws = {
      id              = module.aws[0].vpc_id
      cidr            = module.aws[0].vpc_cidr
      private_subnets = module.aws[0].private_subnet_ids
    } } : {},
    local.azure_enabled ? { azure = {
      id   = module.azure[0].vnet_id
      cidr = var.address_space.azure
      private_subnets = [
        module.azure[0].cosmosdb_subnet_id,
        module.azure[0].synapse_subnet_id,
        module.azure[0].storage_subnet_id,
      ]
    } } : {},
    local.gcp_enabled ? { gcp = {
      id              = module.gcp[0].vpc_id
      cidr            = var.address_space.gcp
      private_subnets = [module.gcp[0].subnet_id]
    } } : {},
  )
}

output "aws_security_groups" {
  description = "Per-store security groups. AWS-specific: the other providers scope access by subnet and private endpoint instead."
  value = local.aws_enabled ? {
    operational_store   = module.aws[0].aurora_security_group_id
    analytics_warehouse = module.aws[0].redshift_security_group_id
    data_pipeline       = module.aws[0].glue_security_group_id
    stream_ingestion    = module.aws[0].msk_security_group_id
  } : null
}

output "azure_subnets" {
  description = "Azure subnets by purpose. Private endpoints are subnet-scoped, so consumers need the specific one."
  value = local.azure_enabled ? {
    operational_store   = module.azure[0].cosmosdb_subnet_id
    analytics_warehouse = module.azure[0].synapse_subnet_id
    data_lake           = module.azure[0].storage_subnet_id
    data_pipeline       = module.azure[0].data_factory_subnet_id
    private_endpoints   = module.azure[0].private_endpoints_subnet_id
  } : null
}

output "azure_resource_group_name" {
  description = "Resource group every Azure resource in this platform is placed into."
  value       = local.azure_enabled ? module.azure[0].resource_group_name : ""
}

output "gcp_network" {
  description = "GCP network handles. Cloud SQL private service access and Dataflow both address the network by id or self link rather than by name."
  value = local.gcp_enabled ? {
    id               = module.gcp[0].vpc_id
    self_link        = module.gcp[0].vpc_self_link
    subnet_self_link = module.gcp[0].subnet_self_link
    dataflow_subnet  = module.gcp[0].dataflow_subnet_self_link
    private_ip_range = module.gcp[0].private_ip_range_name
  } : null
}
