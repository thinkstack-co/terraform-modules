# Remote state in Azure Government
# Replace placeholder values with the output from bootstrap setup (docs/bootstrap.md)

terraform {
  backend "azurerm" {
    environment          = "usgovernment"
    resource_group_name  = "REPLACE-tfstate-rg"
    storage_account_name = "REPLACEtfstate001"
    container_name       = "tfstate"
    key                  = "cmmc-enclave.tfstate"
    use_oidc             = true
  }
}
