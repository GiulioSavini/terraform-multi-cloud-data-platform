locals {
  name_prefix = replace("${var.project}_${var.environment}", "-", "_")
}

resource "google_bigquery_dataset" "analytics" {
  dataset_id  = "${local.name_prefix}_analytics"
  project     = var.gcp_project_id
  location    = var.location
  description = "Analytics dataset for ${var.environment}"

  default_table_expiration_ms = var.default_expiration_ms > 0 ? var.default_expiration_ms : null

  labels = var.labels

  access {
    role          = "OWNER"
    special_group = "projectOwners"
  }

  access {
    role          = "READER"
    special_group = "projectReaders"
  }
}

resource "google_bigquery_dataset" "raw" {
  dataset_id  = "${local.name_prefix}_raw"
  project     = var.gcp_project_id
  location    = var.location
  description = "Raw ingestion dataset for ${var.environment}"
  labels      = var.labels
}

resource "google_bigquery_table" "events" {
  dataset_id          = google_bigquery_dataset.raw.dataset_id
  table_id            = "events"
  project             = var.gcp_project_id
  deletion_protection = var.environment == "prd"

  time_partitioning {
    type  = "DAY"
    field = "event_timestamp"
  }

  clustering = ["event_type", "source"]

  schema = jsonencode([
    { name = "event_id", type = "STRING", mode = "REQUIRED" },
    { name = "event_type", type = "STRING", mode = "REQUIRED" },
    { name = "event_timestamp", type = "TIMESTAMP", mode = "REQUIRED" },
    { name = "source", type = "STRING", mode = "REQUIRED" },
    { name = "payload", type = "JSON", mode = "NULLABLE" },
    { name = "metadata", type = "RECORD", mode = "NULLABLE", fields = [
      { name = "cloud", type = "STRING" },
      { name = "region", type = "STRING" },
      { name = "version", type = "STRING" }
    ]}
  ])

  labels = var.labels
}

resource "google_bigquery_table" "aggregated_metrics" {
  dataset_id          = google_bigquery_dataset.analytics.dataset_id
  table_id            = "aggregated_metrics"
  project             = var.gcp_project_id
  deletion_protection = var.environment == "prd"

  time_partitioning {
    type  = "DAY"
    field = "metric_date"
  }

  schema = jsonencode([
    { name = "metric_date", type = "DATE", mode = "REQUIRED" },
    { name = "metric_name", type = "STRING", mode = "REQUIRED" },
    { name = "source", type = "STRING", mode = "REQUIRED" },
    { name = "count", type = "INT64" },
    { name = "sum_value", type = "FLOAT64" },
    { name = "avg_value", type = "FLOAT64" },
    { name = "min_value", type = "FLOAT64" },
    { name = "max_value", type = "FLOAT64" }
  ])

  labels = var.labels
}

# Scheduled Query - Daily Aggregation
resource "google_bigquery_data_transfer_config" "daily_aggregation" {
  display_name   = "${var.project}-${var.environment}-daily-agg"
  project        = var.gcp_project_id
  location       = var.location
  data_source_id = "scheduled_query"
  schedule       = "every day 06:00"
  disabled       = var.environment == "dev"

  destination_dataset_id = google_bigquery_dataset.analytics.dataset_id

  params = {
    query = <<-SQL
      INSERT INTO `${var.gcp_project_id}.${google_bigquery_dataset.analytics.dataset_id}.aggregated_metrics`
      SELECT
        DATE(event_timestamp) as metric_date,
        event_type as metric_name,
        source,
        COUNT(*) as count,
        0 as sum_value, 0 as avg_value, 0 as min_value, 0 as max_value
      FROM `${var.gcp_project_id}.${google_bigquery_dataset.raw.dataset_id}.events`
      WHERE DATE(event_timestamp) = DATE_SUB(CURRENT_DATE(), INTERVAL 1 DAY)
      GROUP BY 1, 2, 3
    SQL
    destination_table_name_template = "aggregated_metrics"
    write_disposition               = "WRITE_APPEND"
  }
}
