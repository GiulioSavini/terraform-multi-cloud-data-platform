output "account_id" {
  description = "CosmosDB account ID"
  value       = azurerm_cosmosdb_account.main.id
}

output "account_name" {
  description = "CosmosDB account name"
  value       = azurerm_cosmosdb_account.main.name
}

output "endpoint" {
  description = "CosmosDB account endpoint"
  value       = azurerm_cosmosdb_account.main.endpoint
}

output "primary_key" {
  description = "CosmosDB primary key"
  value       = azurerm_cosmosdb_account.main.primary_key
  sensitive   = true
}

output "connection_strings" {
  description = "CosmosDB connection strings"
  value       = azurerm_cosmosdb_account.main.connection_strings
  sensitive   = true
}

output "database_name" {
  description = "CosmosDB SQL database name"
  value       = azurerm_cosmosdb_sql_database.main.name
}
