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

variable "network" {
  description = "VPC network name"
  type        = string
}

variable "subnetwork" {
  description = "Subnetwork self link for Dataflow workers"
  type        = string
}

variable "machine_type" {
  description = "Machine type for Dataflow workers"
  type        = string
  default     = "n1-standard-2"
}

variable "max_workers" {
  description = "Maximum number of Dataflow workers"
  type        = number
  default     = 3
}

variable "labels" {
  description = "Labels for all resources"
  type        = map(string)
  default     = {}
}
