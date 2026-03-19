# -----------------------------------------------------------------------------
# Staging Environment - AWS Modules
# Networking, Aurora, Data Lake, Glue, Redshift, MSK
# -----------------------------------------------------------------------------

module "aws_networking" {
  source = "../../modules/aws/networking"

  project_name         = var.project_name
  environment          = var.environment
  vpc_cidr             = var.aws_vpc_cidr
  private_subnet_cidrs = var.aws_private_subnet_cidrs
  aws_region           = var.aws_region
  tags                 = local.common_tags
}

module "aws_data_lake" {
  source = "../../modules/aws/data-lake"

  project_name = var.project_name
  environment  = var.environment
  tags         = local.common_tags
}

module "aws_aurora" {
  source = "../../modules/aws/aurora"

  project_name            = var.project_name
  environment             = var.environment
  subnet_ids              = module.aws_networking.private_subnet_ids
  security_group_ids      = [module.aws_networking.aurora_security_group_id]
  instance_class          = var.aurora_instance_class
  instance_count          = var.aurora_instance_count
  engine_version          = var.aurora_engine_version
  backup_retention_period = var.aurora_backup_retention
  tags                    = local.common_tags
}

module "aws_redshift" {
  source = "../../modules/aws/redshift"

  project_name       = var.project_name
  environment        = var.environment
  subnet_ids         = module.aws_networking.private_subnet_ids
  security_group_ids = [module.aws_networking.redshift_security_group_id]
  node_type          = var.redshift_node_type
  number_of_nodes    = var.redshift_number_of_nodes
  s3_data_lake_arn   = module.aws_data_lake.raw_bucket_arn
  tags               = local.common_tags
}

module "aws_glue" {
  source = "../../modules/aws/glue"

  project_name          = var.project_name
  environment           = var.environment
  s3_raw_path           = "s3://${module.aws_data_lake.raw_bucket_name}"
  s3_curated_path       = "s3://${module.aws_data_lake.curated_bucket_name}"
  s3_analytics_path     = "s3://${module.aws_data_lake.analytics_bucket_name}"
  data_lake_kms_key_arn = module.aws_data_lake.kms_key_arn
  subnet_id             = module.aws_networking.private_subnet_ids[0]
  security_group_ids    = [module.aws_networking.glue_security_group_id]
  tags                  = local.common_tags
}

module "aws_msk" {
  source = "../../modules/aws/msk"

  project_name       = var.project_name
  environment        = var.environment
  subnet_ids         = module.aws_networking.private_subnet_ids
  security_group_ids = [module.aws_networking.msk_security_group_id]
  instance_type      = var.msk_instance_type
  number_of_brokers  = var.msk_number_of_brokers
  ebs_volume_size    = var.msk_ebs_volume_size
  tags               = local.common_tags
}
