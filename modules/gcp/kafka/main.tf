locals {
  name_prefix = "${var.project}-${var.environment}"
}

resource "google_pubsub_topic" "events" {
  name    = "${local.name_prefix}-events"
  project = var.gcp_project_id

  message_retention_duration = var.message_retention

  schema_settings {
    encoding = "JSON"
  }

  labels = var.labels
}

resource "google_pubsub_topic" "metrics" {
  name    = "${local.name_prefix}-metrics"
  project = var.gcp_project_id

  message_retention_duration = var.message_retention
  labels                     = var.labels
}

resource "google_pubsub_topic" "dead_letter" {
  name    = "${local.name_prefix}-dead-letter"
  project = var.gcp_project_id
  labels  = var.labels
}

resource "google_pubsub_subscription" "events_pull" {
  name    = "${local.name_prefix}-events-pull"
  project = var.gcp_project_id
  topic   = google_pubsub_topic.events.name

  ack_deadline_seconds       = 20
  message_retention_duration = "604800s"

  retry_policy {
    minimum_backoff = "10s"
    maximum_backoff = "600s"
  }

  dead_letter_policy {
    dead_letter_topic     = google_pubsub_topic.dead_letter.id
    max_delivery_attempts = 5
  }

  labels = var.labels
}

resource "google_pubsub_subscription" "events_bq" {
  count = var.bq_dataset_id != "" ? 1 : 0

  name    = "${local.name_prefix}-events-bq"
  project = var.gcp_project_id
  topic   = google_pubsub_topic.events.name

  bigquery_config {
    table            = "${var.gcp_project_id}.${var.bq_dataset_id}.events"
    write_metadata   = true
    use_topic_schema = false
  }

  labels = var.labels
}

resource "google_pubsub_subscription" "metrics_pull" {
  name    = "${local.name_prefix}-metrics-pull"
  project = var.gcp_project_id
  topic   = google_pubsub_topic.metrics.name

  ack_deadline_seconds = 20

  labels = var.labels
}
