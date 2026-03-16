provider "azurerm" {
  environment = "usgovernment"
  use_oidc    = true

  features {
    key_vault {
      purge_soft_delete_on_destroy    = false
      recover_soft_deleted_key_vaults = true
    }
    resource_group {
      prevent_deletion_if_contains_resources = true
    }
    virtual_machine {
      delete_os_disk_on_deletion = true
    }
  }
}

provider "azuread" {
  environment = "usgovernment"
  use_oidc    = true
}

provider "azapi" {
  environment = "usgovernment"
  use_oidc    = true
}

provider "tls" {}

provider "random" {}
