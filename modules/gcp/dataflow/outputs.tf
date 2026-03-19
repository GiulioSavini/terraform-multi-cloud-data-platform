output "service_account_email" {
  description = "Dataflow service account email"
  value       = google_service_account.dataflow.email
}

output "service_account_id" {
  description = "Dataflow service account ID"
  value       = google_service_account.dataflow.id
}

output "temp_bucket" {
  description = "Dataflow temp bucket name"
  value       = google_storage_bucket.temp.name
}

output "staging_bucket" {
  description = "Dataflow staging bucket name"
  value       = google_storage_bucket.staging.name
}
