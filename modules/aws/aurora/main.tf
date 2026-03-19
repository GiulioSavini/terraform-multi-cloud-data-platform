# -----------------------------------------------------------------------------
# AWS Aurora PostgreSQL Module
# Cluster with parameter groups, subnet group, KMS encryption, CloudWatch logs
# -----------------------------------------------------------------------------

locals {
  name_prefix = "${var.project_name}-${var.environment}"
}

# -----------------------------------------------------------------------------
# KMS Key for Encryption
# -----------------------------------------------------------------------------

resource "aws_kms_key" "aurora" {
  description             = "KMS key for Aurora PostgreSQL encryption - ${local.name_prefix}"
  deletion_window_in_days = 30
  enable_key_rotation     = true

  tags = merge(var.tags, {
    Name = "${local.name_prefix}-aurora-kms"
  })
}

resource "aws_kms_alias" "aurora" {
  name          = "alias/${local.name_prefix}-aurora"
  target_key_id = aws_kms_key.aurora.key_id
}

# -----------------------------------------------------------------------------
# Random Password
# -----------------------------------------------------------------------------

resource "random_password" "master" {
  length           = 32
  special          = true
  override_special = "!#$%&*()-_=+[]{}<>:?"
}

resource "aws_secretsmanager_secret" "aurora" {
  name_prefix             = "${local.name_prefix}-aurora-"
  description             = "Aurora PostgreSQL master credentials"
  recovery_window_in_days = 7
  kms_key_id              = aws_kms_key.aurora.arn

  tags = var.tags
}

resource "aws_secretsmanager_secret_version" "aurora" {
  secret_id = aws_secretsmanager_secret.aurora.id
  secret_string = jsonencode({
    username = var.master_username
    password = random_password.master.result
    engine   = "postgres"
    host     = aws_rds_cluster.main.endpoint
    port     = 5432
    dbname   = var.database_name
  })
}

# -----------------------------------------------------------------------------
# Subnet Group
# -----------------------------------------------------------------------------

resource "aws_db_subnet_group" "aurora" {
  name_prefix = "${local.name_prefix}-aurora-"
  description = "Subnet group for Aurora PostgreSQL"
  subnet_ids  = var.subnet_ids

  tags = merge(var.tags, {
    Name = "${local.name_prefix}-aurora-subnet-group"
  })
}

# -----------------------------------------------------------------------------
# Parameter Groups
# -----------------------------------------------------------------------------

resource "aws_rds_cluster_parameter_group" "aurora" {
  name_prefix = "${local.name_prefix}-aurora-cluster-"
  family      = "aurora-postgresql15"
  description = "Cluster parameter group for Aurora PostgreSQL"

  parameter {
    name  = "log_statement"
    value = "all"
  }

  parameter {
    name  = "log_min_duration_statement"
    value = "1000"
  }

  parameter {
    name  = "shared_preload_libraries"
    value = "pg_stat_statements,pgaudit"
  }

  parameter {
    name         = "rds.force_ssl"
    value        = "1"
    apply_method = "pending-reboot"
  }

  tags = var.tags

  lifecycle {
    create_before_destroy = true
  }
}

resource "aws_db_parameter_group" "aurora" {
  name_prefix = "${local.name_prefix}-aurora-db-"
  family      = "aurora-postgresql15"
  description = "DB parameter group for Aurora PostgreSQL instances"

  parameter {
    name  = "log_connections"
    value = "1"
  }

  parameter {
    name  = "log_disconnections"
    value = "1"
  }

  parameter {
    name  = "log_lock_waits"
    value = "1"
  }

  tags = var.tags

  lifecycle {
    create_before_destroy = true
  }
}

# -----------------------------------------------------------------------------
# Aurora Cluster
# -----------------------------------------------------------------------------

