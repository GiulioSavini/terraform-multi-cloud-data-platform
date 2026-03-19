variable "project_name" {
  description = "Project name used as resource prefix"
  type        = string
}

variable "environment" {
  description = "Environment name (dev, stg, prd)"
  type        = string
}

variable "s3_raw_path" {
  description = "S3 path to the raw data zone"
  type        = string
}

variable "s3_curated_path" {
  description = "S3 path to the curated data zone"
  type        = string
}

variable "s3_analytics_path" {
  description = "S3 path to the analytics data zone"
  type        = string
}

variable "data_lake_kms_key_arn" {
  description = "ARN of the KMS key for the data lake"
  type        = string
}

variable "vpc_id" {
  description = "VPC ID for Glue connection"
  type        = string
}

variable "subnet_id" {
  description = "Subnet ID for Glue connection"
  type        = string
}

variable "security_group_ids" {
  description = "Security group IDs for Glue connection"
  type        = list(string)
}

variable "glue_version" {
  description = "Glue version for ETL jobs"
  type        = string
  default     = "4.0"
}

variable "max_capacity" {
  description = "Maximum number of DPU for the Glue job"
  type        = number
  default     = 2.0
}

variable "tags" {
  description = "Common tags for all resources"
  type        = map(string)
  default     = {}
}
