variable "project" { type = string }
variable "environment" { type = string }
variable "gcp_project_id" { type = string }
variable "location" { type = string; default = "EU" }
variable "labels" { type = map(string); default = {} }
