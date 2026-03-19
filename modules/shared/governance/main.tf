locals {
  name_prefix = "${var.project}-${var.environment}"
}

# AWS KMS Key for column-level encryption
resource "aws_kms_key" "data_encryption" {
  description             = "Data encryption key for ${local.name_prefix}"
  deletion_window_in_days = 7
  enable_key_rotation     = true
  tags                    = var.tags
}

resource "aws_kms_alias" "data_encryption" {
  name          = "alias/${local.name_prefix}-data-key"
  target_key_id = aws_kms_key.data_encryption.key_id
}

# GCP KMS for column-level encryption
resource "google_kms_key_ring" "data" {
  name     = "${local.name_prefix}-data-keyring"
  project  = var.gcp_project_id
  location = "europe"
}

resource "google_kms_crypto_key" "data_encryption" {
  name     = "${local.name_prefix}-data-key"
  key_ring = google_kms_key_ring.data.id

  rotation_period = "7776000s" # 90 days

  lifecycle {
    prevent_destroy = false
  }
}

# Azure Purview (Data Governance)
resource "azurerm_purview_account" "main" {
  name                = "${replace(local.name_prefix, "-", "")}purview"
  resource_group_name = var.azure_resource_group_name
  location            = var.azure_location

  identity { type = "SystemAssigned" }

  managed_resource_group_name = "${local.name_prefix}-purview-managed-rg"

  tags = var.tags
}

# AWS Glue Data Catalog Tags
resource "aws_glue_catalog_database" "governance" {
  name = replace("${local.name_prefix}_governance", "-", "_")
}
