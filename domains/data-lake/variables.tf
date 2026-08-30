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
