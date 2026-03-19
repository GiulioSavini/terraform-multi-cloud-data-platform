output "raw_bucket_name" {
  description = "Name of the raw zone S3 bucket"
  value       = aws_s3_bucket.zones["raw"].id
}

output "raw_bucket_arn" {
  description = "ARN of the raw zone S3 bucket"
  value       = aws_s3_bucket.zones["raw"].arn
}

output "curated_bucket_name" {
  description = "Name of the curated zone S3 bucket"
  value       = aws_s3_bucket.zones["curated"].id
}

output "curated_bucket_arn" {
  description = "ARN of the curated zone S3 bucket"
  value       = aws_s3_bucket.zones["curated"].arn
}

output "analytics_bucket_name" {
  description = "Name of the analytics zone S3 bucket"
  value       = aws_s3_bucket.zones["analytics"].id
}

output "analytics_bucket_arn" {
  description = "ARN of the analytics zone S3 bucket"
  value       = aws_s3_bucket.zones["analytics"].arn
}

output "kms_key_arn" {
  description = "ARN of the KMS key used for data lake encryption"
  value       = aws_kms_key.data_lake.arn
}

output "kms_key_id" {
  description = "ID of the KMS key used for data lake encryption"
  value       = aws_kms_key.data_lake.key_id
}
