# -----------------------------------------------------------------------------
# Shared Governance Module
# Cross-cloud data governance: Glue Catalog, Purview, KMS keys, IAM roles
# -----------------------------------------------------------------------------

locals {
  name_prefix = "${var.project_name}-${var.environment}"
}

# =============================================================================
# AWS - Glue Data Catalog & KMS for column-level encryption
# =============================================================================

resource "aws_glue_catalog_database" "governance" {
  name        = replace("${local.name_prefix}_governance", "-", "_")
  description = "Governance metadata catalog for cross-cloud data platform"

  create_table_default_permission {
    permissions = ["ALL"]

    principal {
      data_lake_principal_identifier = "IAM_ALLOWED_PRINCIPALS"
    }
  }
}

resource "aws_kms_key" "data_encryption" {
  description             = "Column-level data encryption key for ${local.name_prefix}"
  deletion_window_in_days = 30
  enable_key_rotation     = true

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Sid    = "EnableRootAccount"
        Effect = "Allow"
        Principal = {
          AWS = "arn:aws:iam::${data.aws_caller_identity.current.account_id}:root"
        }
        Action   = "kms:*"
        Resource = "*"
      },
      {
        Sid    = "AllowGlueAccess"
        Effect = "Allow"
        Principal = {
          Service = "glue.amazonaws.com"
        }
        Action = [
          "kms:Decrypt",
          "kms:Encrypt",
          "kms:GenerateDataKey",
          "kms:DescribeKey"
        ]
        Resource = "*"
      }
    ]
  })

  tags = merge(var.tags, {
    Name    = "${local.name_prefix}-governance-kms"
    Purpose = "column-level-encryption"
  })
}

resource "aws_kms_alias" "data_encryption" {
  name          = "alias/${local.name_prefix}-governance-key"
  target_key_id = aws_kms_key.data_encryption.key_id
}

# Cross-cloud access IAM role
resource "aws_iam_role" "cross_cloud_governance" {
  name_prefix = "${local.name_prefix}-gov-"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = "sts:AssumeRole"
        Effect = "Allow"
        Principal = {
          Service = [
            "glue.amazonaws.com",
            "lakeformation.amazonaws.com"
          ]
        }
      }
    ]
  })

  tags = var.tags
}

resource "aws_iam_role_policy" "governance_glue" {
  name_prefix = "glue-catalog-"
  role        = aws_iam_role.cross_cloud_governance.id

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Action = [
          "glue:GetDatabase*",
          "glue:GetTable*",
          "glue:GetPartition*",
          "glue:SearchTables",
          "glue:BatchGetPartition"
        ]
        Resource = "*"
      },
      {
        Effect = "Allow"
        Action = [
          "kms:Decrypt",
          "kms:DescribeKey"
        ]
        Resource = [aws_kms_key.data_encryption.arn]
      }
    ]
  })
}

data "aws_caller_identity" "current" {}

# =============================================================================
# Azure - Purview Account
# =============================================================================

resource "azurerm_purview_account" "main" {
  name                = "${replace(local.name_prefix, "-", "")}purview"
  resource_group_name = var.azure_resource_group_name
  location            = var.azure_region

  identity {
    type = "SystemAssigned"
  }

  managed_resource_group_name = "${local.name_prefix}-purview-managed-rg"
  public_network_enabled      = false

  tags = merge(var.tags, {
    Name    = "${local.name_prefix}-purview"
    Purpose = "data-governance"
  })
}

# =============================================================================
# GCP - KMS for column-level encryption
# =============================================================================

resource "google_kms_key_ring" "governance" {
  name     = "${local.name_prefix}-governance-keyring"
  location = var.gcp_region
  project  = var.gcp_project_id
}

resource "google_kms_crypto_key" "data_encryption" {
  name     = "${local.name_prefix}-governance-key"
  key_ring = google_kms_key_ring.governance.id

  rotation_period = "7776000s" # 90 days

  purpose = "ENCRYPT_DECRYPT"

  version_template {
    algorithm        = "GOOGLE_SYMMETRIC_ENCRYPTION"
    protection_level = "SOFTWARE"
  }

  labels = {
    project     = var.project_name
    environment = var.environment
    purpose     = "column-level-encryption"
  }

  lifecycle {
    prevent_destroy = false
  }
}

# Cross-cloud governance service account
resource "google_service_account" "governance" {
  account_id   = "${local.name_prefix}-governance"
  display_name = "Cross-Cloud Governance SA - ${var.environment}"
  description  = "Service account for cross-cloud data governance operations"
  project      = var.gcp_project_id
}

resource "google_project_iam_member" "governance_bq" {
  project = var.gcp_project_id
  role    = "roles/bigquery.dataViewer"
  member  = "serviceAccount:${google_service_account.governance.email}"
}

resource "google_project_iam_member" "governance_storage" {
  project = var.gcp_project_id
  role    = "roles/storage.objectViewer"
  member  = "serviceAccount:${google_service_account.governance.email}"
}

resource "google_kms_crypto_key_iam_member" "governance_kms" {
  crypto_key_id = google_kms_crypto_key.data_encryption.id
  role          = "roles/cloudkms.cryptoKeyEncrypterDecrypter"
  member        = "serviceAccount:${google_service_account.governance.email}"
}
