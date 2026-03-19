output "cluster_id" {
  description = "Redshift cluster ID"
  value       = aws_redshift_cluster.main.id
}

output "cluster_arn" {
  description = "Redshift cluster ARN"
  value       = aws_redshift_cluster.main.arn
}

output "endpoint" {
  description = "Redshift cluster endpoint"
  value       = aws_redshift_cluster.main.endpoint
}

output "dns_name" {
  description = "Redshift cluster DNS name"
  value       = aws_redshift_cluster.main.dns_name
}

output "port" {
  description = "Redshift cluster port"
  value       = aws_redshift_cluster.main.port
}

output "database_name" {
  description = "Redshift default database name"
  value       = aws_redshift_cluster.main.database_name
}

output "iam_role_arn" {
  description = "ARN of the IAM role attached to Redshift for S3/Spectrum access"
  value       = aws_iam_role.redshift.arn
}

output "master_secret_arn" {
  description = "ARN of the Secrets Manager secret containing master credentials"
  value       = aws_secretsmanager_secret.redshift.arn
}
