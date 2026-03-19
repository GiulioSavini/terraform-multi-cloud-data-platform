output "namespace_id" {
  description = "Event Hubs namespace ID"
  value       = azurerm_eventhub_namespace.main.id
}

output "namespace_name" {
  description = "Event Hubs namespace name"
  value       = azurerm_eventhub_namespace.main.name
}

output "kafka_endpoint" {
  description = "Kafka-compatible endpoint"
  value       = "${azurerm_eventhub_namespace.main.name}.servicebus.windows.net:9093"
}

output "primary_connection_string" {
  description = "Primary connection string for the namespace"
  value       = azurerm_eventhub_namespace.main.default_primary_connection_string
  sensitive   = true
}

output "send_connection_string" {
  description = "Send-only connection string"
  value       = azurerm_eventhub_namespace_authorization_rule.send.primary_connection_string
  sensitive   = true
}

output "listen_connection_string" {
  description = "Listen-only connection string"
  value       = azurerm_eventhub_namespace_authorization_rule.listen.primary_connection_string
  sensitive   = true
}
