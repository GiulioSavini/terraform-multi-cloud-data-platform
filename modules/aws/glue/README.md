# AWS Glue ETL

Terraform module to provision AWS Glue resources including ETL jobs, crawlers, and a Data Catalog database for schema discovery and data transformation.

## Usage

```hcl
module "glue" {
  source = "./modules/aws/glue"

  catalog_database_name = "data_platform_catalog"

  crawlers = {
    raw_crawler = {
      s3_target_path = "s3://data-platform-raw/data/"
      schedule       = "cron(0 */6 * * ? *)"
      classifiers    = []
    }
  }

  etl_jobs = {
    transform_raw = {
      script_location   = "s3://data-platform-scripts/transform_raw.py"
      worker_type       = "G.1X"
      number_of_workers = 4
      glue_version      = "4.0"
      max_retries       = 1
      timeout           = 60
    }
  }

  iam_role_arn = module.governance.glue_role_arn

  tags = {
    project     = "data-platform"
    environment = "production"
    managed_by  = "terraform"
  }
}
```

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|----------|
| `catalog_database_name` | Name of the Glue Catalog database | `string` | n/a | yes |
| `crawlers` | Map of crawler configurations | `map(object)` | `{}` | no |
| `etl_jobs` | Map of ETL job configurations | `map(object)` | `{}` | no |
| `iam_role_arn` | IAM role ARN for Glue jobs and crawlers | `string` | n/a | yes |
| `security_configuration` | Name of the Glue security configuration | `string` | `null` | no |
| `tags` | Resource tags | `map(string)` | `{}` | no |

## Outputs

| Name | Description |
|------|-------------|
| `catalog_database_name` | Name of the Glue Catalog database |
| `catalog_database_arn` | ARN of the Glue Catalog database |
| `crawler_names` | Map of crawler names |
| `etl_job_names` | Map of ETL job names |
| `etl_job_arns` | Map of ETL job ARNs |
