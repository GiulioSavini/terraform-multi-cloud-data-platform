output "brokers" {
  description = "Bootstrap endpoint per cloud, in a uniform shape."
  value = merge(
    local.aws_enabled ? { aws = {
      id       = module.aws[0].cluster_arn
      name     = module.aws[0].cluster_name
      endpoint = module.aws[0].bootstrap_brokers_sasl_iam
    } } : {},
    local.azure_enabled ? { azure = {
      id       = module.azure[0].namespace_id
      name     = module.azure[0].namespace_name
      endpoint = module.azure[0].kafka_endpoint
    } } : {},
    local.gcp_enabled ? { gcp = {
      id       = module.gcp[0].events_topic_id
      name     = "pubsub"
      endpoint = null
    } } : {},
  )
  sensitive = true
}

output "gcp_topics" {
  description = "Pub/Sub topic ids. Pub/Sub has no broker endpoint — a topic is the addressable unit."
  value       = local.gcp_enabled ? module.gcp[0].topic_ids : null
}

output "dead_letter_topic" {
  description = "Where unprocessable messages land. A stream with no dead-letter destination drops them silently."
  value       = local.gcp_enabled ? module.gcp[0].dead_letter_topic_id : null
}

output "credential_references" {
  description = "Where broker credentials live. Values are never published."
  value = local.replication_enabled ? {
    eventhubs = module.cross_cloud[0].eventhubs_secret_arn
    msk       = module.cross_cloud[0].msk_secret_arn
  } : {}
}

output "cross_cloud_replication_enabled" {
  description = "Whether topics are mirrored between clouds."
  value       = local.replication_enabled
}

output "encryption_keys" {
  description = "Customer-managed keys protecting messages at rest."
  value       = local.aws_enabled ? { aws = module.aws[0].kms_key_arn } : {}
}
