variable "project_name" {
  description = "Project name used as resource prefix"
  type        = string
}

variable "environment" {
  description = "Environment name (dev, stg, prd)"
  type        = string
}

variable "ia_transition_days" {
  description = "Days before transitioning objects to Infrequent Access"
  type        = number
  default     = 30
}

variable "glacier_transition_days" {
  description = "Days before transitioning objects to Glacier"
  type        = number
  default     = 90
}

variable "noncurrent_expiration_days" {
  description = "Days before expiring noncurrent object versions"
  type        = number
  default     = 90
}

variable "tags" {
  description = "Common tags for all resources"
  type        = map(string)
  default     = {}
}
