# Azure Event Hubs with Kafka Protocol

Terraform module to provision Azure Event Hubs with Kafka protocol support, providing a managed Kafka-compatible messaging layer with configurable throughput units and consumer groups.

## Usage

```hcl
module "kafka" {
  source = "./modules/azure/kafka"

  namespace_name      = "data-platform-eventhubs"
  resource_group_name = module.networking.resource_group_name
  location            = "eastus"

  sku      = "Standard"
  capacity = 2

  kafka_enabled = true

  event_hubs = {
    raw_events = {
      partition_count   = 8
      message_retention = 7
      consumer_groups   = ["etl-processor", "analytics-consumer"]
    }
    processed_events = {
      partition_count   = 4
      message_retention = 3
      consumer_groups   = ["downstream-consumer"]
    }
  }

  enable_private_endpoint = true
  subnet_id               = module.networking.private_subnet_id

  tags = {
    project     = "data-platform"
    environment = "production"
    managed_by  = "terraform"
  }
}
```

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|----------|
| `namespace_name` | Name of the Event Hubs namespace | `string` | n/a | yes |
| `resource_group_name` | Resource group name | `string` | n/a | yes |
| `location` | Azure region | `string` | n/a | yes |
| `sku` | Pricing tier (`Basic`, `Standard`, `Premium`) | `string` | `"Standard"` | no |
| `capacity` | Throughput units | `number` | `2` | no |
| `kafka_enabled` | Enable Kafka protocol support | `bool` | `true` | no |
| `event_hubs` | Map of Event Hub configurations | `map(object)` | `{}` | no |
| `enable_private_endpoint` | Enable private endpoint | `bool` | `true` | no |
| `subnet_id` | Subnet ID for private endpoint | `string` | `null` | no |
| `tags` | Resource tags | `map(string)` | `{}` | no |

## Outputs

| Name | Description |
|------|-------------|
| `namespace_id` | ID of the Event Hubs namespace |
| `namespace_name` | Name of the Event Hubs namespace |
| `kafka_endpoint` | Kafka-compatible endpoint |
| `event_hub_ids` | Map of Event Hub IDs |
| `primary_connection_string` | Primary connection string for the namespace |
