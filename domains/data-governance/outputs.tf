output "catalog" {
  description = "The cross-cloud data catalog."
  value = {
    purview_id       = module.cross_cloud.purview_id
    purview_endpoint = module.cross_cloud.purview_endpoint
    glue_database    = module.cross_cloud.glue_governance_database
  }
}

output "governance_identities" {
  description = "Identities the catalog scans under. Read-only by design: a catalog that can write is a catalog that can destroy what it indexes."
  value = {
    aws   = module.cross_cloud.aws_governance_role_arn
    azure = module.cross_cloud.purview_identity_principal_id
    gcp   = module.cross_cloud.gcp_governance_sa_email
  }
}

output "encryption_keys" {
  description = "Governance-owned customer-managed keys. Evidence for ISO 27001 A.8.24 and SOC 2 CC6.1."
  value = {
    aws = module.cross_cloud.aws_kms_key_arn
    gcp = module.cross_cloud.gcp_kms_key_id
  }
}
