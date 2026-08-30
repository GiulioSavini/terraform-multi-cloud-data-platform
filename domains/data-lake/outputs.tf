# ------------------------------------------------------------------------------
# Published contract of the data-lake context.
#
# The zone vocabulary (raw, curated, analytics) is the contract. Consumers ask
# for a zone; they never construct a bucket or container name themselves.
# ------------------------------------------------------------------------------

output "zones" {
  description = "Storage zone identifiers per cloud, keyed by zone rather than by provider-specific name."
  value = merge(
    local.aws_enabled ? { aws = {
      raw       = module.aws[0].raw_bucket_name
      curated   = module.aws[0].curated_bucket_name
      analytics = module.aws[0].analytics_bucket_name
    } } : {},
    local.azure_enabled ? { azure = {
      raw       = module.azure[0].raw_container_id
      curated   = module.azure[0].curated_container_id
      analytics = module.azure[0].analytics_container_id
    } } : {},
    local.gcp_enabled ? { gcp = {
      raw       = module.gcp[0].raw_bucket_name
      curated   = module.gcp[0].curated_bucket_name
      analytics = module.gcp[0].analytics_bucket_name
    } } : {},
  )
}

output "aws_zone_arns" {
  description = "ARNs of the AWS zones, needed to grant a pipeline access to one."
  value = local.aws_enabled ? {
    raw       = module.aws[0].raw_bucket_arn
    curated   = module.aws[0].curated_bucket_arn
    analytics = module.aws[0].analytics_bucket_arn
  } : null
}

output "encryption_keys" {
  description = "Customer-managed keys protecting each lake. Evidence for CIS 2.1.1, ISO 27001 A.8.24 and SOC 2 CC6.1."
  value = merge(
    local.aws_enabled ? { aws = module.aws[0].kms_key_arn } : {},
    local.gcp_enabled ? { gcp = module.gcp[0].kms_key_id } : {},
  )
}

output "azure_storage" {
  description = "Azure storage account handles. Synapse and Data Factory address the account rather than a container."
  value = local.azure_enabled ? {
    account_id    = module.azure[0].storage_account_id
    account_name  = module.azure[0].storage_account_name
    dfs_endpoint  = module.azure[0].primary_dfs_endpoint
    filesystem_id = module.azure[0].raw_container_id
    identity      = module.azure[0].identity_principal_id
  } : null
}
