# -----------------------------------------------------------------------------
# GCP BigQuery Module
# Datasets, tables with schema, scheduled queries, IAM, labels
# -----------------------------------------------------------------------------

locals {
  name_prefix = replace("${var.project_name}_${var.environment}", "-", "_")
  location    = "EU"
}

# -----------------------------------------------------------------------------
# Datasets
# -----------------------------------------------------------------------------

resource "google_bigquery_dataset" "analytics" {
  dataset_id  = "${local.name_prefix}_analytics"
  location    = local.location
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

  access {
    role          = "WRITER"
    special_group = "projectWriters"
  }
}

resource "google_bigquery_dataset" "raw" {
  dataset_id  = "${local.name_prefix}_raw"
  location    = local.location
  description = "Raw ingestion dataset for ${var.environment}"

  labels = var.labels

  access {
    role          = "OWNER"
    special_group = "projectOwners"
  }

  access {
    role          = "WRITER"
    special_group = "projectWriters"
  }
}

# -----------------------------------------------------------------------------
# Tables
# -----------------------------------------------------------------------------

resource "google_bigquery_table" "events" {
  dataset_id          = google_bigquery_dataset.raw.dataset_id
  table_id            = "events"
  deletion_protection = var.environment == "prd"
  description         = "Raw events ingestion table"

  time_partitioning {
    type  = "DAY"
    field = "event_timestamp"
  }

  clustering = ["event_type", "source"]

  schema = jsonencode([
    { name = "event_id", type = "STRING", mode = "REQUIRED", description = "Unique event identifier" },
    { name = "event_type", type = "STRING", mode = "REQUIRED", description = "Type of event" },
    { name = "event_timestamp", type = "TIMESTAMP", mode = "REQUIRED", description = "Event timestamp" },
    { name = "source", type = "STRING", mode = "REQUIRED", description = "Source cloud/system" },
    { name = "payload", type = "JSON", mode = "NULLABLE", description = "Event payload" },
    {
      name = "metadata", type = "RECORD", mode = "NULLABLE", description = "Event metadata",
      fields = [
        { name = "cloud", type = "STRING", description = "Cloud provider" },
        { name = "region", type = "STRING", description = "Cloud region" },
        { name = "version", type = "STRING", description = "Schema version" }
      ]
    }
  ])

  labels = var.labels
}

resource "google_bigquery_table" "aggregated_metrics" {
  dataset_id          = google_bigquery_dataset.analytics.dataset_id
  table_id            = "aggregated_metrics"
  deletion_protection = var.environment == "prd"
  description         = "Daily aggregated metrics"

  time_partitioning {
    type  = "DAY"
    field = "metric_date"
  }

  clustering = ["metric_name", "source"]

  schema = jsonencode([
    { name = "metric_date", type = "DATE", mode = "REQUIRED", description = "Aggregation date" },
    { name = "metric_name", type = "STRING", mode = "REQUIRED", description = "Metric name" },
    { name = "source", type = "STRING", mode = "REQUIRED", description = "Data source" },
    { name = "count", type = "INT64", mode = "NULLABLE", description = "Event count" },
    { name = "sum_value", type = "FLOAT64", mode = "NULLABLE", description = "Sum of values" },
    { name = "avg_value", type = "FLOAT64", mode = "NULLABLE", description = "Average value" },
    { name = "min_value", type = "FLOAT64", mode = "NULLABLE", description = "Minimum value" },
    { name = "max_value", type = "FLOAT64", mode = "NULLABLE", description = "Maximum value" }
  ])

  labels = var.labels
}

# -----------------------------------------------------------------------------
# Scheduled Query - Daily Aggregation
# -----------------------------------------------------------------------------

resource "google_bigquery_data_transfer_config" "daily_aggregation" {
  display_name   = "${var.project_name}-${var.environment}-daily-agg"
  location       = local.location
  data_source_id = "scheduled_query"
  schedule       = "every day 06:00"
  disabled       = var.environment == "dev"

  destination_dataset_id = google_bigquery_dataset.analytics.dataset_id

  params = {
    query = <<-SQL
      INSERT INTO `${google_bigquery_dataset.analytics.dataset_id}.aggregated_metrics`
      SELECT
        DATE(event_timestamp) as metric_date,
        event_type as metric_name,
        source,
        COUNT(*) as count,
        0 as sum_value,
        0 as avg_value,
        0 as min_value,
        0 as max_value
      FROM `${google_bigquery_dataset.raw.dataset_id}.events`
      WHERE DATE(event_timestamp) = DATE_SUB(CURRENT_DATE(), INTERVAL 1 DAY)
      GROUP BY 1, 2, 3
    SQL
    destination_table_name_template = "aggregated_metrics"
    write_disposition               = "WRITE_APPEND"
  }
}
