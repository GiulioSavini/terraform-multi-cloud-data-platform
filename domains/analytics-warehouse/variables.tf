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

variable "lake_zone_arns" {
  description = "The `aws_zone_arns` output of the data-lake context. Redshift Spectrum reads the analytics zone directly."
  type        = any
  default     = null
}

variable "azure_storage" {
  description = "The `azure_storage` output of the data-lake context. Synapse is backed by the lake's storage account."
  type        = any
  default     = null
}

variable "aws_security_group_ids" {
  description = "Security groups for the AWS warehouse, from the networking context."
  type        = list(string)
  default     = []
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
