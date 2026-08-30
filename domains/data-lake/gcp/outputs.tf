output "bucket_names" {
  description = "Map of zone name to bucket name"
  value       = { for k, v in google_storage_bucket.zones : k => v.name }
}

output "raw_bucket_name" {
  description = "Raw zone bucket name"
  value       = google_storage_bucket.zones["raw"].name
}

output "raw_bucket_url" {
  description = "Raw zone bucket URL"
  value       = google_storage_bucket.zones["raw"].url
}

output "curated_bucket_name" {
  description = "Curated zone bucket name"
  value       = google_storage_bucket.zones["curated"].name
}

output "curated_bucket_url" {
  description = "Curated zone bucket URL"
  value       = google_storage_bucket.zones["curated"].url
}

output "analytics_bucket_name" {
  description = "Analytics zone bucket name"
  value       = google_storage_bucket.zones["analytics"].name
}

output "analytics_bucket_url" {
  description = "Analytics zone bucket URL"
  value       = google_storage_bucket.zones["analytics"].url
}

output "kms_key_id" {
  description = "CMEK key ID for data lake encryption"
  value       = google_kms_crypto_key.data_lake.id
}
