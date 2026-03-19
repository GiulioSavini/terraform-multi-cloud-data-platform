# -----------------------------------------------------------------------------
# AWS Glue Module
# Catalog database, crawlers, ETL job, connection, IAM role
# -----------------------------------------------------------------------------

locals {
  name_prefix = "${var.project_name}-${var.environment}"
  zones = {
    raw       = var.s3_raw_path
    curated   = var.s3_curated_path
    analytics = var.s3_analytics_path
  }
}

data "aws_caller_identity" "current" {}
data "aws_region" "current" {}

# -----------------------------------------------------------------------------
# IAM Role for Glue
# -----------------------------------------------------------------------------

resource "aws_iam_role" "glue" {
  name_prefix = "${local.name_prefix}-glue-"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [{
      Action = "sts:AssumeRole"
      Effect = "Allow"
      Principal = {
        Service = "glue.amazonaws.com"
      }
    }]
  })

  tags = var.tags
}

resource "aws_iam_role_policy_attachment" "glue_service" {
  role       = aws_iam_role.glue.name
  policy_arn = "arn:aws:iam::aws:policy/service-role/AWSGlueServiceRole"
}

resource "aws_iam_role_policy" "glue_s3" {
  name_prefix = "s3-access-"
  role        = aws_iam_role.glue.id

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Action = [
          "s3:GetObject",
          "s3:PutObject",
          "s3:DeleteObject",
          "s3:ListBucket",
          "s3:GetBucketLocation"
        ]
        Resource = [
          "${replace(var.s3_raw_path, "s3://", "arn:aws:s3:::")}",
          "${replace(var.s3_raw_path, "s3://", "arn:aws:s3:::")}/*",
          "${replace(var.s3_curated_path, "s3://", "arn:aws:s3:::")}",
          "${replace(var.s3_curated_path, "s3://", "arn:aws:s3:::")}/*",
          "${replace(var.s3_analytics_path, "s3://", "arn:aws:s3:::")}",
          "${replace(var.s3_analytics_path, "s3://", "arn:aws:s3:::")}/*"
        ]
      },
      {
        Effect = "Allow"
        Action = [
          "kms:Decrypt",
          "kms:Encrypt",
          "kms:GenerateDataKey",
          "kms:DescribeKey"
        ]
        Resource = [var.data_lake_kms_key_arn]
      },
      {
        Effect = "Allow"
        Action = [
          "logs:CreateLogGroup",
          "logs:CreateLogStream",
          "logs:PutLogEvents"
        ]
        Resource = "arn:aws:logs:${data.aws_region.current.name}:${data.aws_caller_identity.current.account_id}:log-group:/aws-glue/*"
      }
    ]
  })
}

# -----------------------------------------------------------------------------
# Glue Catalog Database
# -----------------------------------------------------------------------------

resource "aws_glue_catalog_database" "main" {
  name        = replace("${local.name_prefix}-catalog", "-", "_")
  description = "Data lake catalog database for ${var.project_name} ${var.environment}"

  create_table_default_permission {
    permissions = ["ALL"]

    principal {
      data_lake_principal_identifier = "IAM_ALLOWED_PRINCIPALS"
    }
  }
}

# -----------------------------------------------------------------------------
# Glue Connection (VPC)
# -----------------------------------------------------------------------------

resource "aws_glue_connection" "main" {
  name            = "${local.name_prefix}-connection"
  connection_type = "NETWORK"

  physical_connection_requirements {
    availability_zone      = data.aws_subnet.glue.availability_zone
    security_group_id_list = var.security_group_ids
    subnet_id              = var.subnet_id
  }

  tags = var.tags
}

data "aws_subnet" "glue" {
  id = var.subnet_id
}

# -----------------------------------------------------------------------------
# Glue Crawlers
# -----------------------------------------------------------------------------

resource "aws_glue_crawler" "zones" {
  for_each = local.zones

  name          = "${local.name_prefix}-crawler-${each.key}"
  database_name = aws_glue_catalog_database.main.name
  role          = aws_iam_role.glue.arn
  description   = "Crawler for ${each.key} data zone"

  s3_target {
    path = each.value
  }

  schema_change_policy {
    delete_behavior = "LOG"
    update_behavior = "UPDATE_IN_DATABASE"
  }

  configuration = jsonencode({
    Version = 1.0
    Grouping = {
      TableGroupingPolicy = "CombineCompatibleSchemas"
    }
    CrawlerOutput = {
      Partitions = {
        AddOrUpdateBehavior = "InheritFromTable"
      }
    }
  })

  tags = merge(var.tags, {
    DataZone = each.key
  })
}

