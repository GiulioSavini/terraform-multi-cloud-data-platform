variable "landing_zone" {
  description = "Platform identifier."
  type        = string
}

variable "environment" {
  description = "Deployment environment (dev, stg, prd)."
  type        = string
}

variable "clouds" {
  description = "Clouds this platform spans."
  type        = list(string)
  default     = ["aws", "azure", "gcp"]
}

variable "owner" {
  description = "Team accountable for this platform."
  type        = string
}

variable "cost_center" {
  description = "Cost center billed for this platform."
  type        = string
}

variable "data_classification" {
  description = "Highest classification of data the platform may hold."
  type        = string
}

variable "address_space" {
  description = "Non-overlapping CIDR per cloud."
  type = object({
    aws   = optional(string, "10.10.0.0/16")
    azure = optional(string, "10.11.0.0/16")
    gcp   = optional(string, "10.12.0.0/16")
  })
  default = {}
}

variable "aws_region" {
  description = "AWS region."
  type        = string
  default     = "eu-west-1"
}

variable "azure_location" {
  description = "Azure region."
  type        = string
  default     = "westeurope"
}

variable "gcp_project_id" {
  description = "GCP project id."
  type        = string
  default     = ""
}

variable "gcp_region" {
  description = "GCP region."
  type        = string
  default     = "europe-west1"
}

variable "master_username" {
  description = "Administrative username for the AWS transactional cluster."
  type        = string
  default     = "dbadmin"
}

variable "cosmos_capabilities" {
  description = "Cosmos DB capabilities, e.g. EnableServerless."
  type        = list(string)
  default     = []
}

variable "enable_cross_cloud_replication" {
  description = "Mirror stream topics between AWS and Azure."
  type        = bool
  default     = false
}

variable "enable_governance" {
  description = "Deploy the cross-cloud catalog. Requires at least two clouds in scope."
  type        = bool
  default     = true
}
