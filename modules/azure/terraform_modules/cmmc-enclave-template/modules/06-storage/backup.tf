# ---------------------------------------------------------------------------
# Recovery Services Vault
# ---------------------------------------------------------------------------

resource "azurerm_recovery_services_vault" "fslogix" {
  name                = "${local.name_prefix}-rsv-1"
  location            = var.location
  resource_group_name = var.resource_group_name
  sku                 = "Standard"
  storage_mode_type   = "LocallyRedundant"
  #soft_delete_enabled = true
  tags                = var.tags
}

# ---------------------------------------------------------------------------
# Backup Policy — File Share
# ---------------------------------------------------------------------------

resource "azurerm_backup_policy_file_share" "fslogix" {
  name                = "${local.name_prefix}-fslogix-backup-policy"
  resource_group_name = var.resource_group_name
  recovery_vault_name = azurerm_recovery_services_vault.fslogix.name

  timezone = "UTC"

  backup {
    frequency = "Daily"
    time      = "22:00"
  }

  retention_daily {
    count = var.backup_daily_retention_days
  }

  retention_weekly {
    count    = var.backup_weekly_retention_weeks
    weekdays = ["Sunday"]
  }

  retention_monthly {
    count    = var.backup_monthly_retention_months
    weekdays = ["Sunday"]
    weeks    = ["First"]
  }
}

# ---------------------------------------------------------------------------
# Backup — Register storage account with vault
# ---------------------------------------------------------------------------

resource "azurerm_backup_container_storage_account" "fslogix" {
  resource_group_name = var.resource_group_name
  recovery_vault_name = azurerm_recovery_services_vault.fslogix.name
  storage_account_id  = azurerm_storage_account.fslogix.id
}

resource "azurerm_backup_protected_file_share" "fslogix" {
  resource_group_name       = var.resource_group_name
  recovery_vault_name       = azurerm_recovery_services_vault.fslogix.name
  source_storage_account_id = azurerm_storage_account.fslogix.id
  source_file_share_name    = azurerm_storage_share.fslogix.name
  backup_policy_id          = azurerm_backup_policy_file_share.fslogix.id

  depends_on = [azurerm_backup_container_storage_account.fslogix]
}
