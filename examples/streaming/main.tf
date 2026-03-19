# =============================================================================
# Cross-Cloud Streaming Example
# Deploys: MSK (AWS) + Event Hubs (Azure) + Pub/Sub (GCP) + replication
# =============================================================================
#
# Usage:
#   terraform init
#   terraform apply
#
# This example shows how to set up cross-cloud Kafka streaming with
# MSK Connect for replication between AWS MSK and Azure Event Hubs.
#
# Estimated cost: ~$200/month
# Deploy time: ~20 minutes
# =============================================================================

terraform {
  required_version = ">= 1.9.0"
  required_providers {
    aws     = { source = "hashicorp/aws", version = "~> 5.0" }
    azurerm = { source = "hashicorp/azurerm", version = "~> 3.0" }
    google  = { source = "hashicorp/google", version = "~> 5.0" }
  }
}

provider "aws" { region = var.aws_region }
provider "azurerm" { features {}; subscription_id = var.azure_subscription_id }
provider "google" { project = var.gcp_project_id; region = var.gcp_region }

variable "aws_region" { type = string; default = "eu-west-1" }
variable "azure_subscription_id" { type = string }
variable "azure_location" { type = string; default = "westeurope" }
variable "gcp_project_id" { type = string }
variable "gcp_region" { type = string; default = "europe-west1" }

locals {
  project     = "streaming"
  environment = "dev"
  tags        = { Project = local.project, Environment = local.environment }
}

resource "azurerm_resource_group" "main" {
  name     = "${local.project}-${local.environment}-rg"
  location = var.azure_location
  tags     = local.tags
}

# --- AWS: VPC + MSK Kafka ---
module "aws_networking" {
  source      = "../../modules/aws/networking"
  project     = local.project
  environment = local.environment
  tags        = local.tags
}

module "msk" {
  source               = "../../modules/aws/msk"
  project              = local.project
  environment          = local.environment
  subnet_ids           = module.aws_networking.private_subnet_ids
  broker_instance_type = "kafka.t3.small"
  number_of_brokers    = 2
  ebs_volume_size      = 50
  tags                 = local.tags
}

# --- Azure: Event Hubs (Kafka protocol) ---
module "event_hubs" {
  source              = "../../modules/azure/kafka"
  project             = local.project
  environment         = local.environment
  resource_group_name = azurerm_resource_group.main.name
  location            = var.azure_location
  sku                 = "Standard"
  capacity            = 1
  tags                = local.tags
}

# --- GCP: Pub/Sub ---
module "pubsub" {
  source         = "../../modules/gcp/kafka"
  project        = local.project
  environment    = local.environment
  gcp_project_id = var.gcp_project_id
  labels         = local.tags
}

# --- Cross-Cloud Replication Config ---
module "streaming_replication" {
  source = "../../modules/shared/streaming"

  project               = local.project
  environment           = local.environment
  msk_cluster_arn       = module.msk.cluster_arn
  msk_bootstrap_brokers = module.msk.bootstrap_brokers_tls
  tags                  = local.tags
}

output "msk_brokers" { value = module.msk.bootstrap_brokers_tls; sensitive = true }
output "eventhubs_kafka_endpoint" { value = module.event_hubs.kafka_endpoint }
output "pubsub_events_topic" { value = module.pubsub.events_topic_id }
output "replication_role_arn" { value = module.streaming_replication.msk_connect_role_arn }
