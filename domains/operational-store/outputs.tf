# ------------------------------------------------------------------------------
# Published contract of the operational-store context.
#
# Endpoints are published; credentials are not. Where a provider hands back a
# secret, the reference to it is published instead of the secret itself, so the
# value stays out of every consumer's state file.
# ------------------------------------------------------------------------------

output "endpoints" {
  description = "Connection endpoints per cloud. Read-only replicas are published separately where the provider offers them."
  value = merge(
    local.aws_enabled ? { aws = {
      writer   = module.aws[0].cluster_endpoint
      reader   = module.aws[0].reader_endpoint
      port     = module.aws[0].port
      database = module.aws[0].database_name
    } } : {},
    local.azure_enabled ? { azure = {
      writer   = module.azure[0].endpoint
      reader   = module.azure[0].endpoint
      port     = null
      database = module.azure[0].database_name
    } } : {},
    local.gcp_enabled ? { gcp = {
      writer   = module.gcp[0].private_ip
      reader   = module.gcp[0].private_ip
      port     = null
      database = module.gcp[0].database_name
    } } : {},
  )
}

output "credential_references" {
  description = <<-EOT
    Where each store's credentials live, never the credentials themselves.
    Publishing the secret would copy it into the state file of every consumer;
    publishing the reference means a consumer resolves it at run time under its
    own identity.
  EOT
  value = merge(
    local.aws_enabled ? { aws = module.aws[0].master_secret_arn } : {},
    local.gcp_enabled ? { gcp = "cloudsql-generated-see-secret-manager" } : {},
  )
}

output "gcp_connection_name" {
  description = "Cloud SQL connection name, which the proxy addresses instead of an IP."
  value       = local.gcp_enabled ? module.gcp[0].connection_name : null
}

output "encryption_keys" {
  description = "Customer-managed keys. Evidence for ISO 27001 A.8.24 and SOC 2 CC6.1."
  value       = local.aws_enabled ? { aws = module.aws[0].kms_key_arn } : {}
}
