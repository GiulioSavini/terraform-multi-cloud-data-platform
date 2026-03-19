output "cluster_id" {
  description = "Aurora cluster ID"
  value       = aws_rds_cluster.main.id
}

output "cluster_arn" {
  description = "Aurora cluster ARN"
  value       = aws_rds_cluster.main.arn
}

output "cluster_endpoint" {
  description = "Aurora cluster writer endpoint"
  value       = aws_rds_cluster.main.endpoint
}

output "reader_endpoint" {
  description = "Aurora cluster reader endpoint"
  value       = aws_rds_cluster.main.reader_endpoint
}

output "port" {
  description = "Aurora cluster port"
  value       = aws_rds_cluster.main.port
}

output "database_name" {
  description = "Name of the default database"
  value       = aws_rds_cluster.main.database_name
}

output "master_secret_arn" {
  description = "ARN of the Secrets Manager secret containing master credentials"
  value       = aws_secretsmanager_secret.aurora.arn
}

output "kms_key_arn" {
  description = "ARN of the KMS key used for encryption"
  value       = aws_kms_key.aurora.arn
}
