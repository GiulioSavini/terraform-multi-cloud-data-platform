variable "project_name" {
  description = "Project name used as resource prefix"
  type        = string
}

variable "environment" {
  description = "Environment name (dev, stg, prd)"
  type        = string
}

variable "region" {
  description = "GCP region (used as BigQuery location)"
  type        = string
  default     = "europe-west1"
}

variable "default_expiration_ms" {
  description = "Default table expiration in milliseconds (0 = no expiration)"
  type        = number
  default     = 0
}

variable "labels" {
  description = "Labels for all resources"
  type        = map(string)
  default     = {}
}
