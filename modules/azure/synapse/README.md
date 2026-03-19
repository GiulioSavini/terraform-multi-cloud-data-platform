# Azure Synapse Analytics

Terraform module to provision an Azure Synapse Analytics workspace with dedicated SQL pools, Spark pools, and integration with ADLS Gen2 storage.

## Usage

```hcl
module "synapse" {
  source = "./modules/azure/synapse"

  workspace_name      = "data-platform-synapse"
  resource_group_name = module.networking.resource_group_name
  location            = "eastus"

  storage_account_id       = module.data_lake.storage_account_id
  storage_filesystem_name  = "synapse"

  sql_administrator_login          = "sqladmin"
  sql_administrator_login_password = var.synapse_sql_password

  sql_pools = {
    analytics = {
      sku_name   = "DW100c"
      collation  = "SQL_LATIN1_GENERAL_CP1_CI_AS"
      create_mode = "Default"
    }
  }

  spark_pools = {
    processing = {
      node_size_family = "MemoryOptimized"
      node_size        = "Small"
      min_node_count   = 3
      max_node_count   = 10
      spark_version    = "3.4"
    }
  }

  enable_managed_vnet = true

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
| `workspace_name` | Name of the Synapse workspace | `string` | n/a | yes |
| `resource_group_name` | Resource group name | `string` | n/a | yes |
| `location` | Azure region | `string` | n/a | yes |
| `storage_account_id` | ADLS Gen2 storage account ID | `string` | n/a | yes |
| `storage_filesystem_name` | ADLS Gen2 filesystem name | `string` | n/a | yes |
| `sql_administrator_login` | SQL admin username | `string` | n/a | yes |
| `sql_administrator_login_password` | SQL admin password | `string` | n/a | yes |
| `sql_pools` | Map of dedicated SQL pool configurations | `map(object)` | `{}` | no |
| `spark_pools` | Map of Spark pool configurations | `map(object)` | `{}` | no |
| `enable_managed_vnet` | Enable managed virtual network | `bool` | `true` | no |
| `tags` | Resource tags | `map(string)` | `{}` | no |

## Outputs

| Name | Description |
|------|-------------|
| `workspace_id` | ID of the Synapse workspace |
| `workspace_url` | URL of the Synapse workspace |
| `sql_pool_ids` | Map of dedicated SQL pool IDs |
| `spark_pool_ids` | Map of Spark pool IDs |
| `managed_identity_principal_id` | Principal ID of the workspace managed identity |
