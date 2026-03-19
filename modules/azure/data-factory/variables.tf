variable "project" { type = string }
variable "environment" { type = string }
variable "resource_group_name" { type = string }
variable "location" { type = string }
variable "adls_endpoint" { type = string; default = "" }
variable "cosmos_connection_string" { type = string; default = ""; sensitive = true }
variable "tags" { type = map(string); default = {} }
