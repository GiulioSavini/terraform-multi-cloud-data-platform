# Azure Data Lake Storage Gen2

Terraform module to provision an Azure Data Lake Storage Gen2 account with hierarchical namespace, lifecycle management, and private endpoint connectivity.

## Usage

```hcl
module "data_lake" {
  source = "./modules/azure/data-lake"

  storage_account_name = "dataplatformlake"
  resource_group_name  = module.networking.resource_group_name
  location             = "eastus"

  account_tier             = "Standard"
  account_replication_type = "GRS"
  enable_hns               = true

  filesystems = ["raw", "processed", "curated"]

  lifecycle_rules = {
    archive_raw = {
      prefix_match   = ["raw/"]
      tier_to_cool   = 30
      tier_to_archive = 90
      delete_after    = 365
    }
    archive_processed = {
      prefix_match   = ["processed/"]
      tier_to_cool   = 60
      tier_to_archive = 180
      delete_after    = null
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
| `storage_account_name` | Name of the storage account | `string` | n/a | yes |
| `resource_group_name` | Resource group name | `string` | n/a | yes |
| `location` | Azure region | `string` | n/a | yes |
| `account_tier` | Storage account tier | `string` | `"Standard"` | no |
| `account_replication_type` | Replication type | `string` | `"GRS"` | no |
| `enable_hns` | Enable hierarchical namespace (ADLS Gen2) | `bool` | `true` | no |
| `filesystems` | List of filesystem names to create | `list(string)` | `["raw", "processed", "curated"]` | no |
| `lifecycle_rules` | Map of lifecycle management rules | `map(object)` | `{}` | no |
| `enable_private_endpoint` | Enable private endpoint | `bool` | `true` | no |
| `subnet_id` | Subnet ID for private endpoint | `string` | `null` | no |
| `tags` | Resource tags | `map(string)` | `{}` | no |

## Outputs

| Name | Description |
|------|-------------|
| `storage_account_id` | ID of the storage account |
| `storage_account_name` | Name of the storage account |
| `primary_dfs_endpoint` | Primary DFS endpoint |
| `primary_blob_endpoint` | Primary Blob endpoint |
| `filesystem_ids` | Map of filesystem IDs |
