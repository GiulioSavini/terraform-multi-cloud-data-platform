variable "landing_zone" {
  description = "Platform identifier."
  type        = string
}

variable "environment" {
  description = "Deployment environment (dev, stg, prd)."
  type        = string
}

variable "clouds" {
  description = <<-EOT
    Clouds in scope. Governance is cross-cloud by nature — a catalog covering
    one of three clouds is worse than none, because it looks complete.
  EOT
  type        = list(string)
}

variable "placement" {
  description = "Provider-specific placement. Governance touches all three clouds, so all three are required."
  type = object({
    azure = object({
      location            = string
      resource_group_name = string
    })
    gcp = object({
      project_id = string
      region     = string
    })
  })
}

variable "tags" {
  description = "Tag set from platform/tagging."
  type        = map(string)
}
