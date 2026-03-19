variable "project" { type = string }
variable "environment" { type = string }
variable "gcp_project_id" { type = string }
variable "region" { type = string; default = "europe-west1" }
variable "tier" { type = string; default = "db-f1-micro" }
variable "disk_size" { type = number; default = 20 }
variable "network_id" { type = string }
variable "database_name" { type = string; default = "appdb" }
variable "labels" { type = map(string); default = {} }