# -----------------------------------------------------------------------------
# Glue Scripts Bucket
# -----------------------------------------------------------------------------

resource "aws_s3_bucket" "glue_scripts" {
  bucket_prefix = "${local.name_prefix}-glue-scripts-"
  force_destroy = var.environment != "prd"

  tags = merge(var.tags, {
    Name = "${local.name_prefix}-glue-scripts"
  })
}

resource "aws_s3_bucket_server_side_encryption_configuration" "glue_scripts" {
  bucket = aws_s3_bucket.glue_scripts.id

  rule {
    apply_server_side_encryption_by_default {
      sse_algorithm     = "aws:kms"
      kms_master_key_id = var.data_lake_kms_key_arn
    }
  }
}

resource "aws_s3_bucket_public_access_block" "glue_scripts" {
  bucket = aws_s3_bucket.glue_scripts.id

  block_public_acls       = true
  block_public_policy     = true
  ignore_public_acls      = true
  restrict_public_buckets = true
}

resource "aws_s3_object" "etl_script" {
  bucket  = aws_s3_bucket.glue_scripts.id
  key     = "scripts/raw_to_curated.py"
  content = <<-PYTHON
import sys
from awsglue.transforms import *
from awsglue.utils import getResolvedOptions
from pyspark.context import SparkContext
from awsglue.context import GlueContext
from awsglue.job import Job
from awsglue.dynamicframe import DynamicFrame

args = getResolvedOptions(sys.argv, ['JOB_NAME', 'SOURCE_DATABASE', 'SOURCE_TABLE', 'TARGET_PATH'])

sc = SparkContext()
glueContext = GlueContext(sc)
spark = glueContext.spark_session
job = Job(glueContext)
job.init(args['JOB_NAME'], args)

datasource = glueContext.create_dynamic_frame.from_catalog(
    database=args['SOURCE_DATABASE'],
    table_name=args['SOURCE_TABLE']
)

transformed = datasource.toDF()
transformed = transformed.dropDuplicates()
transformed = transformed.na.drop()

output = DynamicFrame.fromDF(transformed, glueContext, "output")

glueContext.write_dynamic_frame.from_options(
    frame=output,
    connection_type="s3",
    connection_options={"path": args['TARGET_PATH']},
    format="parquet"
)

job.commit()
PYTHON

  tags = var.tags
}

# -----------------------------------------------------------------------------
# Glue Security Configuration
# -----------------------------------------------------------------------------

resource "aws_glue_security_configuration" "main" {
  name = "${local.name_prefix}-glue-security"

  encryption_configuration {
    cloudwatch_encryption {
      cloudwatch_encryption_mode = "SSE-KMS"
      kms_key_arn                = var.data_lake_kms_key_arn
    }

    job_bookmarks_encryption {
      job_bookmarks_encryption_mode = "CSE-KMS"
      kms_key_arn                   = var.data_lake_kms_key_arn
    }

    s3_encryption {
      s3_encryption_mode = "SSE-KMS"
      kms_key_arn        = var.data_lake_kms_key_arn
    }
  }
}

# -----------------------------------------------------------------------------
# Glue ETL Job
# -----------------------------------------------------------------------------

resource "aws_glue_job" "raw_to_curated" {
  name         = "${local.name_prefix}-raw-to-curated"
  role_arn     = aws_iam_role.glue.arn
  glue_version = var.glue_version
  max_capacity = var.max_capacity
  description  = "ETL job to transform raw data to curated zone"

  command {
    script_location = "s3://${aws_s3_bucket.glue_scripts.id}/${aws_s3_object.etl_script.key}"
    python_version  = "3"
  }

  default_arguments = {
    "--job-language"                     = "python"
    "--job-bookmark-option"              = "job-bookmark-enable"
    "--enable-continuous-cloudwatch-log"  = "true"
    "--enable-metrics"                   = "true"
    "--enable-spark-ui"                  = "true"
    "--spark-event-logs-path"            = "s3://${aws_s3_bucket.glue_scripts.id}/spark-logs/"
    "--TempDir"                          = "s3://${aws_s3_bucket.glue_scripts.id}/temp/"
    "--SOURCE_DATABASE"                  = aws_glue_catalog_database.main.name
    "--SOURCE_TABLE"                     = "raw"
    "--TARGET_PATH"                      = var.s3_curated_path
    "--encryption-type"                  = "sse-kms"
    "--security-configuration"           = aws_glue_security_configuration.main.name
  }

  connections = [aws_glue_connection.main.name]

  execution_property {
    max_concurrent_runs = 1
  }

  tags = var.tags
}
