# Azure VNet Networking

Terraform module to provision an Azure Virtual Network with subnets, private endpoints, Network Security Groups, and service endpoints for data platform services.

## Usage

```hcl
module "networking" {
  source = "./modules/azure/networking"

  resource_group_name = "data-platform-rg"
  location            = "eastus"

  vnet_name          = "data-platform-vnet"
  vnet_address_space = ["10.1.0.0/16"]

  subnets = {
    private = {
      address_prefixes  = ["10.1.1.0/24"]
      service_endpoints = ["Microsoft.Storage", "Microsoft.Sql", "Microsoft.EventHub"]
    }
    public = {
      address_prefixes  = ["10.1.100.0/24"]
      service_endpoints = []
    }
    databricks_public = {
      address_prefixes = ["10.1.2.0/24"]
      delegation       = "Microsoft.Databricks/workspaces"
    }
    databricks_private = {
      address_prefixes = ["10.1.3.0/24"]
      delegation       = "Microsoft.Databricks/workspaces"
    }
  }

  enable_private_dns_zones = true
  private_dns_zones        = ["privatelink.blob.core.windows.net", "privatelink.dfs.core.windows.net"]

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
| `resource_group_name` | Resource group name | `string` | n/a | yes |
| `location` | Azure region | `string` | n/a | yes |
| `vnet_name` | Name of the virtual network | `string` | n/a | yes |
| `vnet_address_space` | Address space for the VNet | `list(string)` | n/a | yes |
| `subnets` | Map of subnet configurations | `map(object)` | n/a | yes |
| `enable_private_dns_zones` | Enable private DNS zones | `bool` | `true` | no |
| `private_dns_zones` | List of private DNS zone names | `list(string)` | `[]` | no |
| `tags` | Resource tags | `map(string)` | `{}` | no |

## Outputs

| Name | Description |
|------|-------------|
| `vnet_id` | ID of the virtual network |
| `vnet_name` | Name of the virtual network |
| `resource_group_name` | Name of the resource group |
| `subnet_ids` | Map of subnet IDs |
| `private_subnet_id` | ID of the private subnet |
| `private_dns_zone_ids` | Map of private DNS zone IDs |
