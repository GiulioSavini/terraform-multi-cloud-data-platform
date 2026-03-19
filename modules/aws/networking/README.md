# AWS VPC Networking

Terraform module to provision an AWS VPC with public and private subnets, NAT gateways, VPC endpoints for S3 and other AWS services, and configurable routing.

## Usage

```hcl
module "networking" {
  source = "./modules/aws/networking"

  vpc_cidr_block = "10.0.0.0/16"
  vpc_name       = "data-platform-vpc"

  availability_zones = ["us-east-1a", "us-east-1b", "us-east-1c"]

  private_subnet_cidrs = ["10.0.1.0/24", "10.0.2.0/24", "10.0.3.0/24"]
  public_subnet_cidrs  = ["10.0.101.0/24", "10.0.102.0/24", "10.0.103.0/24"]

  enable_nat_gateway   = true
  single_nat_gateway   = false

  vpc_endpoints = ["s3", "dynamodb", "glue", "kms", "logs"]

  enable_flow_logs         = true
  flow_log_retention_days  = 30

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
| `vpc_cidr_block` | CIDR block for the VPC | `string` | n/a | yes |
| `vpc_name` | Name for the VPC | `string` | n/a | yes |
| `availability_zones` | List of availability zones | `list(string)` | n/a | yes |
| `private_subnet_cidrs` | CIDR blocks for private subnets | `list(string)` | n/a | yes |
| `public_subnet_cidrs` | CIDR blocks for public subnets | `list(string)` | n/a | yes |
| `enable_nat_gateway` | Enable NAT gateway | `bool` | `true` | no |
| `single_nat_gateway` | Use a single NAT gateway for all AZs | `bool` | `false` | no |
| `vpc_endpoints` | List of VPC gateway/interface endpoints | `list(string)` | `["s3"]` | no |
| `enable_flow_logs` | Enable VPC flow logs | `bool` | `true` | no |
| `flow_log_retention_days` | CloudWatch log retention in days | `number` | `30` | no |
| `tags` | Resource tags | `map(string)` | `{}` | no |

## Outputs

| Name | Description |
|------|-------------|
| `vpc_id` | ID of the VPC |
| `vpc_cidr_block` | CIDR block of the VPC |
| `private_subnet_ids` | List of private subnet IDs |
| `public_subnet_ids` | List of public subnet IDs |
| `nat_gateway_ids` | List of NAT gateway IDs |
| `vpc_endpoint_ids` | Map of VPC endpoint IDs |
