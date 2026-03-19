# GCP CloudSQL PostgreSQL

Terraform module to provision a Google CloudSQL PostgreSQL instance with high availability, automated backups, private networking, and configurable maintenance windows.

## Usage

```hcl
module "cloudsql" {
  source = "./modules/gcp/cloudsql"

  instance_name    = "data-platform-postgres"
  project_id       = var.gcp_project_id
  region           = "us-central1"
  database_version = "POSTGRES_15"

  tier             = "db-custom-4-16384"
  availability_type = "REGIONAL"
  disk_size        = 100
  disk_type        = "PD_SSD"

  database_name = "analytics"

  private_network = module.networking.vpc_id

  backup_configuration = {
    enabled                        = true
    point_in_time_recovery_enabled = true
    start_time                     = "03:00"
    transaction_log_retention_days = 7
    retained_backups               = 14
  }

  maintenance_window = {
    day          = 7
    hour         = 4
    update_track = "stable"
  }

  database_flags = {
    "log_checkpoints"       = "on"
    "log_connections"       = "on"
    "log_disconnections"    = "on"
    "log_lock_waits"        = "on"
    "log_min_duration_statement" = "1000"
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
| `instance_name` | Name of the CloudSQL instance | `string` | n/a | yes |
| `project_id` | GCP project ID | `string` | n/a | yes |
| `region` | GCP region | `string` | n/a | yes |
| `database_version` | PostgreSQL version | `string` | `"POSTGRES_15"` | no |
| `tier` | Machine type tier | `string` | `"db-custom-4-16384"` | no |
| `availability_type` | Availability type (`ZONAL` or `REGIONAL`) | `string` | `"REGIONAL"` | no |
| `disk_size` | Disk size in GB | `number` | `100` | no |
| `disk_type` | Disk type (`PD_SSD` or `PD_HDD`) | `string` | `"PD_SSD"` | no |
| `database_name` | Name of the default database | `string` | n/a | yes |
| `private_network` | VPC network ID for private IP | `string` | n/a | yes |
| `backup_configuration` | Backup configuration object | `object` | see above | no |
| `maintenance_window` | Maintenance window configuration | `object` | `null` | no |
| `database_flags` | Map of database flags | `map(string)` | `{}` | no |
| `labels` | Resource labels | `map(string)` | `{}` | no |

## Outputs

| Name | Description |
|------|-------------|
| `instance_name` | Name of the CloudSQL instance |
| `connection_name` | Connection name for Cloud SQL Proxy |
| `private_ip_address` | Private IP address of the instance |
| `database_name` | Name of the default database |
| `instance_self_link` | Self-link of the instance |