resource "aws_rds_cluster" "main" {
  cluster_identifier = "${local.name_prefix}-aurora"
  engine             = "aurora-postgresql"
  engine_version     = var.engine_version
  database_name      = var.database_name
  master_username    = var.master_username
  master_password    = random_password.master.result

  db_subnet_group_name            = aws_db_subnet_group.aurora.name
  vpc_security_group_ids          = var.security_group_ids
  db_cluster_parameter_group_name = aws_rds_cluster_parameter_group.aurora.name

  storage_encrypted                   = true
  kms_key_id                          = aws_kms_key.aurora.arn
  iam_database_authentication_enabled = true

  backup_retention_period      = var.backup_retention_period
  preferred_backup_window      = var.preferred_backup_window
  preferred_maintenance_window = var.preferred_maintenance_window
  copy_tags_to_snapshot        = true

  deletion_protection       = var.deletion_protection
  skip_final_snapshot       = var.environment != "prd"
  final_snapshot_identifier = var.environment == "prd" ? "${local.name_prefix}-aurora-final" : null

  enabled_cloudwatch_logs_exports = ["postgresql", "upgrade"]

  tags = merge(var.tags, {
    Name = "${local.name_prefix}-aurora"
  })
}

# -----------------------------------------------------------------------------
# Aurora Instances
# -----------------------------------------------------------------------------

resource "aws_rds_cluster_instance" "instances" {
  count = var.instance_count

  identifier           = "${local.name_prefix}-aurora-${count.index + 1}"
  cluster_identifier   = aws_rds_cluster.main.id
  instance_class       = var.instance_class
  engine               = aws_rds_cluster.main.engine
  engine_version       = aws_rds_cluster.main.engine_version
  db_parameter_group_name = aws_db_parameter_group.aurora.name
  publicly_accessible  = false

  performance_insights_enabled    = true
  performance_insights_kms_key_id = aws_kms_key.aurora.arn

  monitoring_interval = 60
  monitoring_role_arn = aws_iam_role.rds_monitoring.arn

  auto_minor_version_upgrade = true

  tags = merge(var.tags, {
    Name = "${local.name_prefix}-aurora-${count.index + 1}"
  })
}

# -----------------------------------------------------------------------------
# Enhanced Monitoring IAM Role
# -----------------------------------------------------------------------------

resource "aws_iam_role" "rds_monitoring" {
  name_prefix = "${local.name_prefix}-rds-mon-"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [{
      Action = "sts:AssumeRole"
      Effect = "Allow"
      Principal = {
        Service = "monitoring.rds.amazonaws.com"
      }
    }]
  })

  tags = var.tags
}

resource "aws_iam_role_policy_attachment" "rds_monitoring" {
  role       = aws_iam_role.rds_monitoring.name
  policy_arn = "arn:aws:iam::aws:policy/service-role/AmazonRDSEnhancedMonitoringRole"
}

# -----------------------------------------------------------------------------
# CloudWatch Alarms
# -----------------------------------------------------------------------------

resource "aws_cloudwatch_metric_alarm" "cpu" {
  alarm_name          = "${local.name_prefix}-aurora-cpu"
  comparison_operator = "GreaterThanThreshold"
  evaluation_periods  = 3
  metric_name         = "CPUUtilization"
  namespace           = "AWS/RDS"
  period              = 300
  statistic           = "Average"
  threshold           = 80
  alarm_description   = "Aurora cluster CPU utilization above 80%"

  dimensions = {
    DBClusterIdentifier = aws_rds_cluster.main.cluster_identifier
  }

  tags = var.tags
}

resource "aws_cloudwatch_metric_alarm" "freeable_memory" {
  alarm_name          = "${local.name_prefix}-aurora-memory"
  comparison_operator = "LessThanThreshold"
  evaluation_periods  = 3
  metric_name         = "FreeableMemory"
  namespace           = "AWS/RDS"
  period              = 300
  statistic           = "Average"
  threshold           = 256000000 # 256MB
  alarm_description   = "Aurora freeable memory below 256MB"

  dimensions = {
    DBClusterIdentifier = aws_rds_cluster.main.cluster_identifier
  }

  tags = var.tags
}
