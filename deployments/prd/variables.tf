variable "aws_region" {
  description = "AWS region."
  type        = string
  default     = "eu-west-1"
}

variable "azure_subscription_id" {
  description = "Azure subscription id."
  type        = string
  default     = ""
}

variable "gcp_project_id" {
  description = "GCP project id."
  type        = string
  default     = ""
}

variable "gcp_region" {
  description = "GCP region."
  type        = string
  default     = "europe-west1"
}

variable "owner" {
  description = "Team accountable for this platform."
  type        = string
}

variable "cost_center" {
  description = "Cost center billed for this platform."
  type        = string
}

variable "data_classification" {
  description = "Highest classification of data held here."
  type        = string
}

variable "master_username" {
  description = "Administrative username for the AWS transactional cluster."
  type        = string
  default     = "dbadmin"
}
