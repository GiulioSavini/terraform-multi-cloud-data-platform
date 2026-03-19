variable "project_name" {
  description = "Project name used as resource prefix"
  type        = string
}

variable "environment" {
  description = "Environment name (dev, stg, prd)"
  type        = string
}

variable "location" {
  description = "Azure region"
  type        = string
}

variable "resource_group_name" {
  description = "Name of the resource group"
  type        = string
}

variable "storage_account_id" {
  description = "ADLS Gen2 storage account ID"
  type        = string
}

variable "storage_account_url" {
  description = "ADLS Gen2 primary DFS endpoint URL"
  type        = string
}

variable "filesystem_id" {
  description = "ADLS Gen2 filesystem ID for the workspace"
  type        = string
}

variable "subnet_id" {
  description = "Subnet ID for managed private endpoint"
  type        = string
}

variable "sql_pool_sku" {
  description = "Synapse dedicated SQL pool SKU"
  type        = string
  default     = "DW100c"

  validation {
    condition     = can(regex("^DW\\d+c$", var.sql_pool_sku))
    error_message = "SQL pool SKU must match pattern DWxxxc (e.g., DW100c, DW500c)."
  }
}

variable "spark_node_count" {
  description = "Number of Spark pool nodes"
  type        = number
  default     = 3

  validation {
    condition     = var.spark_node_count >= 3 && var.spark_node_count <= 200
    error_message = "Spark node count must be between 3 and 200."
  }
}

variable "sql_admin_user" {
  description = "SQL administrator username"
  type        = string
  default     = "sqladmin"
}

variable "tags" {
  description = "Common tags for all resources"
  type        = map(string)
  default     = {}
}
