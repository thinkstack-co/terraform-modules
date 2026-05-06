terraform {
  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = "~> 4.0"
    }
  }
}

locals {
  name_prefix = "${var.customer_name}-${var.location}"
}

# ---------------------------------------------------------------------------
# Storage Account
# ---------------------------------------------------------------------------

resource "azurerm_storage_account" "fslogix" {
  name                     = var.storage_account_name
  resource_group_name      = var.resource_group_name
  location                 = var.location
  account_tier             = "Premium"
  account_kind             = "FileStorage"
  account_replication_type = "LRS"

  # Security
  https_traffic_only_enabled        = true
  min_tls_version                   = "TLS1_2"
  infrastructure_encryption_enabled = true
  allow_nested_items_to_be_public   = false
  shared_access_key_enabled         = true
  ##
  # Large file shares required for Premium FileStorage
  large_file_share_enabled = true

  share_properties {
    retention_policy {
      days = var.share_soft_delete_retention_days
    }

    # Why: SMB Multichannel allows a single SMB session to use multiple TCP
    # connections in parallel, which materially improves FSLogix profile
    # mount/unmount throughput on Premium FileStorage. Microsoft's FSLogix
    # guidance recommends enabling it; pinning it here so the setting is not
    # silently disabled on a future apply when the azurerm provider would
    # otherwise revert it to Azure's default (false).
    smb {
      multichannel_enabled = true
    }
  }

  network_rules {
    default_action             = "Deny"
    bypass                     = ["AzureServices"]
    virtual_network_subnet_ids = var.allowed_subnet_ids
  }

  tags = var.tags
}

# ---------------------------------------------------------------------------
# FSLogix Profiles File Share
# ---------------------------------------------------------------------------

resource "azurerm_storage_share" "fslogix" {
  name               = "fslogixprofiles"
  storage_account_id = azurerm_storage_account.fslogix.id
  quota              = var.fslogix_share_size_gb

  enabled_protocol = "SMB"
}
