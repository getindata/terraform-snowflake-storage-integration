namespace           = "getindata"
environment         = "example"
location            = "West Europe"
resource_group_name = "atlantis-example"

descriptor_formats = {
  snowflake-role = {
    labels = ["attributes", "name"]
    format = "%v_%v"
  }
  snowflake-storage-integration = {
    labels = ["name", "attributes"]
    format = "%v_%v"
  }
  storage-account = {
    labels = ["namespace", "environment", "name"]
    format = "%v%v%v"
  }
}

tags = {
  Terraform = "True"
}
