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

# The aggregate `connection_strings` attribute was removed in azurerm 4.x in
# favour of per-protocol attributes. Only the SQL one is exposed here: the
# Mongo and Cassandra strings are meaningless unless the matching capability is
# enabled, and publishing them unconditionally would put four secrets in state
# where one is needed.
output "primary_sql_connection_string" {
  description = "CosmosDB SQL connection string. Prefer the endpoint plus a managed identity; this exists for clients that cannot use one."
  value       = azurerm_cosmosdb_account.main.primary_sql_connection_string
  sensitive   = true
}

output "database_name" {
  description = "CosmosDB SQL database name"
  value       = azurerm_cosmosdb_sql_database.main.name
}
