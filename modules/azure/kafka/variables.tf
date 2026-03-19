variable "project" { type = string }
variable "environment" { type = string }
variable "resource_group_name" { type = string }
variable "location" { type = string }
variable "sku" { type = string; default = "Standard" }
variable "capacity" { type = number; default = 1 }
variable "partition_count" { type = number; default = 4 }
variable "message_retention_days" { type = number; default = 7 }
variable "tags" { type = map(string); default = {} }
