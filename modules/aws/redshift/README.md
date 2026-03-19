# AWS Redshift Warehouse

Terraform module to provision an Amazon Redshift cluster for data warehousing with configurable node types, encryption, and VPC networking.

## Usage

```hcl
module "redshift" {
  source = "./modules/aws/redshift"

  cluster_identifier = "data-platform-redshift"
  database_name      = "warehouse"
  master_username    = "admin"
  node_type          = "ra3.xlplus"
  number_of_nodes    = 2

  vpc_id             = module.networking.vpc_id
  subnet_ids         = module.networking.private_subnet_ids
  allowed_cidr_blocks = ["10.0.0.0/16"]

  encrypted  = true
  kms_key_id = module.governance.kms_key_arn

  enhanced_vpc_routing = true

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
| `cluster_identifier` | Identifier for the Redshift cluster | `string` | n/a | yes |
| `database_name` | Name of the default database | `string` | `"warehouse"` | no |
| `master_username` | Master username | `string` | n/a | yes |
| `node_type` | Node type for the cluster | `string` | `"ra3.xlplus"` | no |
| `number_of_nodes` | Number of nodes in the cluster | `number` | `2` | no |
| `vpc_id` | VPC ID for the cluster | `string` | n/a | yes |
| `subnet_ids` | Subnet IDs for the subnet group | `list(string)` | n/a | yes |
| `allowed_cidr_blocks` | CIDR blocks allowed to connect | `list(string)` | `[]` | no |
| `encrypted` | Enable encryption at rest | `bool` | `true` | no |
| `kms_key_id` | KMS key ARN for encryption | `string` | `null` | no |
| `enhanced_vpc_routing` | Enable enhanced VPC routing | `bool` | `true` | no |
| `tags` | Resource tags | `map(string)` | `{}` | no |

## Outputs

| Name | Description |
|------|-------------|
| `cluster_endpoint` | Endpoint for the Redshift cluster |
| `cluster_arn` | ARN of the Redshift cluster |
| `cluster_id` | Identifier of the Redshift cluster |
| `database_name` | Name of the default database |
| `security_group_id` | Security group ID attached to the cluster |
