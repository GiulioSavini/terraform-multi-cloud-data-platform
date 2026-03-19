output "resource_group_name" {
  description = "Name of the resource group"
  value       = azurerm_resource_group.main.name
}

output "resource_group_id" {
  description = "ID of the resource group"
  value       = azurerm_resource_group.main.id
}

output "vnet_id" {
  description = "VNet ID"
  value       = azurerm_virtual_network.main.id
}

output "vnet_name" {
  description = "VNet name"
  value       = azurerm_virtual_network.main.name
}

output "cosmosdb_subnet_id" {
  description = "Subnet ID for CosmosDB"
  value       = azurerm_subnet.cosmosdb.id
}

output "synapse_subnet_id" {
  description = "Subnet ID for Synapse"
  value       = azurerm_subnet.synapse.id
}

output "storage_subnet_id" {
  description = "Subnet ID for Storage"
  value       = azurerm_subnet.storage.id
}

output "data_factory_subnet_id" {
  description = "Subnet ID for Data Factory"
  value       = azurerm_subnet.data_factory.id
}

output "private_endpoints_subnet_id" {
  description = "Subnet ID for Private Endpoints"
  value       = azurerm_subnet.private_endpoints.id
}

output "eventhubs_subnet_id" {
  description = "Subnet ID for Event Hubs"
  value       = azurerm_subnet.eventhubs.id
}

output "cosmos_dns_zone_id" {
  description = "Private DNS zone ID for CosmosDB"
  value       = azurerm_private_dns_zone.cosmos.id
}

output "synapse_dns_zone_id" {
  description = "Private DNS zone ID for Synapse"
  value       = azurerm_private_dns_zone.synapse.id
}

output "storage_blob_dns_zone_id" {
  description = "Private DNS zone ID for Blob Storage"
  value       = azurerm_private_dns_zone.storage_blob.id
}

output "storage_dfs_dns_zone_id" {
  description = "Private DNS zone ID for DFS Storage"
  value       = azurerm_private_dns_zone.storage_dfs.id
}
