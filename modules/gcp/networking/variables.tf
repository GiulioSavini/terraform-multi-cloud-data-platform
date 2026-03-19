variable "project" { type = string }
variable "environment" { type = string }
variable "gcp_project_id" { type = string }
variable "region" { type = string; default = "europe-west1" }
variable "subnet_cidr" { type = string; default = "10.2.0.0/20" }
variable "labels" { type = map(string); default = {} }
