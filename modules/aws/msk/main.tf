# -----------------------------------------------------------------------------
# AWS MSK Module
# Managed Streaming for Apache Kafka - cluster, config, logging, encryption
# -----------------------------------------------------------------------------

locals {
  name_prefix = "${var.project_name}-${var.environment}"
}

# -----------------------------------------------------------------------------
# KMS Key
# -----------------------------------------------------------------------------

resource "aws_kms_key" "msk" {
  description             = "KMS key for MSK encryption - ${local.name_prefix}"
  deletion_window_in_days = 30
  enable_key_rotation     = true

  tags = merge(var.tags, {
    Name = "${local.name_prefix}-msk-kms"
  })
}

resource "aws_kms_alias" "msk" {
  name          = "alias/${local.name_prefix}-msk"
  target_key_id = aws_kms_key.msk.key_id
}

# -----------------------------------------------------------------------------
# CloudWatch Log Group
# -----------------------------------------------------------------------------

resource "aws_cloudwatch_log_group" "msk" {
  name              = "/aws/msk/${local.name_prefix}"
  retention_in_days = var.environment == "prd" ? 90 : 30
  kms_key_id        = aws_kms_key.msk.arn

  tags = var.tags
}

# -----------------------------------------------------------------------------
# S3 Bucket for MSK Logs
# -----------------------------------------------------------------------------

resource "aws_s3_bucket" "msk_logs" {
  bucket_prefix = "${local.name_prefix}-msk-logs-"
  force_destroy = var.environment != "prd"

  tags = merge(var.tags, {
    Name = "${local.name_prefix}-msk-logs"
  })
}

resource "aws_s3_bucket_server_side_encryption_configuration" "msk_logs" {
  bucket = aws_s3_bucket.msk_logs.id

  rule {
    apply_server_side_encryption_by_default {
      sse_algorithm     = "aws:kms"
      kms_master_key_id = aws_kms_key.msk.arn
    }
  }
}

resource "aws_s3_bucket_public_access_block" "msk_logs" {
  bucket = aws_s3_bucket.msk_logs.id

  block_public_acls       = true
  block_public_policy     = true
  ignore_public_acls      = true
  restrict_public_buckets = true
}

resource "aws_s3_bucket_lifecycle_configuration" "msk_logs" {
  bucket = aws_s3_bucket.msk_logs.id

  rule {
    id     = "log-retention"
    status = "Enabled"

    transition {
      days          = 30
      storage_class = "STANDARD_IA"
    }

    expiration {
      days = 90
    }
  }
}

# -----------------------------------------------------------------------------
# MSK Configuration
# -----------------------------------------------------------------------------

resource "aws_msk_configuration" "main" {
  name              = "${local.name_prefix}-msk-config"
  kafka_versions    = [var.kafka_version]
  description       = "MSK configuration for ${local.name_prefix}"

  server_properties = <<-PROPERTIES
    auto.create.topics.enable=true
    delete.topic.enable=true
    default.replication.factor=3
    min.insync.replicas=2
    num.partitions=6
    log.retention.hours=168
    log.retention.bytes=1073741824
    num.replica.fetchers=2
    replica.lag.time.max.ms=30000
    unclean.leader.election.enable=false
    log.message.timestamp.type=CreateTime
    log.cleanup.policy=delete
    compression.type=producer
  PROPERTIES
}

# -----------------------------------------------------------------------------
# MSK Cluster
# -----------------------------------------------------------------------------

resource "aws_msk_cluster" "main" {
  cluster_name           = "${local.name_prefix}-msk"
  kafka_version          = var.kafka_version
  number_of_broker_nodes = var.number_of_brokers

  broker_node_group_info {
    instance_type  = var.instance_type
    client_subnets = var.subnet_ids

    storage_info {
      ebs_storage_info {
        volume_size = var.ebs_volume_size
      }
    }

    security_groups = var.security_group_ids
  }

  configuration_info {
    arn      = aws_msk_configuration.main.arn
    revision = aws_msk_configuration.main.latest_revision
  }

  encryption_info {
    encryption_at_rest_kms_key_arn = aws_kms_key.msk.arn

    encryption_in_transit {
      client_broker = "TLS"
      in_cluster    = true
    }
  }

  client_authentication {
    sasl {
      iam = true
    }

    tls {}
  }

  logging_info {
    broker_logs {
      cloudwatch_logs {
        enabled   = true
        log_group = aws_cloudwatch_log_group.msk.name
      }

      s3_logs {
        enabled = true
        bucket  = aws_s3_bucket.msk_logs.id
        prefix  = "msk-broker-logs/"
      }
    }
  }

  open_monitoring {
    prometheus {
      jmx_exporter {
        enabled_in_broker = true
      }
      node_exporter {
        enabled_in_broker = true
      }
    }
  }

  tags = merge(var.tags, {
    Name = "${local.name_prefix}-msk"
  })
}
