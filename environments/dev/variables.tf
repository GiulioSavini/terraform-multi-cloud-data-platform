# -----------------------------------------------------------------------------
# General Variables
# -----------------------------------------------------------------------------

variable "project_name" {
  description = "Name of the project, used as prefix for all resources"
  type        = string
  default     = "data-platform"

  validation {
    condition     = can(regex("^[a-z][a-z0-9-]{2,28}[a-z0-9]$", var.project_name))
    error_message = "Project name must be 4-30 characters, lowercase alphanumeric and hyphens."
  }
}

variable "environment" {
  description = "Environment name (dev, stg, prd)"
  type        = string
  default     = "dev"

  validation {
    condition     = contains(["dev", "stg", "prd"], var.environment)
    error_message = "Environment must be one of: dev, stg, prd."
  }
}

variable "owner" {
  description = "Team or individual owning the resources"
  type        = string
  default     = "data-engineering"
}

# -----------------------------------------------------------------------------
# AWS Variables
# -----------------------------------------------------------------------------

variable "aws_region" {
  description = "AWS region for resource deployment"
  type        = string
  default     = "eu-west-1"
}

variable "aws_vpc_cidr" {
  description = "CIDR block for the AWS VPC"
  type        = string
  default     = "10.0.0.0/16"

  validation {
    condition     = can(cidrhost(var.aws_vpc_cidr, 0))
    error_message = "Must be a valid CIDR block."
  }
}

variable "aws_private_subnet_cidrs" {
  description = "CIDR blocks for private subnets across 3 AZs"
  type        = list(string)
  default     = ["10.0.1.0/24", "10.0.2.0/24", "10.0.3.0/24"]
}

variable "aurora_instance_class" {
  description = "Instance class for Aurora PostgreSQL"
  type        = string
  default     = "db.t3.medium"
}

variable "aurora_instance_count" {
  description = "Number of Aurora instances"
  type        = number
  default     = 1
}

variable "aurora_backup_retention" {
  description = "Backup retention period in days for Aurora"
  type        = number
  default     = 7
}

variable "aurora_engine_version" {
  description = "Aurora PostgreSQL engine version"
  type        = string
  default     = "15.4"
}

variable "redshift_node_type" {
  description = "Redshift node type"
  type        = string
  default     = "dc2.large"
}

variable "redshift_number_of_nodes" {
  description = "Number of Redshift nodes"
  type        = number
  default     = 1
}

variable "msk_instance_type" {
  description = "MSK broker instance type"
  type        = string
  default     = "kafka.t3.small"
}

variable "msk_number_of_brokers" {
  description = "Number of MSK broker nodes"
  type        = number
  default     = 2
}

variable "msk_ebs_volume_size" {
  description = "EBS volume size in GB for each MSK broker"
  type        = number
  default     = 100
}

# -----------------------------------------------------------------------------
# Azure Variables
# -----------------------------------------------------------------------------

variable "azure_subscription_id" {
  description = "Azure subscription ID"
  type        = string
  sensitive   = true
}

variable "azure_region" {
  description = "Azure region for resource deployment"
  type        = string
  default     = "westeurope"
}

variable "azure_vnet_cidr" {
  description = "CIDR block for the Azure VNet"
  type        = string
  default     = "10.1.0.0/16"
}

variable "cosmosdb_max_throughput" {
  description = "CosmosDB autoscale max throughput (RU/s)"
  type        = number
  default     = 4000
}

variable "cosmosdb_geo_replication" {
  description = "Enable CosmosDB geo-replication"
  type        = bool
  default     = false
}

variable "synapse_sql_pool_sku" {
  description = "Synapse dedicated SQL pool SKU"
  type        = string
  default     = "DW100c"
}

variable "synapse_spark_node_count" {
  description = "Number of Spark pool nodes"
  type        = number
  default     = 3
}

variable "eventhubs_capacity" {
  description = "Event Hubs throughput units"
  type        = number
  default     = 1
}

# -----------------------------------------------------------------------------
# GCP Variables
# -----------------------------------------------------------------------------

variable "gcp_project_id" {
  description = "GCP project ID"
  type        = string
}

variable "gcp_region" {
  description = "GCP region for resource deployment"
  type        = string
  default     = "europe-west1"
}

variable "gcp_vpc_cidr" {
  description = "CIDR block for the GCP VPC subnet"
  type        = string
  default     = "10.2.0.0/16"
}

variable "cloudsql_tier" {
  description = "CloudSQL machine tier"
  type        = string
  default     = "db-custom-2-8192"
}

variable "cloudsql_ha_enabled" {
  description = "Enable CloudSQL high availability"
  type        = bool
  default     = false
}

variable "cloudsql_backup_retention" {
  description = "CloudSQL backup retention in days"
  type        = number
  default     = 7
}

variable "cloudsql_read_replicas" {
  description = "Number of CloudSQL read replicas"
  type        = number
  default     = 0
}

variable "dataflow_machine_type" {
  description = "Dataflow worker machine type"
  type        = string
  default     = "n1-standard-2"
}

variable "dataflow_max_workers" {
  description = "Maximum number of Dataflow workers"
  type        = number
  default     = 1
}
