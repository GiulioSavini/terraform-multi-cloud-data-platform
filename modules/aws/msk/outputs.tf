output "cluster_arn" {
  description = "MSK cluster ARN"
  value       = aws_msk_cluster.main.arn
}

output "cluster_name" {
  description = "MSK cluster name"
  value       = aws_msk_cluster.main.cluster_name
}

output "bootstrap_brokers_tls" {
  description = "TLS bootstrap broker connection string"
  value       = aws_msk_cluster.main.bootstrap_brokers_tls
}

output "bootstrap_brokers_sasl_iam" {
  description = "SASL/IAM bootstrap broker connection string"
  value       = aws_msk_cluster.main.bootstrap_brokers_sasl_iam
}

output "zookeeper_connect_string" {
  description = "ZooKeeper connection string"
  value       = aws_msk_cluster.main.zookeeper_connect_string
}

output "kms_key_arn" {
  description = "ARN of the KMS key used for MSK encryption"
  value       = aws_kms_key.msk.arn
}
