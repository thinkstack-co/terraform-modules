# Managed disk outputs

output "id" {
  description = "The ID of the Managed Disk."
  value       = azurerm_managed_disk.disk.id
}

output "name" {
  description = "The name of the Managed Disk."
  value       = azurerm_managed_disk.disk.name
}

output "disk_size_gb" {
  description = "The size of the Managed Disk in GB."
  value       = azurerm_managed_disk.disk.disk_size_gb
}

output "storage_account_type" {
  description = "The storage account type of the Managed Disk."
  value       = azurerm_managed_disk.disk.storage_account_type
}

output "zone" {
  description = "The Availability Zone in which the Managed Disk is located."
  value       = azurerm_managed_disk.disk.zone
}

# Disk attachment outputs

output "attachment_id" {
  description = "The ID of the Virtual Machine Data Disk attachment."
  value       = var.virtual_machine_id != null ? azurerm_virtual_machine_data_disk_attachment.attachment[0].id : null
}

output "lun" {
  description = "The Logical Unit Number assigned to the attached disk."
  value       = var.virtual_machine_id != null ? azurerm_virtual_machine_data_disk_attachment.attachment[0].lun : null
}
