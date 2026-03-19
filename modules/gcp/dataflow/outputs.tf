output "service_account_email" { value = google_service_account.dataflow.email }
output "temp_bucket" { value = google_storage_bucket.temp.name }
output "staging_bucket" { value = google_storage_bucket.staging.name }
