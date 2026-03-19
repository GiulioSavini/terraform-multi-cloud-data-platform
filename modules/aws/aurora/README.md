# AWS Aurora PostgreSQL Cluster

Terraform module to provision an Amazon Aurora PostgreSQL-compatible cluster with configurable instance classes, automated backups, and encryption at rest.

## Usage

```hcl
module "aurora" {
  source = "./modules/aws/aurora"

  cluster_identifier = "data-platform-aurora"
  engine_version     = "15.4"
  instance_class     = "db.r6g.large"
  instance_count     = 2

  database_name   = "analytics"
  master_username = "admin"

  vpc_id             = module.networking.vpc_id
  subnet_ids         = module.networking.private_subnet_ids
  allowed_cidr_blocks = ["10.0.0.0/16"]

  backup_retention_period = 7
  deletion_protection     = true
  storage_encrypted       = true
  kms_key_id              = module.governance.kms_key_arn

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
| `cluster_identifier` | Identifier for the Aurora cluster | `string` | n/a | yes |
| `engine_version` | Aurora PostgreSQL engine version | `string` | `"15.4"` | no |
| `instance_class` | Instance class for cluster instances | `string` | `"db.r6g.large"` | no |
| `instance_count` | Number of cluster instances | `number` | `2` | no |
| `database_name` | Name of the default database | `string` | n/a | yes |
| `master_username` | Master username for the cluster | `string` | n/a | yes |
| `vpc_id` | VPC ID for the cluster | `string` | n/a | yes |
| `subnet_ids` | List of subnet IDs for the DB subnet group | `list(string)` | n/a | yes |
| `allowed_cidr_blocks` | CIDR blocks allowed to connect | `list(string)` | `[]` | no |
| `backup_retention_period` | Days to retain backups | `number` | `7` | no |
| `deletion_protection` | Enable deletion protection | `bool` | `true` | no |
| `storage_encrypted` | Enable encryption at rest | `bool` | `true` | no |
| `kms_key_id` | KMS key ARN for encryption | `string` | `null` | no |
| `tags` | Resource tags | `map(string)` | `{}` | no |

## Outputs

| Name | Description |
|------|-------------|
| `cluster_endpoint` | Writer endpoint for the Aurora cluster |
| `reader_endpoint` | Reader endpoint for the Aurora cluster |
| `cluster_arn` | ARN of the Aurora cluster |
| `cluster_id` | Identifier of the Aurora cluster |
| `security_group_id` | Security group ID attached to the cluster |
