output "vnet_id" {
  description = "Resource ID of the production virtual network."
  value       = azurerm_virtual_network.prod.id
}

output "vnet_name" {
  description = "Name of the production virtual network."
  value       = azurerm_virtual_network.prod.name
}

output "subnet_ids" {
  description = "List of subnet resource IDs."
  value       = azurerm_subnet.customer[*].id
}

output "subnet_names" {
  description = "List of subnet names."
  value       = azurerm_subnet.customer[*].name
}
