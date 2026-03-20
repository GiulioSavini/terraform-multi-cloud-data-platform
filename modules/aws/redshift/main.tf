# -----------------------------------------------------------------------------
# AWS Redshift Module
# Cluster with parameter group, subnet group, IAM role, logging, encryption
# -----------------------------------------------------------------------------

locals {
  name_prefix  = "${var.project_name}-${var.environment}"
  cluster_type = var.number_of_nodes > 1 ? "multi-node" : "single-node"
}

# -----------------------------------------------------------------------------
# KMS Key
# -----------------------------------------------------------------------------

resource "aws_kms_key" "redshift" {
  description             = "KMS key for Redshift encryption - ${local.name_prefix}"
  deletion_window_in_days = 30
  enable_key_rotation     = true

  tags = merge(var.tags, {
    Name = "${local.name_prefix}-redshift-kms"
  })
}

resource "aws_kms_alias" "redshift" {
  name          = "alias/${local.name_prefix}-redshift"
  target_key_id = aws_kms_key.redshift.key_id
}

# -----------------------------------------------------------------------------
# Random Password
# -----------------------------------------------------------------------------

resource "random_password" "master" {
  length           = 32
  special          = true
  override_special = "!#$%&*()-_=+[]{}<>:?"
}

resource "aws_secretsmanager_secret" "redshift" {
  name_prefix             = "${local.name_prefix}-redshift-"
  description             = "Redshift master credentials"
  recovery_window_in_days = 7
  kms_key_id              = aws_kms_key.redshift.arn

  tags = var.tags
}

resource "aws_secretsmanager_secret_version" "redshift" {
  secret_id = aws_secretsmanager_secret.redshift.id
  secret_string = jsonencode({
    username = var.master_username
    password = random_password.master.result
    engine   = "redshift"
    host     = aws_redshift_cluster.main.endpoint
    port     = 5439
    dbname   = var.database_name
  })
}

# -----------------------------------------------------------------------------
# Subnet Group
# -----------------------------------------------------------------------------

resource "aws_redshift_subnet_group" "main" {
  name       = "${local.name_prefix}-redshift"
  subnet_ids = var.subnet_ids

  tags = merge(var.tags, {
    Name = "${local.name_prefix}-redshift-subnet-group"
  })
}

# -----------------------------------------------------------------------------
# Parameter Group
# -----------------------------------------------------------------------------

resource "aws_redshift_parameter_group" "main" {
  name   = "${local.name_prefix}-redshift"
  family = "redshift-1.0"

  parameter {
    name  = "require_ssl"
    value = "true"
  }

  parameter {
    name  = "enable_user_activity_logging"
    value = "true"
  }

  parameter {
    name  = "max_concurrency_scaling_clusters"
    value = "1"
  }

  tags = var.tags
}

# -----------------------------------------------------------------------------
# IAM Role for Spectrum/S3 Access
# -----------------------------------------------------------------------------

resource "aws_iam_role" "redshift" {
  name_prefix = "${local.name_prefix}-redshift-"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [{
      Action = "sts:AssumeRole"
      Effect = "Allow"
      Principal = {
        Service = "redshift.amazonaws.com"
      }
    }]
  })

  tags = var.tags
}

resource "aws_iam_role_policy" "redshift_s3" {
  name_prefix = "s3-access-"
  role        = aws_iam_role.redshift.id

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Action = [
          "s3:GetObject",
          "s3:ListBucket",
          "s3:GetBucketLocation"
        ]
        Resource = [
          var.s3_data_lake_arn,
          "${var.s3_data_lake_arn}/*"
        ]
      },
      {
        Effect = "Allow"
        Action = [
          "glue:GetTable",
          "glue:GetTables",
          "glue:GetDatabase",
          "glue:GetDatabases",
          "glue:GetPartition",
          "glue:GetPartitions",
          "glue:BatchGetPartition"
        ]
        Resource = ["*"]
      }
    ]
  })
}

# -----------------------------------------------------------------------------
# Logging Bucket
# -----------------------------------------------------------------------------

resource "aws_s3_bucket" "redshift_logs" {
  bucket_prefix = "${local.name_prefix}-rs-logs-"
  force_destroy = var.environment != "prd"

  tags = merge(var.tags, {
    Name = "${local.name_prefix}-redshift-logs"
  })
}

resource "aws_s3_bucket_server_side_encryption_configuration" "redshift_logs" {
  bucket = aws_s3_bucket.redshift_logs.id

  rule {
    apply_server_side_encryption_by_default {
      sse_algorithm     = "aws:kms"
      kms_master_key_id = aws_kms_key.redshift.arn
    }
  }
}

resource "aws_s3_bucket_public_access_block" "redshift_logs" {
  bucket = aws_s3_bucket.redshift_logs.id

  block_public_acls       = true
  block_public_policy     = true
  ignore_public_acls      = true
  restrict_public_buckets = true
}

resource "aws_s3_bucket_lifecycle_configuration" "redshift_logs" {
  bucket = aws_s3_bucket.redshift_logs.id

  rule {
    id     = "log-retention"
    status = "Enabled"

    abort_incomplete_multipart_upload {
      days_after_initiation = 7
    }

    expiration {
      days = 90
    }
  }
}

resource "aws_s3_bucket_policy" "redshift_logs" {
  bucket = aws_s3_bucket.redshift_logs.id

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [{
      Sid    = "RedshiftLogging"
      Effect = "Allow"
      Principal = {
        Service = "redshift.amazonaws.com"
      }
      Action   = "s3:PutObject"
      Resource = "${aws_s3_bucket.redshift_logs.arn}/*"
    }, {
      Sid    = "RedshiftGetBucketAcl"
      Effect = "Allow"
      Principal = {
        Service = "redshift.amazonaws.com"
      }
      Action   = "s3:GetBucketAcl"
      Resource = aws_s3_bucket.redshift_logs.arn
    }]
  })
}

# -----------------------------------------------------------------------------
# Redshift Cluster
# -----------------------------------------------------------------------------

resource "aws_redshift_cluster" "main" {
  cluster_identifier = "${local.name_prefix}-redshift"
  database_name      = var.database_name
  master_username    = var.master_username
  master_password    = random_password.master.result

  node_type       = var.node_type
  number_of_nodes = var.number_of_nodes
  cluster_type    = local.cluster_type

  cluster_subnet_group_name    = aws_redshift_subnet_group.main.name
  cluster_parameter_group_name = aws_redshift_parameter_group.main.name
  vpc_security_group_ids       = var.security_group_ids
  iam_roles                    = [aws_iam_role.redshift.arn]

  encrypted  = true
  kms_key_id = aws_kms_key.redshift.arn

  publicly_accessible  = false
  enhanced_vpc_routing = true

  logging {
    enable               = true
    bucket_name          = aws_s3_bucket.redshift_logs.id
    s3_key_prefix        = "redshift-logs/"
    log_destination_type = "s3"
    log_exports          = ["connectionlog", "userlog", "useractivitylog"]
  }

  automated_snapshot_retention_period = var.environment == "prd" ? 35 : 7
  preferred_maintenance_window        = "sun:04:00-sun:05:00"

  skip_final_snapshot       = var.environment != "prd"
  final_snapshot_identifier = var.environment == "prd" ? "${local.name_prefix}-redshift-final" : null

  tags = merge(var.tags, {
    Name = "${local.name_prefix}-redshift"
  })

  depends_on = [aws_s3_bucket_policy.redshift_logs]
}
