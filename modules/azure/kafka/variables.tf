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

variable "capacity" {
  description = "Throughput units for the namespace"
  type        = number
  default     = 1

  validation {
    condition     = var.capacity >= 1 && var.capacity <= 40
    error_message = "Capacity must be between 1 and 40 throughput units."
  }
}

variable "partition_count" {
  description = "Number of partitions per event hub"
  type        = number
  default     = 4
}

variable "message_retention_days" {
  description = "Message retention in days"
  type        = number
  default     = 7
}

variable "storage_account_id" {
  description = "Storage account ID for Event Hub capture"
  type        = string
}

variable "tags" {
  description = "Common tags for all resources"
  type        = map(string)
  default     = {}
}
