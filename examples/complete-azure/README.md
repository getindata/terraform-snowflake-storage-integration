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
