# Azure Data Factory

Terraform module to provision an Azure Data Factory instance with managed virtual network, linked services, and configurable pipeline triggers.

## Usage

```hcl
module "data_factory" {
  source = "./modules/azure/data-factory"

  name                = "data-platform-adf"
  resource_group_name = module.networking.resource_group_name
  location            = "eastus"

  managed_virtual_network_enabled = true
  public_network_enabled          = false

  identity_type = "SystemAssigned"

  linked_services = {
    adls = {
      type                 = "AzureBlobFS"
      storage_account_name = module.data_lake.storage_account_name
    }
    synapse = {
      type         = "AzureSynapse"
      workspace_url = module.synapse.workspace_url
    }
  }

  triggers = {
    daily_etl = {
      type       = "Schedule"
      frequency  = "Day"
      interval   = 1
      start_time = "2024-01-01T00:00:00Z"
      pipeline   = "main_etl_pipeline"
    }
  }

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
| `name` | Name of the Data Factory | `string` | n/a | yes |
| `resource_group_name` | Resource group name | `string` | n/a | yes |
| `location` | Azure region | `string` | n/a | yes |
| `managed_virtual_network_enabled` | Enable managed VNet | `bool` | `true` | no |
| `public_network_enabled` | Enable public network access | `bool` | `false` | no |
| `identity_type` | Managed identity type | `string` | `"SystemAssigned"` | no |
| `linked_services` | Map of linked service configurations | `map(object)` | `{}` | no |
| `triggers` | Map of pipeline trigger configurations | `map(object)` | `{}` | no |
| `tags` | Resource tags | `map(string)` | `{}` | no |

## Outputs

| Name | Description |
|------|-------------|
| `id` | ID of the Data Factory |
| `name` | Name of the Data Factory |
| `identity_principal_id` | Principal ID of the managed identity |
| `identity_tenant_id` | Tenant ID of the managed identity |
| `linked_service_ids` | Map of linked service IDs |
