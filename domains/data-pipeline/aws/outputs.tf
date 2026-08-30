output "database_name" {
  description = "Glue catalog database name"
  value       = aws_glue_catalog_database.main.name
}

output "database_arn" {
  description = "Glue catalog database ARN"
  value       = aws_glue_catalog_database.main.arn
}

output "glue_role_arn" {
  description = "ARN of the Glue IAM role"
  value       = aws_iam_role.glue.arn
}

output "etl_job_name" {
  description = "Name of the raw-to-curated ETL job"
  value       = aws_glue_job.raw_to_curated.name
}

output "crawler_names" {
  description = "Map of crawler names by zone"
  value       = { for k, v in aws_glue_crawler.zones : k => v.name }
}

output "scripts_bucket_name" {
  description = "Name of the Glue scripts S3 bucket"
  value       = aws_s3_bucket.glue_scripts.id
}
