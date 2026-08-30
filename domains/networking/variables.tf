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

  validation {
    condition     = length(var.clouds) > 0 && length(setsubtract(toset(var.clouds), toset(["aws", "azure", "gcp"]))) == 0
    error_message = "clouds must be a non-empty subset of: aws, azure, gcp."
  }
}

variable "address_space" {
  description = "Non-overlapping CIDR per cloud. Cross-cloud replication routes between them."
  type = object({
    aws   = optional(string, "10.10.0.0/16")
    azure = optional(string, "10.11.0.0/16")
    gcp   = optional(string, "10.12.0.0/16")
  })
  default = {}
}

variable "placement" {
  description = "Provider-specific placement."
  type = object({
    aws   = optional(object({ region = string }))
    azure = optional(object({ location = string }))
  })
}

variable "tags" {
  description = "Tag set from platform/tagging."
  type        = map(string)
}
