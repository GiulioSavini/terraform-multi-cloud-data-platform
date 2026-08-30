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

variable "tags" {
  description = "Tag set from platform/tagging."
  type        = map(string)
}

variable "placement" {
  description = "Provider-specific placement."
  type = object({
    azure = optional(object({
      location            = string
      resource_group_name = string
      subnet_id           = string
    }))
  })
  default = {}
}

variable "aws_security_group_ids" {
  description = "Security groups for the AWS cluster, from the networking context."
  type        = list(string)
  default     = []
}

variable "gcp_network_id" {
  description = "Network id for Cloud SQL private service access."
  type        = string
  default     = ""
}

variable "master_username" {
  description = <<-EOT
    Administrative username for the AWS cluster. Not "admin" or "root": those
    are the first two entries in every credential-stuffing list, and the
    username is the half of the credential pair that is never rotated.
  EOT
  type        = string
  default     = "dbadmin"

  validation {
    condition     = !contains(["admin", "root", "administrator", "sa", "postgres"], lower(var.master_username))
    error_message = "master_username must not be a well-known default (admin, root, administrator, sa, postgres)."
  }
}

variable "cosmos_capabilities" {
  description = "Cosmos DB capabilities, e.g. EnableServerless."
  type        = list(string)
  default     = []
}
