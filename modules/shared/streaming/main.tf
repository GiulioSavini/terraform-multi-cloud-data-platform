locals {
  name_prefix = "${var.project}-${var.environment}"
}

# MSK Connect - Connector for cross-cloud replication
resource "aws_iam_role" "msk_connect" {
  name = "${local.name_prefix}-msk-connect-role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [{
      Action    = "sts:AssumeRole"
      Effect    = "Allow"
      Principal = { Service = "kafkaconnect.amazonaws.com" }
    }]
  })

  tags = var.tags
}

resource "aws_iam_role_policy" "msk_connect" {
  name = "msk-connect-policy"
  role = aws_iam_role.msk_connect.id

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Action = [
          "kafka-cluster:Connect",
          "kafka-cluster:DescribeCluster",
          "kafka-cluster:ReadData",
          "kafka-cluster:WriteData",
          "kafka-cluster:DescribeTopic",
          "kafka-cluster:CreateTopic",
          "kafka-cluster:DescribeGroup",
          "kafka-cluster:AlterGroup"
        ]
        Resource = var.msk_cluster_arn != "" ? [var.msk_cluster_arn, "${var.msk_cluster_arn}/*"] : ["*"]
      },
      {
        Effect   = "Allow"
        Action   = ["s3:GetObject", "s3:PutObject", "s3:ListBucket"]
        Resource = ["*"]
      }
    ]
  })
}

# S3 bucket for connector plugins
resource "aws_s3_bucket" "connector_plugins" {
  bucket        = "${local.name_prefix}-kafka-connectors-${data.aws_caller_identity.current.account_id}"
  force_destroy = var.environment != "prd"
  tags          = var.tags
}

resource "aws_s3_bucket_server_side_encryption_configuration" "connector_plugins" {
  bucket = aws_s3_bucket.connector_plugins.id
  rule {
    apply_server_side_encryption_by_default { sse_algorithm = "aws:kms" }
  }
}

resource "aws_s3_bucket_public_access_block" "connector_plugins" {
  bucket                  = aws_s3_bucket.connector_plugins.id
  block_public_acls       = true
  block_public_policy     = true
  ignore_public_acls      = true
  restrict_public_buckets = true
}

data "aws_caller_identity" "current" {}
