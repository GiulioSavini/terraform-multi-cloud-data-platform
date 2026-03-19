# GCP BigQuery

Terraform module to provision Google BigQuery datasets, tables, views, and scheduled queries with configurable access controls and partitioning strategies.

## Usage

```hcl
module "bigquery" {
  source = "./modules/gcp/bigquery"

  project_id = var.gcp_project_id
  location   = "US"

  datasets = {
    raw = {
      description                = "Raw data ingested from sources"
      default_table_expiration_ms = null
      delete_contents_on_destroy  = false
    }
    analytics = {
      description                = "Transformed analytics datasets"
      default_table_expiration_ms = null
      delete_contents_on_destroy  = false
    }
  }

  scheduled_queries = {
    daily_aggregation = {
      display_name = "Daily Aggregation"
      dataset_id   = "analytics"
      schedule     = "every 24 hours"
      query        = "SELECT DATE(timestamp) as date, COUNT(*) as count FROM raw.events GROUP BY 1"
    }
  }

  access_roles = {
    data_engineers = {
      role          = "WRITER"
      group_by_email = "data-engineers@company.com"
    }
    data_analysts = {
      role          = "READER"
      group_by_email = "data-analysts@company.com"
    }
  }

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
| `location` | BigQuery dataset location | `string` | `"US"` | no |
| `datasets` | Map of dataset configurations | `map(object)` | n/a | yes |
| `scheduled_queries` | Map of scheduled query configurations | `map(object)` | `{}` | no |
| `access_roles` | Map of dataset access role bindings | `map(object)` | `{}` | no |
| `default_encryption_key` | Default KMS encryption key | `string` | `null` | no |
| `labels` | Resource labels | `map(string)` | `{}` | no |

## Outputs

| Name | Description |
|------|-------------|
| `dataset_ids` | Map of dataset IDs |
| `dataset_self_links` | Map of dataset self-links |
| `scheduled_query_names` | Map of scheduled query display names |
| `project_id` | GCP project ID |
| `location` | BigQuery location |
