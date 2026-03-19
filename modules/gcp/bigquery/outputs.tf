output "dataset_id" {
  description = "Analytics BigQuery dataset ID"
  value       = google_bigquery_dataset.analytics.dataset_id
}

output "analytics_dataset_id" {
  description = "Analytics dataset ID"
  value       = google_bigquery_dataset.analytics.dataset_id
}

output "raw_dataset_id" {
  description = "Raw dataset ID"
  value       = google_bigquery_dataset.raw.dataset_id
}

output "events_table_id" {
  description = "Events table ID"
  value       = google_bigquery_table.events.table_id
}

output "aggregated_metrics_table_id" {
  description = "Aggregated metrics table ID"
  value       = google_bigquery_table.aggregated_metrics.table_id
}
