output "id" {
  description = "Data Factory ID"
  value       = azurerm_data_factory.main.id
}

output "name" {
  description = "Data Factory name"
  value       = azurerm_data_factory.main.name
}

output "identity_principal_id" {
  description = "Data Factory managed identity principal ID"
  value       = azurerm_data_factory.main.identity[0].principal_id
}

output "identity_tenant_id" {
  description = "Data Factory managed identity tenant ID"
  value       = azurerm_data_factory.main.identity[0].tenant_id
}
