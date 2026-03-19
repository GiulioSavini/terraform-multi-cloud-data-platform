# -----------------------------------------------------------------------------
# Shared Streaming Module
# Cross-cloud Kafka replication: MSK Connect, connector configuration
# -----------------------------------------------------------------------------

locals {
  name_prefix = "${var.project_name}-${var.environment}"
}

data "aws_caller_identity" "current" {}
data "aws_region" "current" {}

# -----------------------------------------------------------------------------
# MSK Connect - IAM Role for Connectors
# -----------------------------------------------------------------------------

resource "aws_iam_role" "msk_connect" {
  name_prefix = "${local.name_prefix}-msk-connect-"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [{
      Action = "sts:AssumeRole"
      Effect = "Allow"
      Principal = {
        Service = "kafkaconnect.amazonaws.com"
      }
    }]
  })

  tags = var.tags
}

resource "aws_iam_role_policy" "msk_connect_kafka" {
  name_prefix = "kafka-access-"
  role        = aws_iam_role.msk_connect.id

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
        Resource = [
          var.msk_cluster_arn,
          "${var.msk_cluster_arn}/*"
        ]
      },
      {
        Effect = "Allow"
        Action = [
          "s3:GetObject",
          "s3:PutObject",
          "s3:ListBucket",
          "s3:GetBucketLocation"
        ]
        Resource = [
          aws_s3_bucket.connector_plugins.arn,
          "${aws_s3_bucket.connector_plugins.arn}/*",
          aws_s3_bucket.connector_offsets.arn,
          "${aws_s3_bucket.connector_offsets.arn}/*"
        ]
      },
      {
        Effect = "Allow"
        Action = [
          "logs:CreateLogGroup",
          "logs:CreateLogStream",
          "logs:PutLogEvents",
          "logs:DescribeLogStreams"
        ]
        Resource = "arn:aws:logs:${data.aws_region.current.name}:${data.aws_caller_identity.current.account_id}:log-group:/aws/msk-connect/*"
      }
    ]
  })
}

# -----------------------------------------------------------------------------
# S3 Bucket for Connector Plugins
# -----------------------------------------------------------------------------

resource "aws_s3_bucket" "connector_plugins" {
  bucket_prefix = "${local.name_prefix}-kafka-plugins-"
  force_destroy = var.environment != "prd"

  tags = merge(var.tags, {
    Name = "${local.name_prefix}-kafka-connector-plugins"
  })
}

resource "aws_s3_bucket_server_side_encryption_configuration" "connector_plugins" {
  bucket = aws_s3_bucket.connector_plugins.id

  rule {
    apply_server_side_encryption_by_default {
      sse_algorithm = "aws:kms"
    }
  }
}

resource "aws_s3_bucket_public_access_block" "connector_plugins" {
  bucket = aws_s3_bucket.connector_plugins.id

  block_public_acls       = true
  block_public_policy     = true
  ignore_public_acls      = true
  restrict_public_buckets = true
}

resource "aws_s3_bucket_versioning" "connector_plugins" {
  bucket = aws_s3_bucket.connector_plugins.id

  versioning_configuration {
    status = "Enabled"
  }
}

# -----------------------------------------------------------------------------
# S3 Bucket for Connector Offsets
# -----------------------------------------------------------------------------

resource "aws_s3_bucket" "connector_offsets" {
  bucket_prefix = "${local.name_prefix}-kafka-offsets-"
  force_destroy = var.environment != "prd"

  tags = merge(var.tags, {
    Name = "${local.name_prefix}-kafka-connector-offsets"
  })
}

resource "aws_s3_bucket_server_side_encryption_configuration" "connector_offsets" {
  bucket = aws_s3_bucket.connector_offsets.id

  rule {
    apply_server_side_encryption_by_default {
      sse_algorithm = "aws:kms"
    }
  }
}

resource "aws_s3_bucket_public_access_block" "connector_offsets" {
  bucket = aws_s3_bucket.connector_offsets.id

  block_public_acls       = true
  block_public_policy     = true
  ignore_public_acls      = true
  restrict_public_buckets = true
}

# -----------------------------------------------------------------------------
# CloudWatch Log Group for MSK Connect
# -----------------------------------------------------------------------------

resource "aws_cloudwatch_log_group" "msk_connect" {
  name              = "/aws/msk-connect/${local.name_prefix}"
  retention_in_days = var.environment == "prd" ? 90 : 30

  tags = var.tags
}

# -----------------------------------------------------------------------------
# Secrets Manager - Cross-cloud connection strings
# -----------------------------------------------------------------------------

resource "aws_secretsmanager_secret" "eventhubs_connection" {
  name_prefix             = "${local.name_prefix}-eh-conn-"
  description             = "Azure Event Hubs connection string for cross-cloud replication"
  recovery_window_in_days = 7

  tags = var.tags
}

resource "aws_secretsmanager_secret_version" "eventhubs_connection" {
  secret_id = aws_secretsmanager_secret.eventhubs_connection.id
  secret_string = jsonencode({
    namespace         = var.eventhubs_namespace
    connection_string = var.eventhubs_connection_string
    kafka_endpoint    = "${var.eventhubs_namespace}.servicebus.windows.net:9093"
  })
}

resource "aws_secretsmanager_secret" "msk_connection" {
  name_prefix             = "${local.name_prefix}-msk-conn-"
  description             = "MSK bootstrap brokers for cross-cloud replication"
  recovery_window_in_days = 7

  tags = var.tags
}

resource "aws_secretsmanager_secret_version" "msk_connection" {
  secret_id = aws_secretsmanager_secret.msk_connection.id
  secret_string = jsonencode({
    bootstrap_brokers = var.msk_bootstrap_brokers
    cluster_arn       = var.msk_cluster_arn
  })
}

# -----------------------------------------------------------------------------
# Connector Configuration (stored as S3 objects for MSK Connect)
# -----------------------------------------------------------------------------

resource "aws_s3_object" "mirror_maker_config" {
  bucket = aws_s3_bucket.connector_plugins.id
  key    = "config/mirror-maker-eventhubs.json"
  content = jsonencode({
    name = "${local.name_prefix}-mm2-eventhubs"
    config = {
      "connector.class"                    = "org.apache.kafka.connect.mirror.MirrorSourceConnector"
      "source.cluster.alias"               = "msk"
      "target.cluster.alias"               = "eventhubs"
      "source.cluster.bootstrap.servers"   = var.msk_bootstrap_brokers
      "target.cluster.bootstrap.servers"   = "${var.eventhubs_namespace}.servicebus.windows.net:9093"
      "topics"                             = "events,metrics,commands"
      "replication.factor"                 = "1"
      "tasks.max"                          = "3"
      "key.converter"                      = "org.apache.kafka.connect.converters.ByteArrayConverter"
      "value.converter"                    = "org.apache.kafka.connect.converters.ByteArrayConverter"
      "offset.storage.topic"               = "mm2-offsets"
      "status.storage.topic"               = "mm2-status"
      "config.storage.topic"               = "mm2-config"
      "source.cluster.security.protocol"   = "SSL"
      "target.cluster.security.protocol"   = "SASL_SSL"
      "target.cluster.sasl.mechanism"      = "PLAIN"
    }
  })

  tags = var.tags
}
