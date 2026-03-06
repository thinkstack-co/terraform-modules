provider "azurerm" {
  environment     = "usgovernment"
  use_oidc        = true
  tenant_id       = var.tenant_id
  subscription_id = var.subscription_id

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
  tenant_id   = var.tenant_id
}

provider "tls" {}

provider "random" {}

provider "microsoft365" {
  tenant_id   = var.tenant_id
  environment = "usgov"
  use_oidc    = true
}
