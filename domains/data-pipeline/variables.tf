variable "landing_zone" {
  description = "Platform identifier."
  type        = string
}

variable "environment" {
  description = "Deployment environment (dev, stg, prd)."
  type        = string
}

variable "clouds" {
  description = "Clouds in scope."
  type        = list(string)
}

variable "networks" {
  description = "The `networks` output of the networking context."
  type        = any
}

variable "lake_zones" {
  description = "The `zones` output of the data-lake context. Pipelines address zones, never bucket names."
  type        = any
}

variable "lake_encryption_keys" {
  description = "The `encryption_keys` output of the data-lake context. A pipeline that cannot use the key cannot read the lake."
  type        = any
  default     = {}
}

variable "azure_storage" {
  description = "The `azure_storage` output of the data-lake context."
  type        = any
  default     = null
}

variable "operational_endpoints" {
  description = "The `endpoints` output of the operational-store context, for pipelines that read from the transactional stores."
  type        = any
  default     = {}
}

variable "warehouse_endpoints" {
  description = "The `azure_endpoints` output of the analytics-warehouse context."
  type        = any
  default     = null
}

variable "aws_security_group_ids" {
  description = "Security groups for AWS Glue connections."
  type        = list(string)
  default     = []
}

variable "gcp_network" {
  description = "The `gcp_network` output of the networking context. Dataflow workers are placed on it."
  type        = any
  default     = null
}

variable "placement" {
  description = "Provider-specific placement."
  type = object({
    azure = optional(object({
      location            = string
      resource_group_name = string
    }))
  })
  default = {}
}

variable "tags" {
  description = "Tag set from platform/tagging."
  type        = map(string)
}

variable "labels" {
  description = "Same tag set normalised to GCP label constraints, from platform/tagging."
  type        = map(string)
}
