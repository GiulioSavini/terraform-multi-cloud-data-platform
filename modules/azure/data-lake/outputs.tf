output "storage_account_id" { value = azurerm_storage_account.adls.id }
output "storage_account_name" { value = azurerm_storage_account.adls.name }
output "primary_dfs_endpoint" { value = azurerm_storage_account.adls.primary_dfs_endpoint }
output "raw_filesystem_id" { value = azurerm_storage_data_lake_gen2_filesystem.raw.id }
output "curated_filesystem_id" { value = azurerm_storage_data_lake_gen2_filesystem.curated.id }
output "analytics_filesystem_id" { value = azurerm_storage_data_lake_gen2_filesystem.analytics.id }
