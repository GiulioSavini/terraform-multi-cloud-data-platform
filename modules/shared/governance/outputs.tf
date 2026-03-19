output "aws_kms_key_arn" { value = aws_kms_key.data_encryption.arn }
output "gcp_kms_key_id" { value = google_kms_crypto_key.data_encryption.id }
output "purview_id" { value = azurerm_purview_account.main.id }
output "purview_endpoint" { value = azurerm_purview_account.main.catalog_endpoint }
