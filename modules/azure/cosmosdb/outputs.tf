output "account_id" { value = azurerm_cosmosdb_account.main.id }
output "endpoint" { value = azurerm_cosmosdb_account.main.endpoint }
output "primary_key" { value = azurerm_cosmosdb_account.main.primary_key; sensitive = true }
output "connection_strings" { value = azurerm_cosmosdb_account.main.connection_strings; sensitive = true }
output "database_name" { value = azurerm_cosmosdb_sql_database.main.name }
