# -----------------------------------------------------------------------------
# AWS Data Lake Module
# S3 buckets (raw/curated/analytics), lifecycle policies, KMS, Lake Formation
# -----------------------------------------------------------------------------

locals {
  name_prefix = "${var.project_name}-${var.environment}"
  zones       = ["raw", "curated", "analytics"]
}

data "aws_caller_identity" "current" {}

# -----------------------------------------------------------------------------
# KMS Key
# -----------------------------------------------------------------------------

resource "aws_kms_key" "data_lake" {
  description             = "KMS key for S3 Data Lake encryption - ${local.name_prefix}"
  deletion_window_in_days = 30
  enable_key_rotation     = true

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Sid    = "EnableRootAccountAccess"
        Effect = "Allow"
        Principal = {
          AWS = "arn:aws:iam::${data.aws_caller_identity.current.account_id}:root"
        }
        Action   = "kms:*"
        Resource = "*"
      },
      {
        Sid    = "AllowLakeFormation"
        Effect = "Allow"
        Principal = {
          Service = "lakeformation.amazonaws.com"
        }
        Action = [
          "kms:Decrypt",
          "kms:DescribeKey",
          "kms:GenerateDataKey"
        ]
        Resource = "*"
      }
    ]
  })

  tags = merge(var.tags, {
    Name = "${local.name_prefix}-data-lake-kms"
  })
}

resource "aws_kms_alias" "data_lake" {
  name          = "alias/${local.name_prefix}-data-lake"
  target_key_id = aws_kms_key.data_lake.key_id
}

# -----------------------------------------------------------------------------
# S3 Buckets
# -----------------------------------------------------------------------------

resource "aws_s3_bucket" "zones" {
  for_each = toset(local.zones)

  bucket_prefix = "${local.name_prefix}-${each.value}-"
  force_destroy = var.environment != "prd"

  tags = merge(var.tags, {
    Name     = "${local.name_prefix}-${each.value}"
    DataZone = each.value
  })
}

resource "aws_s3_bucket_versioning" "zones" {
  for_each = aws_s3_bucket.zones

  bucket = each.value.id

  versioning_configuration {
    status = "Enabled"
  }
}

resource "aws_s3_bucket_server_side_encryption_configuration" "zones" {
  for_each = aws_s3_bucket.zones

  bucket = each.value.id

  rule {
    apply_server_side_encryption_by_default {
      sse_algorithm     = "aws:kms"
      kms_master_key_id = aws_kms_key.data_lake.arn
    }
    bucket_key_enabled = true
  }
}

resource "aws_s3_bucket_public_access_block" "zones" {
  for_each = aws_s3_bucket.zones

  bucket = each.value.id

  block_public_acls       = true
  block_public_policy     = true
  ignore_public_acls      = true
  restrict_public_buckets = true
}

resource "aws_s3_bucket_lifecycle_configuration" "zones" {
  for_each = aws_s3_bucket.zones

  bucket = each.value.id

  rule {
    id     = "transition-to-ia"
    status = "Enabled"

    transition {
      days          = var.ia_transition_days
      storage_class = "STANDARD_IA"
    }

    transition {
      days          = var.glacier_transition_days
      storage_class = "GLACIER"
    }

    noncurrent_version_expiration {
      noncurrent_days = var.noncurrent_expiration_days
    }
  }

  rule {
    id     = "abort-incomplete-multipart"
    status = "Enabled"

    abort_incomplete_multipart_upload {
      days_after_initiation = 7
    }
  }

  depends_on = [aws_s3_bucket_versioning.zones]
}

resource "aws_s3_bucket_policy" "zones" {
  for_each = aws_s3_bucket.zones

  bucket = each.value.id

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Sid    = "DenyUnencryptedTransport"
        Effect = "Deny"
        Principal = "*"
        Action = "s3:*"
        Resource = [
          each.value.arn,
          "${each.value.arn}/*"
        ]
        Condition = {
          Bool = {
            "aws:SecureTransport" = "false"
          }
        }
      },
      {
        Sid    = "DenyIncorrectEncryption"
        Effect = "Deny"
        Principal = "*"
        Action = "s3:PutObject"
        Resource = "${each.value.arn}/*"
        Condition = {
          StringNotEquals = {
            "s3:x-amz-server-side-encryption" = "aws:kms"
          }
        }
      }
    ]
  })
}

resource "aws_s3_bucket_logging" "zones" {
  for_each = aws_s3_bucket.zones

  bucket        = each.value.id
  target_bucket = aws_s3_bucket.access_logs.id
  target_prefix = "${each.key}/"
}

# -----------------------------------------------------------------------------
# Access Logs Bucket
# -----------------------------------------------------------------------------

resource "aws_s3_bucket" "access_logs" {
  bucket_prefix = "${local.name_prefix}-access-logs-"
  force_destroy = var.environment != "prd"

  tags = merge(var.tags, {
    Name = "${local.name_prefix}-access-logs"
  })
}

resource "aws_s3_bucket_server_side_encryption_configuration" "access_logs" {
  bucket = aws_s3_bucket.access_logs.id

  rule {
    apply_server_side_encryption_by_default {
      sse_algorithm = "AES256"
    }
  }
}

resource "aws_s3_bucket_public_access_block" "access_logs" {
  bucket = aws_s3_bucket.access_logs.id

  block_public_acls       = true
  block_public_policy     = true
  ignore_public_acls      = true
  restrict_public_buckets = true
}

resource "aws_s3_bucket_lifecycle_configuration" "access_logs" {
  bucket = aws_s3_bucket.access_logs.id

  rule {
    id     = "log-expiration"
    status = "Enabled"

    expiration {
      days = 90
    }
  }

  rule {
    id     = "abort-incomplete-multipart"
    status = "Enabled"

    abort_incomplete_multipart_upload {
      days_after_initiation = 7
    }
  }
}

# -----------------------------------------------------------------------------
# Lake Formation
# -----------------------------------------------------------------------------

resource "aws_lakeformation_data_lake_settings" "main" {
  admins = [data.aws_caller_identity.current.arn]
}

resource "aws_lakeformation_resource" "zones" {
  for_each = aws_s3_bucket.zones

  arn = each.value.arn
}
