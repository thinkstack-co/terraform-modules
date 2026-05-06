output "storage_account_id" {
  description = "Resource ID of the FSLogix storage account."
  value       = azurerm_storage_account.fslogix.id
}

output "storage_account_name" {
  description = "Name of the FSLogix storage account."
  value       = azurerm_storage_account.fslogix.name
}

output "storage_account_key" {
  description = "Primary access key for the FSLogix storage account."
  value       = azurerm_storage_account.fslogix.primary_access_key
  sensitive   = true
}

output "fslogix_unc_path" {
  description = "UNC path for the FSLogix profiles file share."
  value       = "\\\\${azurerm_storage_account.fslogix.name}.file.core.usgovcloudapi.net\\${azurerm_storage_share.fslogix.name}"
}

output "recovery_vault_id" {
  description = "Resource ID of the Recovery Services Vault."
  value       = azurerm_recovery_services_vault.fslogix.id
}
