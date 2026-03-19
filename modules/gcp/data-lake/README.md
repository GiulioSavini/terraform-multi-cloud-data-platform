# GCP GCS Data Lake

Terraform module to provision Google Cloud Storage buckets for a data lake architecture with lifecycle management, versioning, and uniform bucket-level access.

## Usage

```hcl
module "data_lake" {
  source = "./modules/gcp/data-lake"

  project_id = var.gcp_project_id
  region     = "us-central1"

  bucket_prefix = "data-platform"

  buckets = {
    raw = {
      storage_class = "STANDARD"
      versioning    = true
    }
    processed = {
      storage_class = "STANDARD"
      versioning    = true
    }
    curated = {
      storage_class = "STANDARD"
      versioning    = true
    }
  }

  lifecycle_rules = {
    raw = [
      {
        action_type   = "SetStorageClass"
        storage_class = "NEARLINE"
        age           = 30
      },
      {
        action_type   = "SetStorageClass"
        storage_class = "COLDLINE"
        age           = 90
      },
      {
        action_type = "Delete"
        age         = 365
      }
    ]
    processed = [
      {
        action_type   = "SetStorageClass"
        storage_class = "NEARLINE"
        age           = 60
      }
    ]
  }

  uniform_bucket_level_access = true

  encryption_key = module.governance.kms_key_id

  labels = {
    project     = "data-platform"
    environment = "production"
    managed_by  = "terraform"
  }
}
```

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|----------|
| `project_id` | GCP project ID | `string` | n/a | yes |
| `region` | GCP region | `string` | n/a | yes |
| `bucket_prefix` | Prefix for bucket names | `string` | n/a | yes |
| `buckets` | Map of bucket configurations | `map(object)` | n/a | yes |
| `lifecycle_rules` | Map of lifecycle rules per bucket | `map(list(object))` | `{}` | no |
| `uniform_bucket_level_access` | Enable uniform bucket-level access | `bool` | `true` | no |
| `encryption_key` | KMS encryption key for buckets | `string` | `null` | no |
| `labels` | Resource labels | `map(string)` | `{}` | no |

## Outputs

| Name | Description |
|------|-------------|
| `bucket_names` | Map of bucket names |
| `bucket_urls` | Map of bucket URLs (`gs://...`) |
| `bucket_self_links` | Map of bucket self-links |
| `raw_bucket_name` | Name of the raw data bucket |
| `processed_bucket_name` | Name of the processed data bucket |
| `curated_bucket_name` | Name of the curated data bucket |
