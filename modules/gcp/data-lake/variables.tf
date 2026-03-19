variable "project_name" {
  description = "Project name used as resource prefix"
  type        = string
}

variable "environment" {
  description = "Environment name (dev, stg, prd)"
  type        = string
}

variable "region" {
  description = "GCP region"
  type        = string
  default     = "europe-west1"
}

variable "nearline_age_days" {
  description = "Days before transitioning to Nearline storage"
  type        = number
  default     = 30
}

variable "coldline_age_days" {
  description = "Days before transitioning to Coldline storage"
  type        = number
  default     = 90
}

variable "labels" {
  description = "Labels for all resources"
  type        = map(string)
  default     = {}
}
