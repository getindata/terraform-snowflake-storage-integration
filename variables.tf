variable "name" {
  description = "Name of the resource"
  type        = string
}

variable "enabled" {
  description = "Whether the storage integration is enabled"
  type        = bool
  default     = true

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
    name_scheme = optional(object({
      properties            = optional(list(string))
      delimiter             = optional(string)
      context_template_name = optional(string)
      replace_chars_regex   = optional(string)
      extra_labels          = optional(map(string))
      uppercase             = optional(bool)
    }))
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

variable "name_scheme" {
  description = <<EOT
  Naming scheme configuration for the resource. This configuration is used to generate names using context provider:
    - `properties` - list of properties to use when creating the name - is superseded by `var.context_templates`
    - `delimiter` - delimited used to create the name from `properties` - is superseded by `var.context_templates`
    - `context_template_name` - name of the context template used to create the name
    - `replace_chars_regex` - regex to use for replacing characters in property-values created by the provider - any characters that match the regex will be removed from the name
    - `extra_values` - map of extra label-value pairs, used to create a name
    - `uppercase` - convert name to uppercase
  EOT
  type = object({
    properties            = optional(list(string), ["environment", "name"])
    delimiter             = optional(string, "_")
    context_template_name = optional(string, "snowflake-warehouse")
    replace_chars_regex   = optional(string, "[^a-zA-Z0-9_]")
    extra_values          = optional(map(string))
    uppercase             = optional(bool, true)
  })
  default = {}
}

variable "context_templates" {
  description = "Map of context templates used for naming conventions - this variable supersedes `naming_scheme.properties` and `naming_scheme.delimiter` configuration"
  type        = map(string)
  default     = {}
}
