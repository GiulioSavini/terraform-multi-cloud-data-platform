output "msk_connect_role_arn" {
  description = "ARN of the MSK Connect IAM role"
  value       = aws_iam_role.msk_connect.arn
}

output "connector_plugins_bucket" {
  description = "S3 bucket name for connector plugins"
  value       = aws_s3_bucket.connector_plugins.id
}

output "connector_offsets_bucket" {
  description = "S3 bucket name for connector offsets"
  value       = aws_s3_bucket.connector_offsets.id
}

output "eventhubs_secret_arn" {
  description = "ARN of the Secrets Manager secret for Event Hubs connection"
  value       = aws_secretsmanager_secret.eventhubs_connection.arn
}

output "msk_secret_arn" {
  description = "ARN of the Secrets Manager secret for MSK connection"
  value       = aws_secretsmanager_secret.msk_connection.arn
}

output "log_group_name" {
  description = "CloudWatch log group name for MSK Connect"
  value       = aws_cloudwatch_log_group.msk_connect.name
}
