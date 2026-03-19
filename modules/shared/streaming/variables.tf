variable "project" { type = string }
variable "environment" { type = string }
variable "msk_cluster_arn" { type = string; default = "" }
variable "msk_bootstrap_brokers" { type = string; default = "" }
variable "tags" { type = map(string); default = {} }
