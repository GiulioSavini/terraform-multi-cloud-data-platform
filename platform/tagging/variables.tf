variable "landing_zone" {
  description = "Landing zone identifier."
  type        = string
}

variable "environment" {
  description = "Deployment environment (dev, stg, prd)."
  type        = string
}

variable "context" {
  description = "Bounded context that owns the resource."
  type        = string
}

variable "owner" {
  description = "Team accountable for the resource. Must resolve to a real contact — an unowned resource cannot be assessed during an audit."
  type        = string

  validation {
    condition     = length(trimspace(var.owner)) > 0
    error_message = "owner must not be empty. Every resource needs an accountable team."
  }
}

variable "cost_center" {
  description = "Cost center the resource is billed to."
  type        = string
}

variable "data_classification" {
  description = <<-EOT
    Highest classification of data the resource may hold. Drives encryption,
    retention and access requirements downstream, so it is mandatory rather
    than defaulted — a wrong default here is a silent compliance failure.
  EOT
  type        = string

  validation {
    condition     = contains(["public", "internal", "confidential", "restricted"], var.data_classification)
    error_message = "data_classification must be one of: public, internal, confidential, restricted."
  }
}

variable "compliance_scope" {
  description = "Compliance frameworks this resource is in scope for."
  type        = list(string)
  default     = ["cis", "iso27001", "soc2", "nis2"]

  validation {
    condition     = length(setsubtract(toset(var.compliance_scope), toset(["cis", "iso27001", "soc2", "nis2", "none"]))) == 0
    error_message = "compliance_scope entries must be from: cis, iso27001, soc2, nis2, none."
  }
}

variable "extra" {
  description = "Additional non-mandatory tags."
  type        = map(string)
  default     = {}
}
