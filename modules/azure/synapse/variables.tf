variable "project" { type = string }
variable "environment" { type = string }
variable "resource_group_name" { type = string }
variable "location" { type = string }
variable "adls_id" { type = string }
variable "adls_filesystem_id" { type = string }
variable "sql_pool_sku" { type = string; default = "DW100c" }
variable "spark_node_size" { type = string; default = "Small" }
variable "spark_min_nodes" { type = number; default = 3 }
variable "spark_max_nodes" { type = number; default = 10 }
variable "sql_admin_user" { type = string; default = "sqladmin" }
variable "sql_admin_password" { type = string; sensitive = true }
variable "tags" { type = map(string); default = {} }
