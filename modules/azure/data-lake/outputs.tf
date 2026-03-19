output "storage_account_id" {
  description = "Storage account ID"
  value       = azurerm_storage_account.adls.id
}

output "storage_account_name" {
  description = "Storage account name"
  value       = azurerm_storage_account.adls.name
}

output "primary_dfs_endpoint" {
  description = "Primary DFS endpoint URL"
  value       = azurerm_storage_account.adls.primary_dfs_endpoint
}

output "primary_blob_endpoint" {
  description = "Primary blob endpoint URL"
  value       = azurerm_storage_account.adls.primary_blob_endpoint
}

output "raw_container_id" {
  description = "Raw filesystem/container ID"
  value       = azurerm_storage_data_lake_gen2_filesystem.raw.id
}

output "curated_container_id" {
  description = "Curated filesystem/container ID"
  value       = azurerm_storage_data_lake_gen2_filesystem.curated.id
}

output "analytics_container_id" {
  description = "Analytics filesystem/container ID"
  value       = azurerm_storage_data_lake_gen2_filesystem.analytics.id
}

output "identity_principal_id" {
  description = "Storage account managed identity principal ID"
  value       = azurerm_storage_account.adls.identity[0].principal_id
}
