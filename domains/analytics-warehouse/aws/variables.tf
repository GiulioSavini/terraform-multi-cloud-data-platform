variable "project_name" {
  description = "Project name used as resource prefix"
  type        = string
}

variable "environment" {
  description = "Environment name (dev, stg, prd)"
  type        = string
}

variable "subnet_ids" {
  description = "List of subnet IDs for the Redshift subnet group"
  type        = list(string)
}

variable "security_group_ids" {
  description = "List of security group IDs for the cluster"
  type        = list(string)
}

variable "node_type" {
  description = "Redshift node type"
  type        = string
  default     = "dc2.large"

  validation {
    condition     = contains(["dc2.large", "dc2.8xlarge", "ra3.xlplus", "ra3.4xlarge", "ra3.16xlarge"], var.node_type)
    error_message = "Invalid Redshift node type."
  }
}

variable "number_of_nodes" {
  description = "Number of Redshift nodes"
  type        = number
  default     = 1

  validation {
    condition     = var.number_of_nodes >= 1 && var.number_of_nodes <= 128
    error_message = "Number of nodes must be between 1 and 128."
  }
}

variable "database_name" {
  description = "Name of the default database"
  type        = string
  default     = "analytics"
}

variable "master_username" {
  description = "Master username for the database"
  type        = string
  default     = "rsadmin"
  sensitive   = true
}

variable "s3_data_lake_arn" {
  description = "ARN of the S3 data lake bucket for Spectrum access"
  type        = string
}

variable "tags" {
  description = "Common tags for all resources"
  type        = map(string)
  default     = {}
}
