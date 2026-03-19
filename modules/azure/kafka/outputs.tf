output "namespace_id" { value = azurerm_eventhub_namespace.main.id }
output "namespace_name" { value = azurerm_eventhub_namespace.main.name }
output "kafka_endpoint" { value = "${azurerm_eventhub_namespace.main.name}.servicebus.windows.net:9093" }
