output "warehouses" {
  description = "Query endpoint per cloud, in a uniform shape."
  value = merge(
    local.aws_enabled ? { aws = {
      id       = module.aws[0].cluster_id
      endpoint = module.aws[0].endpoint
      database = module.aws[0].database_name
    } } : {},
    local.azure_enabled ? { azure = {
      id       = module.azure[0].workspace_id
      endpoint = module.azure[0].connectivity_endpoints
      database = module.azure[0].sql_pool_id
    } } : {},
    local.gcp_enabled ? { gcp = {
      id       = module.gcp[0].dataset_id
      endpoint = null
      database = module.gcp[0].analytics_dataset_id
    } } : {},
  )
}

output "credential_references" {
  description = "Where warehouse credentials live. The value is never published."
  value       = local.aws_enabled ? { aws = module.aws[0].master_secret_arn } : {}
}

output "workload_identities" {
  description = "Identities the warehouses use to reach the lake."
  value = merge(
    local.aws_enabled ? { aws = module.aws[0].iam_role_arn } : {},
    local.azure_enabled ? { azure = module.azure[0].identity_principal_id } : {},
  )
}

output "azure_endpoints" {
  description = "Synapse connectivity endpoints, needed by the data-pipeline context."
  value       = local.azure_enabled ? module.azure[0].connectivity_endpoints : null
}
