# Cross-Cloud Streaming

Terraform module to provision cross-cloud streaming infrastructure including MSK Connect connectors for data replication between AWS MSK, Azure Event Hubs, and GCP Pub/Sub.

## Usage

```hcl
module "streaming" {
  source = "./modules/shared/streaming"

  project_name = "data-platform"
  environment  = "production"

  # MSK Connect
  msk_connect = {
    enabled            = true
    cluster_arn        = module.msk.cluster_arn
    bootstrap_servers  = module.msk.bootstrap_brokers_tls

    connectors = {
      azure_sink = {
        connector_class = "io.confluent.connect.azure.eventhubs.EventHubsSinkConnector"
        tasks_max       = 2
        config = {
          "azure.eventhubs.connection.string" = var.eventhubs_connection_string
          "azure.eventhubs.hub.name"          = "raw_events"
          "topics"                            = "raw-events"
        }
      }
      gcp_sink = {
        connector_class = "com.google.pubsub.kafka.sink.CloudPubSubSinkConnector"
        tasks_max       = 2
        config = {
          "cps.project" = var.gcp_project_id
          "cps.topic"   = "raw_events"
          "topics"      = "raw-events"
        }
      }
    }
  }

  # Service accounts and IAM
  service_account_roles = {
    aws = ["arn:aws:iam::policy/AmazonMSKFullAccess"]
    gcp = ["roles/pubsub.publisher", "roles/pubsub.subscriber"]
  }

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
| `project_name` | Name of the project | `string` | n/a | yes |
| `environment` | Environment name | `string` | n/a | yes |
| `msk_connect` | MSK Connect configuration with connectors | `object` | `{ enabled = false }` | no |
| `service_account_roles` | IAM roles for cross-cloud service accounts | `map(list(string))` | `{}` | no |
| `connector_plugins` | Custom connector plugin configurations | `map(object)` | `{}` | no |
| `log_delivery` | Log delivery configuration for connectors | `object` | `null` | no |
| `tags` | Resource tags | `map(string)` | `{}` | no |

## Outputs

| Name | Description |
|------|-------------|
| `msk_connect_connector_arns` | Map of MSK Connect connector ARNs |
| `msk_connect_connector_names` | Map of MSK Connect connector names |
| `connector_plugin_arns` | Map of custom connector plugin ARNs |
| `service_account_arns` | Map of service account ARNs/IDs per cloud |
| `replication_status` | Status of cross-cloud replication connectors |
