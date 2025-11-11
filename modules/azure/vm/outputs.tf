######################################
# VM Outputs
######################################

output "vm_id" {
  description = "ID of the virtual machine"
  value       = var.os_type == "Linux" ? azurerm_linux_virtual_machine.vm[0].id : azurerm_windows_virtual_machine.vm[0].id
}

output "vm_name" {
  description = "Name of the virtual machine"
  value       = var.os_type == "Linux" ? azurerm_linux_virtual_machine.vm[0].name : azurerm_windows_virtual_machine.vm[0].name
}

output "private_ip_address" {
  description = "Private IP address of the virtual machine"
  value       = azurerm_network_interface.vm.private_ip_address
}

output "public_ip_address" {
  description = "Public IP address of the virtual machine (if assigned)"
  value       = var.public_ip_address_id != null ? azurerm_network_interface.vm.ip_configuration[0].public_ip_address_id : null
}

output "network_interface_id" {
  description = "ID of the network interface"
  value       = azurerm_network_interface.vm.id
}

output "availability_zone" {
  description = "Availability zone of the virtual machine"
  value       = var.os_type == "Linux" ? azurerm_linux_virtual_machine.vm[0].zone : azurerm_windows_virtual_machine.vm[0].zone
}

output "os_disk_id" {
  description = "ID of the OS disk"
  value       = var.os_type == "Linux" ? azurerm_linux_virtual_machine.vm[0].os_disk[0].name : azurerm_windows_virtual_machine.vm[0].os_disk[0].name
}

output "identity_principal_id" {
  description = "Principal ID of the system assigned managed identity (if enabled)"
  value = var.identity_type != null ? (
    var.os_type == "Linux" ?
    (length(azurerm_linux_virtual_machine.vm[0].identity) > 0 ? azurerm_linux_virtual_machine.vm[0].identity[0].principal_id : null) :
    (length(azurerm_windows_virtual_machine.vm[0].identity) > 0 ? azurerm_windows_virtual_machine.vm[0].identity[0].principal_id : null)
  ) : null
}

output "identity_tenant_id" {
  description = "Tenant ID of the system assigned managed identity (if enabled)"
  value = var.identity_type != null ? (
    var.os_type == "Linux" ?
    (length(azurerm_linux_virtual_machine.vm[0].identity) > 0 ? azurerm_linux_virtual_machine.vm[0].identity[0].tenant_id : null) :
    (length(azurerm_windows_virtual_machine.vm[0].identity) > 0 ? azurerm_windows_virtual_machine.vm[0].identity[0].tenant_id : null)
  ) : null
}

######################################
# Azure Monitor Alert Outputs
######################################

output "vm_availability_alert_id" {
  description = "ID of the VM availability alert"
  value       = azurerm_monitor_metric_alert.vm_availability.id
}

output "cpu_percentage_alert_id" {
  description = "ID of the CPU percentage alert (if enabled)"
  value       = var.enable_cpu_alert ? azurerm_monitor_metric_alert.cpu_percentage[0].id : null
}

output "memory_percentage_alert_id" {
  description = "ID of the memory percentage alert (if enabled)"
  value       = var.enable_memory_alert ? azurerm_monitor_metric_alert.memory_percentage[0].id : null
}

output "disk_operations_alert_id" {
  description = "ID of the disk operations alert (if enabled)"
  value       = var.enable_disk_alert ? azurerm_monitor_metric_alert.disk_operations[0].id : null
}

######################################
# Performance Optimization Diagnostic Outputs
######################################
# These outputs help verify that the performance optimization is working correctly
# and show which method is being used to obtain Azure subscription information.

output "performance_optimization_info" {
  description = <<-EOT
    Diagnostic information showing whether performance optimization is active.
    This helps confirm that subscription/location variables are being passed correctly
    to avoid redundant Azure API calls.
  EOT
  value = {
    # Shows whether azure_subscription_id variable was passed (true = optimized, false = using data source)
    subscription_optimization_active = var.azure_subscription_id != null

    # Shows whether location variable was passed (true = optimized, false = using data source)
    location_optimization_active = var.location != null

    # The actual subscription ID being used (regardless of source)
    azure_subscription_id = local.azure_subscription_id

    # The actual location being used (regardless of source)
    location = local.location

    # Overall optimization status message
    optimization_status = (var.azure_subscription_id != null && var.location != null) ? "✅ OPTIMIZED: Both variables passed, no API calls made" : (var.azure_subscription_id != null || var.location != null) ? "⚠️ PARTIAL: Some variables passed, some API calls still made" : "❌ NOT OPTIMIZED: Using data sources, making redundant API calls"
  }
}

######################################
# VM Configuration Summary
######################################

output "vm_configuration_summary" {
  description = "Summary of the VM configuration"
  value = {
    vm_name                   = var.name
    vm_size                   = var.vm_size
    os_type                   = var.os_type
    location                  = local.location
    private_ip                = azurerm_network_interface.vm.private_ip_address
    accelerated_networking    = var.enable_accelerated_networking
    availability_zone         = var.zone
    monitoring_alerts_enabled = var.enable_monitoring_alerts
  }
}
