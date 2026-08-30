output "catalogs" {
  description = "Metadata catalog per cloud, where the platform records what the lake contains."
  value       = local.aws_enabled ? { aws = module.aws[0].database_name } : {}
}

output "pipeline_identities" {
  description = "Identities the pipelines run as. These are the only identities with write access to the raw and curated zones."
  value = merge(
    local.aws_enabled ? { aws = module.aws[0].glue_role_arn } : {},
    local.azure_enabled ? { azure = module.azure[0].identity_principal_id } : {},
    local.gcp_enabled ? { gcp = module.gcp[0].service_account_email } : {},
  )
}

output "jobs" {
  description = "Named jobs and crawlers, for an orchestrator to trigger."
  value = local.aws_enabled ? {
    etl_job  = module.aws[0].etl_job_name
    crawlers = module.aws[0].crawler_names
  } : {}
}

output "gcp_buckets" {
  description = "Dataflow's temp and staging buckets. Operational scratch space, deliberately not lake zones."
  value = local.gcp_enabled ? {
    temp    = module.gcp[0].temp_bucket
    staging = module.gcp[0].staging_bucket
  } : null
}
