variable "descriptor_name" {
  description = "Name of the descriptor used to form a resource name"
  type        = string
  default     = "snowflake-storage-integration"
}

variable "storage_provider" {
  description = "Storage provider name. Possible values are: `S3`, `S3GOV`, `GCS`, `AZURE`"
  type        = string

  validation {
    condition     = contains(["S3", "S3GOV", "GCS", "AZURE"], var.storage_provider)
    error_message = "Invalid storage provider. Possible values are: \"S3\", \"S3GOV\", \"GCS\", \"AZURE\""
  }
}

variable "storage_allowed_locations" {
  description = "Explicitly limits external stages that use the integration to reference one or more storage locations"
  type        = list(string)
}

variable "storage_blocked_locations" {
  description = "Explicitly prohibits external stages that use the integration from referencing one or more storage locations"
  type        = list(string)
  default     = []
}

variable "type" {
  description = "Type of the storage integration. Defaults: EXTERNAL_STAGE"
  type        = string
  default     = "EXTERNAL_STAGE"
}

variable "comment" {
  description = "Specifies comment for the storage integration"
  type        = string
  default     = null
}

variable "azure_tenant_id" {
  description = "Azure tenant ID. Required if storage provider is type of `AZURE`"
  type        = string
  default     = null
}

variable "storage_aws_object_acl" {
  description = "Value of \"bucket-owner-full-control\" enables support for AWS access control lists (ACLs) to grant the bucket owner full control"
  type        = string
  default     = null
}

variable "storage_aws_role_arn" {
  description = "AWS Role ARN"
  type        = string
  default     = null
}

variable "create_default_roles" {
  description = "Whether the default roles should be created"
  type        = bool
  default     = false
}

variable "roles" {
  description = "Roles created in the database scope"
  type = map(object({
    enabled              = optional(bool, true)
    descriptor_name      = optional(string, "snowflake-role")
    comment              = optional(string)
    role_ownership_grant = optional(string)
    granted_roles        = optional(list(string))
    granted_to_roles     = optional(list(string))
    granted_to_users     = optional(list(string))
    integration_grants = optional(object({
      all_privileges    = optional(bool)
      with_grant_option = optional(bool, false)
      privileges        = optional(list(string))
    }))
  }))
  default = {}
}
