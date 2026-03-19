output "workspace_id" {
  description = "Synapse workspace ID"
  value       = azurerm_synapse_workspace.main.id
}

output "workspace_name" {
  description = "Synapse workspace name"
  value       = azurerm_synapse_workspace.main.name
}

output "connectivity_endpoints" {
  description = "Synapse connectivity endpoints"
  value       = azurerm_synapse_workspace.main.connectivity_endpoints
}

output "sql_pool_id" {
  description = "Dedicated SQL pool ID"
  value       = azurerm_synapse_sql_pool.main.id
}

output "spark_pool_id" {
  description = "Spark pool ID"
  value       = azurerm_synapse_spark_pool.main.id
}

output "identity_principal_id" {
  description = "Synapse managed identity principal ID"
  value       = azurerm_synapse_workspace.main.identity[0].principal_id
}

output "identity_tenant_id" {
  description = "Synapse managed identity tenant ID"
  value       = azurerm_synapse_workspace.main.identity[0].tenant_id
}
