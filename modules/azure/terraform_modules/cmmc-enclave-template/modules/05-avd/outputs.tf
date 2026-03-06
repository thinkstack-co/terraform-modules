output "mgmt_host_pool_id" {
  description = "Resource ID of the management host pool."
  value       = azurerm_virtual_desktop_host_pool.mgmt.id
}

output "mgmt_host_pool_name" {
  description = "Name of the management host pool."
  value       = azurerm_virtual_desktop_host_pool.mgmt.name
}

output "customer_host_pool_id" {
  description = "Resource ID of the customer host pool."
  value       = azurerm_virtual_desktop_host_pool.customer.id
}

output "customer_host_pool_name" {
  description = "Name of the customer host pool."
  value       = azurerm_virtual_desktop_host_pool.customer.name
}

output "mgmt_registration_token" {
  description = "Registration token for joining VMs to the management host pool (valid 2 hours from apply)."
  value       = azurerm_virtual_desktop_host_pool_registration_info.mgmt.token
  sensitive   = true
}

output "customer_registration_token" {
  description = "Registration token for joining VMs to the customer host pool (valid 2 hours from apply)."
  value       = azurerm_virtual_desktop_host_pool_registration_info.customer.token
  sensitive   = true
}

output "mgmt_workspace_id" {
  description = "Resource ID of the management AVD workspace."
  value       = azurerm_virtual_desktop_workspace.mgmt.id
}

output "customer_workspace_id" {
  description = "Resource ID of the customer AVD workspace."
  value       = azurerm_virtual_desktop_workspace.customer.id
}
