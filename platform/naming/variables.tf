variable "landing_zone" {
  description = "Landing zone identifier. Appears first in every resource name."
  type        = string

  validation {
    condition     = can(regex("^[a-z][a-z0-9-]{1,14}$", var.landing_zone))
    error_message = "landing_zone must be 2-15 chars, lowercase alphanumeric or dash, starting with a letter. Azure storage accounts and GCP buckets impose the tightest limits and this keeps every derived name inside them."
  }
}

variable "environment" {
  description = "Deployment environment."
  type        = string

  validation {
    condition     = contains(["dev", "stg", "prd"], var.environment)
    error_message = "environment must be one of: dev, stg, prd."
  }
}

variable "context" {
  description = <<-EOT
    Bounded context this name belongs to, e.g. "networking" or "observability".
    Encoding the context in the resource name is what makes ownership legible
    in a console listing that mixes every domain in one account.
  EOT
  type        = string

  validation {
    condition     = can(regex("^[a-z][a-z0-9-]{1,20}$", var.context))
    error_message = "context must be 2-21 chars, lowercase alphanumeric or dash, starting with a letter."
  }
}
