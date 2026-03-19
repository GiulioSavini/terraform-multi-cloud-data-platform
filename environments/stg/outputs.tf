# -----------------------------------------------------------------------------
# AWS Outputs
# -----------------------------------------------------------------------------

output "aws_vpc_id" {
  description = "AWS VPC ID"
  value       = module.aws_networking.vpc_id
}

output "aws_aurora_endpoint" {
  description = "Aurora cluster endpoint"
  value       = module.aws_aurora.cluster_endpoint
  sensitive   = true
}

output "aws_aurora_reader_endpoint" {
  description = "Aurora cluster reader endpoint"
  value       = module.aws_aurora.reader_endpoint
  sensitive   = true
}

output "aws_redshift_endpoint" {
  description = "Redshift cluster endpoint"
  value       = module.aws_redshift.endpoint
  sensitive   = true
}

output "aws_s3_raw_bucket" {
  description = "S3 raw data lake bucket name"
  value       = module.aws_data_lake.raw_bucket_name
}

output "aws_s3_curated_bucket" {
  description = "S3 curated data lake bucket name"
  value       = module.aws_data_lake.curated_bucket_name
}

output "aws_s3_analytics_bucket" {
  description = "S3 analytics data lake bucket name"
  value       = module.aws_data_lake.analytics_bucket_name
}

output "aws_glue_database_name" {
  description = "Glue catalog database name"
  value       = module.aws_glue.database_name
}

output "aws_msk_bootstrap_brokers" {
  description = "MSK bootstrap broker connection string (TLS)"
  value       = module.aws_msk.bootstrap_brokers_tls
  sensitive   = true
}

# -----------------------------------------------------------------------------
# Azure Outputs
# -----------------------------------------------------------------------------

output "azure_resource_group_name" {
  description = "Azure resource group name"
  value       = module.azure_networking.resource_group_name
}

output "azure_cosmosdb_endpoint" {
  description = "CosmosDB account endpoint"
  value       = module.azure_cosmosdb.endpoint
  sensitive   = true
}

output "azure_synapse_workspace_url" {
  description = "Synapse workspace development endpoint"
  value       = module.azure_synapse.connectivity_endpoints
}

output "azure_data_lake_endpoint" {
  description = "ADLS Gen2 primary DFS endpoint"
  value       = module.azure_data_lake.primary_dfs_endpoint
}

output "azure_data_factory_name" {
  description = "Azure Data Factory name"
  value       = module.azure_data_factory.name
}

output "azure_eventhubs_namespace" {
  description = "Event Hubs namespace name"
  value       = module.azure_kafka.namespace_name
}

# -----------------------------------------------------------------------------
# GCP Outputs
# -----------------------------------------------------------------------------

output "gcp_vpc_name" {
  description = "GCP VPC network name"
  value       = module.gcp_networking.vpc_name
}

output "gcp_cloudsql_connection_name" {
  description = "CloudSQL instance connection name"
  value       = module.gcp_cloudsql.connection_name
  sensitive   = true
}

output "gcp_cloudsql_private_ip" {
  description = "CloudSQL instance private IP"
  value       = module.gcp_cloudsql.private_ip
  sensitive   = true
}

output "gcp_bigquery_dataset_id" {
  description = "BigQuery dataset ID"
  value       = module.gcp_bigquery.dataset_id
}

output "gcp_gcs_raw_bucket" {
  description = "GCS raw data lake bucket name"
  value       = module.gcp_data_lake.raw_bucket_name
}

output "gcp_gcs_curated_bucket" {
  description = "GCS curated data lake bucket name"
  value       = module.gcp_data_lake.curated_bucket_name
}

output "gcp_gcs_analytics_bucket" {
  description = "GCS analytics data lake bucket name"
  value       = module.gcp_data_lake.analytics_bucket_name
}

output "gcp_pubsub_topics" {
  description = "Pub/Sub topic IDs"
  value       = module.gcp_kafka.topic_ids
}
