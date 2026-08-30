# -----------------------------------------------------------------------------
# GCP Pub/Sub Module (Kafka alternative)
# Topics, subscriptions, dead letter, BigQuery subscription, retention
# -----------------------------------------------------------------------------

locals {
  name_prefix = "${var.project_name}-${var.environment}"
}

# -----------------------------------------------------------------------------
# Topics
# -----------------------------------------------------------------------------

resource "google_pubsub_topic" "events" {
  name = "${local.name_prefix}-events"

  message_retention_duration = var.message_retention

  message_storage_policy {
    allowed_persistence_regions = [var.region]
  }

  labels = merge(var.labels, {
    topic = "events"
  })
}

resource "google_pubsub_topic" "metrics" {
  name = "${local.name_prefix}-metrics"

  message_retention_duration = var.message_retention

  message_storage_policy {
    allowed_persistence_regions = [var.region]
  }

  labels = merge(var.labels, {
    topic = "metrics"
  })
}

resource "google_pubsub_topic" "commands" {
  name = "${local.name_prefix}-commands"

  message_retention_duration = var.message_retention

  message_storage_policy {
    allowed_persistence_regions = [var.region]
  }

  labels = merge(var.labels, {
    topic = "commands"
  })
}

# -----------------------------------------------------------------------------
# Dead Letter Topic
# -----------------------------------------------------------------------------

resource "google_pubsub_topic" "dead_letter" {
  name = "${local.name_prefix}-dead-letter"

  message_retention_duration = "2592000s" # 30 days

  message_storage_policy {
    allowed_persistence_regions = [var.region]
  }

  labels = merge(var.labels, {
    topic = "dead-letter"
  })
}

resource "google_pubsub_subscription" "dead_letter" {
  name  = "${local.name_prefix}-dead-letter-sub"
  topic = google_pubsub_topic.dead_letter.name

  message_retention_duration = "2592000s"
  ack_deadline_seconds       = 60

  expiration_policy {
    ttl = ""
  }

  labels = var.labels
}

# -----------------------------------------------------------------------------
# Subscriptions
# -----------------------------------------------------------------------------

resource "google_pubsub_subscription" "events_pull" {
  name  = "${local.name_prefix}-events-pull"
  topic = google_pubsub_topic.events.name

  ack_deadline_seconds       = 20
  message_retention_duration = "604800s"
  retain_acked_messages      = false

  retry_policy {
    minimum_backoff = "10s"
    maximum_backoff = "600s"
  }

  dead_letter_policy {
    dead_letter_topic     = google_pubsub_topic.dead_letter.id
    max_delivery_attempts = 5
  }

  expiration_policy {
    ttl = ""
  }

  labels = var.labels
}

resource "google_pubsub_subscription" "events_streaming" {
  name  = "${local.name_prefix}-events-streaming"
  topic = google_pubsub_topic.events.name

  ack_deadline_seconds       = 10
  message_retention_duration = "86400s"

  retry_policy {
    minimum_backoff = "5s"
    maximum_backoff = "300s"
  }

  expiration_policy {
    ttl = ""
  }

  labels = var.labels
}

resource "google_pubsub_subscription" "metrics_pull" {
  name  = "${local.name_prefix}-metrics-pull"
  topic = google_pubsub_topic.metrics.name

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

  expiration_policy {
    ttl = ""
  }

  labels = var.labels
}
