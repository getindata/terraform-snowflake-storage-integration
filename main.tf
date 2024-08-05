module "storage_integration_label" {
  source  = "cloudposse/label/null"
  version = "0.25.0"
  context = module.this.context

  delimiter           = coalesce(module.this.context.delimiter, "_")
  regex_replace_chars = coalesce(module.this.context.regex_replace_chars, "/[^_a-zA-Z0-9]/")
  label_value_case    = coalesce(module.this.context.label_value_case, "upper")
}

resource "snowflake_storage_integration" "this" {
  count = module.this.enabled ? 1 : 0

  name    = local.name_from_descriptor
  comment = var.comment

  type                      = var.type
  storage_provider          = var.storage_provider
  storage_allowed_locations = var.storage_allowed_locations
  storage_blocked_locations = var.storage_blocked_locations

  azure_tenant_id = var.azure_tenant_id

  storage_aws_object_acl = var.storage_aws_object_acl
  storage_aws_role_arn   = var.storage_aws_role_arn
}

module "snowflake_default_role" {
  for_each = local.default_roles

  source  = "getindata/role/snowflake"
  version = "2.1.0"
  context = module.this.context

  name            = each.key
  attributes      = ["SI", one(snowflake_storage_integration.this[*].name)]
  enabled         = local.create_default_roles && lookup(each.value, "enabled", true)
  descriptor_name = lookup(each.value, "descriptor_name", "snowflake-role")

  role_ownership_grant = lookup(each.value, "role_ownership_grant", "SYSADMIN")
  granted_to_users     = lookup(each.value, "granted_to_users", [])
  granted_to_roles     = lookup(each.value, "granted_to_roles", [])
  granted_roles        = lookup(each.value, "granted_roles", [])

  account_objects_grants = {
    "INTEGRATION" = [{
      all_privileges    = each.value.integration_grants.all_privileges
      privileges        = each.value.integration_grants.privileges
      with_grant_option = each.value.integration_grants.with_grant_option
      object_name       = one(snowflake_storage_integration.this[*].name)
    }]
  }

  depends_on = [
    snowflake_storage_integration.this
  ]
}

module "snowflake_custom_role" {
  for_each = local.custom_roles

  source  = "getindata/role/snowflake"
  version = "2.1.0"
  context = module.this.context

  name            = each.key
  attributes      = ["SI", one(snowflake_storage_integration.this[*].name)]
  enabled         = lookup(each.value, "enabled", true)
  descriptor_name = lookup(each.value, "descriptor_name", "snowflake-role")

  role_ownership_grant = lookup(each.value, "role_ownership_grant", "SYSADMIN")
  granted_to_users     = lookup(each.value, "granted_to_users", [])
  granted_to_roles     = lookup(each.value, "granted_to_roles", [])
  granted_roles        = lookup(each.value, "granted_roles", [])

  account_objects_grants = {
    "INTEGRATION" = [{
      all_privileges    = each.value.integration_grants.all_privileges
      privileges        = each.value.integration_grants.privileges
      with_grant_option = each.value.integration_grants.with_grant_option
      object_name       = one(snowflake_storage_integration.this[*].name)
    }]
  }

  depends_on = [
    snowflake_storage_integration.this
  ]
}
