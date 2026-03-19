# AWS MSK Kafka Cluster

Terraform module to provision an Amazon Managed Streaming for Apache Kafka (MSK) cluster with configurable broker instances, encryption, and monitoring.

## Usage

```hcl
module "msk" {
  source = "./modules/aws/msk"

  cluster_name   = "data-platform-kafka"
  kafka_version  = "3.5.1"
  broker_count   = 3
  instance_type  = "kafka.m5.large"
  ebs_volume_size = 100

  vpc_id     = module.networking.vpc_id
  subnet_ids = module.networking.private_subnet_ids

  encryption_in_transit = "TLS"
  encryption_at_rest_kms_key_arn = module.governance.kms_key_arn

  enhanced_monitoring = "PER_TOPIC_PER_BROKER"

  allowed_cidr_blocks = ["10.0.0.0/16"]

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
| `cluster_name` | Name of the MSK cluster | `string` | n/a | yes |
| `kafka_version` | Apache Kafka version | `string` | `"3.5.1"` | no |
| `broker_count` | Number of broker nodes | `number` | `3` | no |
| `instance_type` | Instance type for brokers | `string` | `"kafka.m5.large"` | no |
| `ebs_volume_size` | EBS volume size in GB per broker | `number` | `100` | no |
| `vpc_id` | VPC ID for the cluster | `string` | n/a | yes |
| `subnet_ids` | Subnet IDs for broker placement | `list(string)` | n/a | yes |
| `encryption_in_transit` | Encryption in transit mode (`TLS`, `TLS_PLAINTEXT`, `PLAINTEXT`) | `string` | `"TLS"` | no |
| `encryption_at_rest_kms_key_arn` | KMS key ARN for encryption at rest | `string` | `null` | no |
| `enhanced_monitoring` | Monitoring level | `string` | `"PER_TOPIC_PER_BROKER"` | no |
| `allowed_cidr_blocks` | CIDR blocks allowed to connect | `list(string)` | `[]` | no |
| `tags` | Resource tags | `map(string)` | `{}` | no |

## Outputs

| Name | Description |
|------|-------------|
| `cluster_arn` | ARN of the MSK cluster |
| `bootstrap_brokers_tls` | TLS bootstrap broker connection string |
| `zookeeper_connect_string` | ZooKeeper connection string |
| `cluster_name` | Name of the MSK cluster |
| `security_group_id` | Security group ID attached to the cluster |
