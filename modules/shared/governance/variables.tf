variable "project" { type = string }
variable "environment" { type = string }
variable "gcp_project_id" { type = string }
variable "azure_resource_group_name" { type = string }
variable "azure_location" { type = string }
variable "tags" { type = map(string); default = {} }
