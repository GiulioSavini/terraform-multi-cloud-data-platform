# AWS S3 Data Lake

Terraform module to provision an S3-based data lake with lifecycle policies, versioning, encryption, and organized bucket structure for raw, processed, and curated data tiers.

## Usage

```hcl
module "data_lake" {
  source = "./modules/aws/data-lake"

  bucket_prefix = "data-platform"
  environment   = "production"

  enable_versioning = true
  encryption_type   = "aws:kms"
  kms_key_id        = module.governance.kms_key_arn

  lifecycle_rules = {
    raw = {
      transition_glacier_days = 90
      expiration_days         = 365
    }
    processed = {
      transition_glacier_days = 180
      expiration_days         = 730
    }
    curated = {
      transition_glacier_days = 365
      expiration_days         = null
    }
  }

  block_public_access = true

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
| `bucket_prefix` | Prefix for S3 bucket names | `string` | n/a | yes |
| `environment` | Environment name | `string` | n/a | yes |
| `enable_versioning` | Enable bucket versioning | `bool` | `true` | no |
| `encryption_type` | Encryption type (`aws:kms` or `AES256`) | `string` | `"aws:kms"` | no |
| `kms_key_id` | KMS key ARN for encryption | `string` | `null` | no |
| `lifecycle_rules` | Lifecycle rules per data tier | `map(object)` | `{}` | no |
| `block_public_access` | Block all public access | `bool` | `true` | no |
| `tags` | Resource tags | `map(string)` | `{}` | no |

## Outputs

| Name | Description |
|------|-------------|
| `raw_bucket_id` | ID of the raw data bucket |
| `raw_bucket_arn` | ARN of the raw data bucket |
| `processed_bucket_id` | ID of the processed data bucket |
| `processed_bucket_arn` | ARN of the processed data bucket |
| `curated_bucket_id` | ID of the curated data bucket |
| `curated_bucket_arn` | ARN of the curated data bucket |
