output "vm_ids" {
  description = "List of session host VM resource IDs."
  value       = azurerm_windows_virtual_machine.session_host[*].id
}

output "vm_names" {
  description = "List of session host VM names."
  value       = azurerm_windows_virtual_machine.session_host[*].name
}

output "private_ips" {
  description = "List of session host private IP addresses."
  value       = azurerm_network_interface.session_host[*].private_ip_address
}
