data "context_label" "this" {
  delimiter  = local.context_template == null ? var.name_scheme.delimiter : null
  properties = local.context_template == null ? var.name_scheme.properties : null
  template   = local.context_template

  replace_chars_regex = var.name_scheme.replace_chars_regex

  values = merge(
    var.name_scheme.extra_values,
    { name = var.name }
  )
}

resource "snowflake_storage_integration" "this" {
  name    = var.name_scheme.uppercase ? upper(data.context_label.this.rendered) : data.context_label.this.rendered
  comment = var.comment
  enabled = var.enabled

  type                      = var.type
  storage_provider          = var.storage_provider
  storage_allowed_locations = var.storage_allowed_locations
  storage_blocked_locations = var.storage_blocked_locations

  azure_tenant_id = var.azure_tenant_id

  storage_aws_object_acl = var.storage_aws_object_acl
  storage_aws_role_arn   = var.storage_aws_role_arn
}
moved {
  from = snowflake_storage_integration.this[0]
  to   = snowflake_storage_integration.this
}

module "snowflake_default_role" {
  for_each = local.default_roles

  source  = "getindata/role/snowflake"
  version = "3.1.0"

  context_templates = var.context_templates

  name = each.key
  name_scheme = merge(
    local.default_role_naming_scheme,
    lookup(each.value, "name_scheme", {})
  )

  role_ownership_grant = lookup(each.value, "role_ownership_grant", "SYSADMIN")
  granted_to_users     = lookup(each.value, "granted_to_users", [])
  granted_to_roles     = lookup(each.value, "granted_to_roles", [])
  granted_roles        = lookup(each.value, "granted_roles", [])

  account_objects_grants = {
    "INTEGRATION" = [{
      all_privileges    = each.value.integration_grants.all_privileges
      privileges        = each.value.integration_grants.privileges
      with_grant_option = each.value.integration_grants.with_grant_option
      object_name       = snowflake_storage_integration.this.name
    }]
  }
}

module "snowflake_custom_role" {
  for_each = local.custom_roles

  source  = "getindata/role/snowflake"
  version = "3.1.0"

  context_templates = var.context_templates

  name = each.key
  name_scheme = merge(
    local.default_role_naming_scheme,
    lookup(each.value, "name_scheme", {})
  )
  granted_to_users = lookup(each.value, "granted_to_users", [])
  granted_to_roles = lookup(each.value, "granted_to_roles", [])
  granted_roles    = lookup(each.value, "granted_roles", [])

  account_objects_grants = {
    "INTEGRATION" = [{
      all_privileges    = each.value.integration_grants.all_privileges
      privileges        = each.value.integration_grants.privileges
      with_grant_option = each.value.integration_grants.with_grant_option
      object_name       = snowflake_storage_integration.this.name
    }]
  }
}
