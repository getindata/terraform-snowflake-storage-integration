# Complete Azure Example

```terraform
data "azurerm_client_config" "current" {}

module "snowflake_admin_role" {
  source  = "getindata/role/snowflake"
  version = "1.0.3"
  context = module.this.context
  name    = "admin"
}

module "snowflake_dev_role" {
  source  = "getindata/role/snowflake"
  version = "1.0.3"
  context = module.this.context
  name    = "dev"
}

module "resource_group" {
  source  = "getindata/resource-group/azurerm"
  version = "1.1.0"
  context = module.this.context

  name     = var.resource_group_name
  location = var.location
}

module "azure_storage_account" {
  source  = "getindata/storage-account/azurerm"
  version = "1.3.0"
  context = module.this.context

  name                = "datalake"
  resource_group_name = module.resource_group.name
  location            = module.resource_group.location

  containers_list = [
    {
      name        = "raw"
      access_type = "private"
    }
  ]
}

module "storage_integration" {
  source  = "../../"
  context = module.this.context

  name    = "my_integration"
  comment = "This is my stage"

  type                      = "EXTERNAL_STAGE"
  storage_provider          = "AZURE"
  storage_allowed_locations = [format("%sraw", replace(module.azure_storage_account.storage_account_primary_blob_endpoint, "https", "azure"))]
  storage_blocked_locations = [format("%sraw/secret", replace(module.azure_storage_account.storage_account_primary_blob_endpoint, "https", "azure"))]
  azure_tenant_id           = data.azurerm_client_config.current.tenant_id

  create_default_roles = true
  roles = {
    readonly = {
      granted_to_roles = [module.snowflake_dev_role.name]
    }
    admin = {
      granted_to_roles = [module.snowflake_admin_role.name]
    }
  }
}
```

## Usage
Populate `.env` file with Snowflake credentials and make sure it's sourced to your shell.

```
terraform init
terraform plan -var-file fixtures.tfvars -out tfplan
terraform apply tfplan
```

<!-- BEGIN_TF_DOCS -->




## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_context_templates"></a> [context\_templates](#input\_context\_templates) | A map of context templates used to generate names | `map(string)` | n/a | yes |

## Modules

| Name | Source | Version |
|------|--------|---------|
| <a name="module_storage_integration"></a> [storage\_integration](#module\_storage\_integration) | ../../ | n/a |

## Outputs

| Name | Description |
|------|-------------|
| <a name="output_storage_integration"></a> [storage\_integration](#output\_storage\_integration) | Storage integration module outputs |

## Providers

| Name | Version |
|------|---------|
| <a name="provider_snowflake"></a> [snowflake](#provider\_snowflake) | ~> 0.94 |

## Requirements

| Name | Version |
|------|---------|
| <a name="requirement_terraform"></a> [terraform](#requirement\_terraform) | >= 1.3 |
| <a name="requirement_context"></a> [context](#requirement\_context) | >=0.4.0 |
| <a name="requirement_snowflake"></a> [snowflake](#requirement\_snowflake) | ~> 0.94 |

## Resources

| Name | Type |
|------|------|
| [snowflake_account_role.dev_role](https://registry.terraform.io/providers/Snowflake-Labs/snowflake/latest/docs/resources/account_role) | resource |
<!-- END_TF_DOCS -->
