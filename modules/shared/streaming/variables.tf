variable "project_name" {
  description = "Project name used as resource prefix"
  type        = string
}

variable "environment" {
  description = "Environment name (dev, stg, prd)"
  type        = string
}

variable "msk_cluster_arn" {
  description = "ARN of the MSK cluster"
  type        = string
}

variable "msk_bootstrap_brokers" {
  description = "MSK TLS bootstrap broker connection string"
  type        = string
  sensitive   = true
}

variable "eventhubs_namespace" {
  description = "Azure Event Hubs namespace name"
  type        = string
}

variable "eventhubs_connection_string" {
  description = "Azure Event Hubs primary connection string"
  type        = string
  sensitive   = true
}

variable "pubsub_topics" {
  description = "Map of GCP Pub/Sub topic IDs"
  type        = map(string)
}

variable "tags" {
  description = "Common tags for all resources"
  type        = map(string)
  default     = {}
}
