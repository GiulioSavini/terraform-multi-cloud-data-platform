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

variable "aws_security_group_ids" {
  description = "Security groups for the AWS broker cluster."
  type        = list(string)
  default     = []
}

variable "azure_storage_account_id" {
  description = "Storage account Event Hubs captures to."
  type        = string
  default     = ""
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

variable "enable_cross_cloud_replication" {
  description = <<-EOT
    Mirror topics between the AWS and Azure brokers. Requires both to be in
    scope, and it is not free: replication doubles egress and introduces an
    ordering guarantee the source brokers do not make.
  EOT
  type        = bool
  default     = false
}

variable "tags" {
  description = "Tag set from platform/tagging."
  type        = map(string)
}
