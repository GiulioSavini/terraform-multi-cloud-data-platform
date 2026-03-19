output "aws_kms_key_arn" {
  description = "AWS KMS key ARN for column-level encryption"
  value       = aws_kms_key.data_encryption.arn
}

output "aws_kms_key_id" {
  description = "AWS KMS key ID"
  value       = aws_kms_key.data_encryption.key_id
}

output "aws_governance_role_arn" {
  description = "AWS IAM role ARN for cross-cloud governance"
  value       = aws_iam_role.cross_cloud_governance.arn
}

output "gcp_kms_key_id" {
  description = "GCP KMS crypto key ID for column-level encryption"
  value       = google_kms_crypto_key.data_encryption.id
}

output "gcp_governance_sa_email" {
  description = "GCP governance service account email"
  value       = google_service_account.governance.email
}

output "purview_id" {
  description = "Azure Purview account ID"
  value       = azurerm_purview_account.main.id
}

output "purview_endpoint" {
  description = "Azure Purview catalog endpoint"
  value       = azurerm_purview_account.main.catalog_endpoint
}

output "purview_identity_principal_id" {
  description = "Azure Purview managed identity principal ID"
  value       = azurerm_purview_account.main.identity[0].principal_id
}

output "glue_governance_database" {
  description = "AWS Glue governance catalog database name"
  value       = aws_glue_catalog_database.governance.name
}
