provider "snowflake" {
  preview_features_enabled = ["snowflake_storage_integration_resource"]
}

provider "context" {
  properties = {
    "environment" = {}
    "name"        = {}
  }

  values = {
    environment = "dev"
  }
}
