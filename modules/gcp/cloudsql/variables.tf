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

variable "tier" {
  description = "CloudSQL machine tier"
  type        = string
  default     = "db-custom-2-8192"
}

variable "disk_size" {
  description = "Initial disk size in GB"
  type        = number
  default     = 20
}

variable "ha_enabled" {
  description = "Enable high availability (REGIONAL)"
  type        = bool
  default     = false
}

variable "backup_retention" {
  description = "Number of days to retain backups"
  type        = number
  default     = 7
}

variable "read_replicas" {
  description = "Number of read replicas"
  type        = number
  default     = 0
}

variable "network_id" {
  description = "VPC network ID for private IP"
  type        = string
}

variable "private_ip_range" {
  description = "Private IP range name for service networking"
  type        = string
}

variable "database_name" {
  description = "Name of the default database"
  type        = string
  default     = "dataplatform"
}
