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

variable "message_retention" {
  description = "Message retention duration for topics"
  type        = string
  default     = "604800s"
}

variable "labels" {
  description = "Labels for all resources"
  type        = map(string)
  default     = {}
}
