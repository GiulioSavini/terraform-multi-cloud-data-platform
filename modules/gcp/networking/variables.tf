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

variable "vpc_cidr" {
  description = "Primary subnet CIDR range"
  type        = string
  default     = "10.2.0.0/16"
}
