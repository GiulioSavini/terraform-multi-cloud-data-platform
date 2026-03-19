output "workspace_id" { value = azurerm_synapse_workspace.main.id }
output "workspace_name" { value = azurerm_synapse_workspace.main.name }
output "sql_pool_id" { value = azurerm_synapse_sql_pool.main.id }
output "identity_principal_id" { value = azurerm_synapse_workspace.main.identity[0].principal_id }
