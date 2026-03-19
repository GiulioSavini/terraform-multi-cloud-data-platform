variable "project_name" {
  description = "Project name used as resource prefix"
  type        = string
}

variable "environment" {
  description = "Environment name (dev, stg, prd)"
  type        = string
}

variable "location" {
  description = "Azure region"
  type        = string
}

variable "resource_group_name" {
  description = "Name of the resource group"
  type        = string
}

variable "storage_account_url" {
  description = "ADLS Gen2 primary DFS endpoint URL"
  type        = string
}

variable "cosmosdb_endpoint" {
  description = "CosmosDB account endpoint"
  type        = string
}

variable "synapse_endpoint" {
  description = "Synapse workspace connectivity endpoints"
  type        = map(string)
}

variable "tags" {
  description = "Common tags for all resources"
  type        = map(string)
  default     = {}
}
