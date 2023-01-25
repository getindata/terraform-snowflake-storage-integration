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

  source          = "getindata/role/snowflake"
  version         = "1.0.3"
  context         = module.this.context
  enabled         = local.create_default_roles && each.value.enabled
  descriptor_name = each.value.descriptor_name

  name = each.key
  attributes = [
    one(snowflake_storage_integration.this[*].name)
  ]

  role_ownership_grant = each.value.role_ownership_grant
  granted_to_users     = each.value.granted_to_users
  granted_to_roles     = each.value.granted_to_roles
  granted_roles        = each.value.granted_roles
}

module "snowflake_custom_role" {
  for_each = local.custom_roles

  source          = "getindata/role/snowflake"
  version         = "1.0.3"
  context         = module.this.context
  enabled         = local.enabled && each.value.enabled
  descriptor_name = each.value.descriptor_name

  name = each.key
  attributes = [
    one(snowflake_storage_integration.this[*].name)
  ]

  role_ownership_grant = each.value.role_ownership_grant
  granted_to_users     = each.value.granted_to_users
  granted_to_roles     = each.value.granted_to_roles
  granted_roles        = each.value.granted_roles
}

resource "snowflake_integration_grant" "this" {
  for_each = local.enabled ? transpose(
    {
      for role_name, role in local.roles : local.roles[role_name].name => local.roles_definition[role_name].integration_grants
      if local.roles_definition[role_name].enabled
    }
  ) : {}

  integration_name = one(snowflake_storage_integration.this[*].name)
  privilege        = each.key
  roles            = each.value
}
