variable "project" { type = string }
variable "environment" { type = string }
variable "gcp_project_id" { type = string }
variable "bq_dataset_id" { type = string; default = "" }
variable "message_retention" { type = string; default = "604800s" }
variable "labels" { type = map(string); default = {} }
