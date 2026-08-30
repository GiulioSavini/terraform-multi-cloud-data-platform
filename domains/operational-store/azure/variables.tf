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

variable "subnet_id" {
  description = "Subnet ID for private endpoint"
  type        = string
}

variable "max_throughput" {
  description = "Maximum autoscale throughput (RU/s)"
  type        = number
  default     = 4000

  validation {
    condition     = var.max_throughput >= 1000
    error_message = "Max throughput must be at least 1000 RU/s for autoscale."
  }
}

variable "geo_replication" {
  description = "Enable geo-replication (adds secondary region)"
  type        = bool
  default     = false
}

variable "secondary_location" {
  description = "Secondary location for geo-replication"
  type        = string
  default     = "northeurope"
}

variable "tags" {
  description = "Common tags for all resources"
  type        = map(string)
  default     = {}
}

variable "capabilities" {
  description = <<-EOT
    Cosmos DB account capabilities, e.g. "EnableServerless" or "EnableMongo".
    Serverless accounts cannot have a backup policy, autoscale throughput or
    multi-region writes, so several blocks in this module are switched off when
    it is present.
  EOT
  type        = list(string)
  default     = []

  validation {
    condition = length(setsubtract(toset(var.capabilities), toset([
      "EnableServerless",
      "EnableMongo",
      "EnableCassandra",
      "EnableTable",
      "EnableGremlin",
      "EnableAggregationPipeline",
      "mongoEnableDocLevelTTL",
      "DisableRateLimitingResponses",
    ]))) == 0
    error_message = "capabilities entries must be recognised Cosmos DB capability names."
  }
}
