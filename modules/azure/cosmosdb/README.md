# Azure CosmosDB SQL API

Terraform module to provision an Azure CosmosDB account with SQL API, configurable consistency levels, geo-replication, and private endpoint connectivity.

## Usage

```hcl
module "cosmosdb" {
  source = "./modules/azure/cosmosdb"

  account_name        = "data-platform-cosmos"
  resource_group_name = module.networking.resource_group_name
  location            = "eastus"

  offer_type          = "Standard"
  kind                = "GlobalDocumentDB"
  consistency_level   = "Session"

  geo_locations = [
    {
      location          = "eastus"
      failover_priority = 0
    },
    {
      location          = "westus"
      failover_priority = 1
    }
  ]

  databases = {
    analytics = {
      throughput = 400
      containers = {
        events = {
          partition_key_path = "/eventType"
          throughput         = 400
        }
      }
    }
  }

  enable_private_endpoint = true
  subnet_id               = module.networking.private_subnet_id

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
| `account_name` | Name of the CosmosDB account | `string` | n/a | yes |
| `resource_group_name` | Resource group name | `string` | n/a | yes |
| `location` | Azure region | `string` | n/a | yes |
| `offer_type` | CosmosDB offer type | `string` | `"Standard"` | no |
| `kind` | CosmosDB account kind | `string` | `"GlobalDocumentDB"` | no |
| `consistency_level` | Default consistency level | `string` | `"Session"` | no |
| `geo_locations` | List of geo-replication locations | `list(object)` | n/a | yes |
| `databases` | Map of databases and containers | `map(object)` | `{}` | no |
| `enable_private_endpoint` | Enable private endpoint | `bool` | `true` | no |
| `subnet_id` | Subnet ID for private endpoint | `string` | `null` | no |
| `tags` | Resource tags | `map(string)` | `{}` | no |

## Outputs

| Name | Description |
|------|-------------|
| `account_id` | ID of the CosmosDB account |
| `account_endpoint` | Endpoint of the CosmosDB account |
| `primary_key` | Primary key for the CosmosDB account |
| `connection_strings` | Connection strings for the account |
| `database_ids` | Map of database IDs |
