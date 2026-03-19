variable "project_name" {
  description = "Project name used as resource prefix"
  type        = string
}

variable "environment" {
  description = "Environment name (dev, stg, prd)"
  type        = string
}

variable "azure_region" {
  description = "Azure region"
  type        = string
}

variable "azure_resource_group_name" {
  description = "Azure resource group name"
  type        = string
}

variable "gcp_region" {
  description = "GCP region"
  type        = string
}

variable "gcp_project_id" {
  description = "GCP project ID"
  type        = string
}

variable "tags" {
  description = "Common tags for all resources"
  type        = map(string)
  default     = {}
}
