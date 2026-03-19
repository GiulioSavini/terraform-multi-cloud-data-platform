variable "project_name" {
  description = "Project name used as resource prefix"
  type        = string
}

variable "environment" {
  description = "Environment name (dev, stg, prd)"
  type        = string
}

variable "vpc_id" {
  description = "VPC ID where MSK will be deployed"
  type        = string
}

variable "subnet_ids" {
  description = "List of subnet IDs for broker placement"
  type        = list(string)

  validation {
    condition     = length(var.subnet_ids) >= 2
    error_message = "At least 2 subnets required for MSK."
  }
}

variable "security_group_ids" {
  description = "Security group IDs for MSK brokers"
  type        = list(string)
}

variable "kafka_version" {
  description = "Apache Kafka version"
  type        = string
  default     = "3.6.0"
}

variable "instance_type" {
  description = "MSK broker instance type"
  type        = string
  default     = "kafka.t3.small"
}

variable "number_of_brokers" {
  description = "Number of MSK broker nodes"
  type        = number
  default     = 3

  validation {
    condition     = var.number_of_brokers >= 2
    error_message = "At least 2 brokers are required."
  }
}

variable "ebs_volume_size" {
  description = "EBS volume size in GB per broker"
  type        = number
  default     = 100

  validation {
    condition     = var.ebs_volume_size >= 1 && var.ebs_volume_size <= 16384
    error_message = "EBS volume size must be between 1 and 16384 GB."
  }
}

variable "tags" {
  description = "Common tags for all resources"
  type        = map(string)
  default     = {}
}
