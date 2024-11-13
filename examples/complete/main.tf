resource "snowflake_account_role" "dev_role" {
  name = "developer"
}


module "storage_integration" {
  source = "../../"

  context_templates = var.context_templates

  name    = "gcs"
  comment = "GCP Storage Integration"

  type                      = "EXTERNAL_STAGE"
  storage_provider          = "GCS"
  storage_allowed_locations = ["gcs://bucket-name"]
  storage_blocked_locations = ["gcs://blocked-bucket-name"]

  create_default_roles = true
  roles = {
    readonly = {
      granted_to_roles = [snowflake_account_role.dev_role.name]
    }
  }
}
