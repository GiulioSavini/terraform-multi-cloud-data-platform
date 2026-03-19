variable "project" { type = string }
variable "environment" { type = string }
variable "gcp_project_id" { type = string }
variable "region" { type = string; default = "europe-west1" }
variable "network_id" { type = string }
variable "subnet_id" { type = string }
variable "max_workers" { type = number; default = 3 }
variable "labels" { type = map(string); default = {} }
