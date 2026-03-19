# GCP Pub/Sub (Kafka-compatible Messaging)

Terraform module to provision Google Cloud Pub/Sub topics and subscriptions as a Kafka-compatible messaging layer with configurable retention, dead-letter policies, and push/pull delivery.

## Usage

```hcl
module "kafka" {
  source = "./modules/gcp/kafka"

  project_id = var.gcp_project_id

  topics = {
    raw_events = {
      message_retention_duration = "604800s"
      schema                     = null
    }
    processed_events = {
      message_retention_duration = "259200s"
      schema                     = null
    }
  }

  subscriptions = {
    etl_processor = {
      topic                = "raw_events"
      ack_deadline_seconds = 60
      retain_acked_messages = false
      message_retention_duration = "604800s"
      enable_exactly_once_delivery = true
      dead_letter_topic           = "raw_events_dlq"
      max_delivery_attempts       = 5
    }
    analytics_consumer = {
      topic                = "processed_events"
      ack_deadline_seconds = 30
      retain_acked_messages = false
      message_retention_duration = "259200s"
      enable_exactly_once_delivery = false
      dead_letter_topic           = null
      max_delivery_attempts       = null
    }
  }

  labels = {
    project     = "data-platform"
    environment = "production"
    managed_by  = "terraform"
  }
}
```

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|----------|
| `project_id` | GCP project ID | `string` | n/a | yes |
| `topics` | Map of Pub/Sub topic configurations | `map(object)` | n/a | yes |
| `subscriptions` | Map of subscription configurations | `map(object)` | `{}` | no |
| `schema_definitions` | Map of schema definitions for topics | `map(object)` | `{}` | no |
| `labels` | Resource labels | `map(string)` | `{}` | no |

## Outputs

| Name | Description |
|------|-------------|
| `topic_ids` | Map of Pub/Sub topic IDs |
| `topic_names` | Map of Pub/Sub topic names |
| `subscription_ids` | Map of subscription IDs |
| `subscription_paths` | Map of subscription paths |
| `dead_letter_topic_ids` | Map of dead-letter topic IDs |
