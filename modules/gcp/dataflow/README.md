# GCP Dataflow

Terraform module to provision Google Dataflow resources including service accounts, IAM bindings, staging and temp GCS buckets for Dataflow job execution.

## Usage

```hcl
module "dataflow" {
  source = "./modules/gcp/dataflow"

  project_id = var.gcp_project_id
  region     = "us-central1"

  service_account_name = "dataflow-worker"

  staging_bucket_name = "data-platform-dataflow-staging"
  temp_bucket_name    = "data-platform-dataflow-temp"

  network    = module.networking.vpc_name
  subnetwork = module.networking.private_subnet_name

  iam_roles = [
    "roles/dataflow.worker",
    "roles/storage.objectAdmin",
    "roles/bigquery.dataEditor",
    "roles/pubsub.subscriber",
  ]

  max_workers     = 10
  machine_type    = "n1-standard-4"
  enable_streaming_engine = true

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
| `service_account_name` | Name for the Dataflow service account | `string` | `"dataflow-worker"` | no |
| `staging_bucket_name` | GCS bucket for staging files | `string` | n/a | yes |
| `temp_bucket_name` | GCS bucket for temp files | `string` | n/a | yes |
| `network` | VPC network name | `string` | n/a | yes |
| `subnetwork` | Subnetwork name | `string` | n/a | yes |
| `iam_roles` | IAM roles to assign to the service account | `list(string)` | see above | no |
| `max_workers` | Maximum number of workers | `number` | `10` | no |
| `machine_type` | Machine type for workers | `string` | `"n1-standard-4"` | no |
| `enable_streaming_engine` | Enable Streaming Engine | `bool` | `true` | no |
| `labels` | Resource labels | `map(string)` | `{}` | no |

## Outputs

| Name | Description |
|------|-------------|
| `service_account_email` | Email of the Dataflow service account |
| `service_account_id` | ID of the Dataflow service account |
| `staging_bucket_name` | Name of the staging GCS bucket |
| `temp_bucket_name` | Name of the temp GCS bucket |
| `staging_bucket_url` | URL of the staging bucket (`gs://...`) |
