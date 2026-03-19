# Cross-Cloud Governance

Terraform module to provision cross-cloud governance resources including KMS encryption keys across AWS, Azure, and GCP, centralized policy enforcement, and Azure Purview for unified data cataloging.

## Usage

```hcl
module "governance" {
  source = "./modules/shared/governance"

  project_name = "data-platform"
  environment  = "production"

  # AWS KMS
  aws_kms = {
    enabled              = true
    description          = "Data platform encryption key"
    deletion_window_days = 30
    enable_key_rotation  = true
  }

  # Azure Key Vault
  azure_key_vault = {
    enabled             = true
    name                = "dp-keyvault"
    resource_group_name = "data-platform-rg"
    location            = "eastus"
    sku_name            = "standard"
    purge_protection    = true
  }

  # GCP KMS
  gcp_kms = {
    enabled         = true
    project_id      = var.gcp_project_id
    location        = "us-central1"
    keyring_name    = "data-platform-keyring"
    key_name        = "data-platform-key"
    rotation_period = "7776000s"
  }

  # Azure Purview
  purview = {
    enabled             = true
    name                = "dp-purview"
    resource_group_name = "data-platform-rg"
    location            = "eastus"
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
| `project_name` | Name of the project | `string` | n/a | yes |
| `environment` | Environment name | `string` | n/a | yes |
| `aws_kms` | AWS KMS key configuration | `object` | `{ enabled = false }` | no |
| `azure_key_vault` | Azure Key Vault configuration | `object` | `{ enabled = false }` | no |
| `gcp_kms` | GCP KMS keyring and key configuration | `object` | `{ enabled = false }` | no |
| `purview` | Azure Purview configuration | `object` | `{ enabled = false }` | no |
| `tags` | Resource tags | `map(string)` | `{}` | no |

## Outputs

| Name | Description |
|------|-------------|
| `aws_kms_key_arn` | ARN of the AWS KMS key |
| `aws_kms_key_id` | ID of the AWS KMS key |
| `azure_key_vault_id` | ID of the Azure Key Vault |
| `azure_key_vault_uri` | URI of the Azure Key Vault |
| `gcp_kms_key_id` | ID of the GCP KMS crypto key |
| `gcp_kms_keyring_id` | ID of the GCP KMS keyring |
| `purview_account_id` | ID of the Azure Purview account |
| `purview_managed_identity_principal_id` | Principal ID of Purview managed identity |
| `glue_role_arn` | ARN of the Glue IAM role |
