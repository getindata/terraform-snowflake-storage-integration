output "name" {
  description = "Name of the storage integration"
  value       = snowflake_storage_integration.this.name
}

output "comment" {
  description = "Specifies comment for the storage integration"
  value       = snowflake_storage_integration.this.comment
}

output "type" {
  description = "Type of the storage integration"
  value       = snowflake_storage_integration.this.type
}

output "storage_provider" {
  description = "Storage provider name"
  value       = snowflake_storage_integration.this.storage_provider
}

output "storage_allowed_locations" {
  description = "Explicitly limits external stages that use the integration to reference one or more storage locations"
  value       = snowflake_storage_integration.this.storage_allowed_locations
}

output "storage_blocked_locations" {
  description = "Explicitly prohibits external stages that use the integration from referencing one or more storage locations"
  value       = snowflake_storage_integration.this.storage_blocked_locations
}

output "roles" {
  description = "This storage integration access roles"
  value       = local.roles
}

output "azure_consent_url" {
  description = "The consent URL that is used to create an Azure Snowflake service principle inside your tenant"
  value       = snowflake_storage_integration.this.azure_consent_url
}

output "azure_multi_tenant_app_name" {
  description = "This is the name of the Snowflake client application created for your account"
  value       = snowflake_storage_integration.this.azure_multi_tenant_app_name
}

output "azure_tenant_id" {
  description = "ID of the tenant"
  value       = snowflake_storage_integration.this.azure_tenant_id
}

output "storage_aws_external_id" {
  description = "The external ID that Snowflake will use when assuming the AWS role"
  value       = snowflake_storage_integration.this.storage_aws_external_id
}

output "storage_aws_iam_user_arn" {
  description = "The Snowflake user that will attempt to assume the AWS role"
  value       = snowflake_storage_integration.this.storage_aws_iam_user_arn
}

output "storage_aws_object_acl" {
  description = "Name of the AWS access control lists (ACLs)"
  value       = snowflake_storage_integration.this.storage_aws_object_acl
}

output "storage_aws_role_arn" {
  description = "AWS Role ARN"
  value       = snowflake_storage_integration.this.storage_aws_role_arn
}

output "storage_gcp_service_account" {
  description = "This is the name of the Snowflake Google Service Account created for your account"
  value       = snowflake_storage_integration.this.storage_gcp_service_account
}

output "enabled" {
  description = "Whether the storage integration is enabled"
  value       = snowflake_storage_integration.this.enabled
}
