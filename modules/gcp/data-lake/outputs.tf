output "bucket_names" { value = { for k, v in google_storage_bucket.zones : k => v.name } }
output "raw_bucket" { value = google_storage_bucket.zones["raw"].name }
output "curated_bucket" { value = google_storage_bucket.zones["curated"].name }
output "analytics_bucket" { value = google_storage_bucket.zones["analytics"].name }
