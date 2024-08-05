data "azurerm_client_config" "current" {}

resource "snowflake_account_role" "dev_role" {
  name = "developer"
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

  name    = "azure"
  comment = "azure storage integration"

  type                      = "EXTERNAL_STAGE"
  storage_provider          = "AZURE"
  storage_allowed_locations = [format("%sraw", replace(module.azure_storage_account.storage_account_primary_blob_endpoint, "https", "azure"))]
  storage_blocked_locations = [format("%sraw/secret", replace(module.azure_storage_account.storage_account_primary_blob_endpoint, "https", "azure"))]
  azure_tenant_id           = data.azurerm_client_config.current.tenant_id

  create_default_roles = true
  roles = {
    readonly = {
      granted_to_roles = [snowflake_account_role.dev_role.name]
    }
  }
}
