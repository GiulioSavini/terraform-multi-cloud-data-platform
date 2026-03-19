output "analytics_dataset_id" { value = google_bigquery_dataset.analytics.dataset_id }
output "raw_dataset_id" { value = google_bigquery_dataset.raw.dataset_id }
output "events_table_id" { value = google_bigquery_table.events.table_id }
