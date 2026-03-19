# =============================================================================
# Azure Analytics Example
# Deploys: CosmosDB + ADLS Gen2 + Data Factory + Synapse Analytics
# =============================================================================
#
# Usage:
#   terraform init
#   terraform apply -var="subscription_id=YOUR_SUB" -var="synapse_password=YOUR_PASS"
#
# Estimated cost: ~$120/month (dev sizing with auto-pause)
# Deploy time: ~15 minutes
# =============================================================================

terraform {
  required_version = ">= 1.9.0"
  required_providers {
    azurerm = { source = "hashicorp/azurerm", version = "~> 3.0" }
  }
}

provider "azurerm" {
  features {}
  subscription_id = var.subscription_id
}

variable "subscription_id" { type = string }
variable "location" { type = string; default = "westeurope" }
variable "synapse_password" { type = string; sensitive = true }

locals {
  project     = "azure-analytics"
  environment = "dev"
  tags        = { Project = local.project, Environment = local.environment }
}

resource "azurerm_resource_group" "main" {
  name     = "${local.project}-${local.environment}-rg"
  location = var.location
  tags     = local.tags
}

# --- ADLS Gen2 Data Lake ---
module "data_lake" {
  source              = "../../modules/azure/data-lake"
  project             = local.project
  environment         = local.environment
  resource_group_name = azurerm_resource_group.main.name
  location            = var.location
  tags                = local.tags
}

# --- CosmosDB (operational data) ---
module "cosmosdb" {
  source              = "../../modules/azure/cosmosdb"
  project             = local.project
  environment         = local.environment
  resource_group_name = azurerm_resource_group.main.name
  location            = var.location
  max_throughput      = 1000
  tags                = local.tags
}

# --- Data Factory (ETL pipelines) ---
module "data_factory" {
  source              = "../../modules/azure/data-factory"
  project             = local.project
  environment         = local.environment
  resource_group_name = azurerm_resource_group.main.name
  location            = var.location
  adls_endpoint       = module.data_lake.primary_dfs_endpoint
  tags                = local.tags
}

# --- Synapse Analytics (data warehouse) ---
module "synapse" {
  source              = "../../modules/azure/synapse"
  project             = local.project
  environment         = local.environment
  resource_group_name = azurerm_resource_group.main.name
  location            = var.location
  adls_id             = module.data_lake.storage_account_id
  adls_filesystem_id  = module.data_lake.raw_filesystem_id
  sql_pool_sku        = "DW100c"
  sql_admin_password  = var.synapse_password
  tags                = local.tags
}

output "adls_name" { value = module.data_lake.storage_account_name }
output "cosmos_endpoint" { value = module.cosmosdb.endpoint }
output "synapse_workspace" { value = module.synapse.workspace_name }
output "data_factory_name" { value = module.data_factory.name }
