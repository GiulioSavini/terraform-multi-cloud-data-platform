# GCP VPC Networking

Terraform module to provision a Google Cloud VPC network with subnets, Cloud NAT, Cloud Router, and firewall rules for data platform services.

## Usage

```hcl
module "networking" {
  source = "./modules/gcp/networking"

  project_id = var.gcp_project_id
  region     = "us-central1"

  network_name = "data-platform-vpc"
  routing_mode = "REGIONAL"

  subnets = {
    private = {
      ip_cidr_range            = "10.2.1.0/24"
      private_ip_google_access = true
    }
    public = {
      ip_cidr_range            = "10.2.100.0/24"
      private_ip_google_access = false
    }
    gke = {
      ip_cidr_range            = "10.2.2.0/24"
      private_ip_google_access = true
      secondary_ranges = {
        pods     = "10.10.0.0/16"
        services = "10.20.0.0/20"
      }
    }
  }

  enable_cloud_nat = true
  cloud_nat_name   = "data-platform-nat"

  firewall_rules = {
    allow_internal = {
      direction   = "INGRESS"
      ranges      = ["10.2.0.0/16"]
      allow_rules = [{ protocol = "tcp", ports = ["0-65535"] }]
    }
    allow_health_checks = {
      direction   = "INGRESS"
      ranges      = ["130.211.0.0/22", "35.191.0.0/16"]
      allow_rules = [{ protocol = "tcp", ports = ["80", "443"] }]
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
| `region` | GCP region | `string` | n/a | yes |
| `network_name` | Name of the VPC network | `string` | n/a | yes |
| `routing_mode` | Network routing mode (`REGIONAL` or `GLOBAL`) | `string` | `"REGIONAL"` | no |
| `subnets` | Map of subnet configurations | `map(object)` | n/a | yes |
| `enable_cloud_nat` | Enable Cloud NAT | `bool` | `true` | no |
| `cloud_nat_name` | Name of the Cloud NAT | `string` | `"cloud-nat"` | no |
| `firewall_rules` | Map of firewall rule configurations | `map(object)` | `{}` | no |
| `labels` | Resource labels | `map(string)` | `{}` | no |

## Outputs

| Name | Description |
|------|-------------|
| `vpc_id` | ID of the VPC network |
| `vpc_name` | Name of the VPC network |
| `vpc_self_link` | Self-link of the VPC network |
| `subnet_ids` | Map of subnet IDs |
| `private_subnet_name` | Name of the private subnet |
| `cloud_nat_id` | ID of the Cloud NAT |
| `cloud_router_id` | ID of the Cloud Router |
