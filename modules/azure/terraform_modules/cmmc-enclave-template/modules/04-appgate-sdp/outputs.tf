output "key_vault_id" {
  description = "Resource ID of the Key Vault storing Appgate SSH private keys."
  value       = azurerm_key_vault.appgate.id
}

output "key_vault_name" {
  description = "Name of the Key Vault storing Appgate SSH private keys."
  value       = azurerm_key_vault.appgate.name
}

output "controller_private_ip" {
  description = "Private IP of the Appgate SDP Controller VM."
  value       = azurerm_network_interface.controller.private_ip_address
}

output "gateway_private_ip" {
  description = "Private IP of the Appgate SDP Gateway VM."
  value       = azurerm_network_interface.gateway.private_ip_address
}

output "controller_fqdn" {
  description = "FQDN of the Appgate SDP Controller public IP."
  value       = azurerm_public_ip.controller.fqdn
}

output "gateway_fqdn" {
  description = "FQDN of the Appgate SDP Gateway public IP."
  value       = azurerm_public_ip.gateway.fqdn
}
