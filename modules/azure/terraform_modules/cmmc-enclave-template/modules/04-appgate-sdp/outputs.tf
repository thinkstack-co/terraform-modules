output "key_vault_id" {
  description = "Resource ID of the Key Vault storing Appgate SSH private keys."
  value       = azurerm_key_vault.appgate.id
}

output "key_vault_name" {
  description = "Name of the Key Vault storing Appgate SSH private keys."
  value       = azurerm_key_vault.appgate.name
}

output "appgate_private_ip" {
  description = "Private IP of the Appgate SDP combined VM. Null when deploy_vms = false."
  value       = var.deploy_vms ? azurerm_network_interface.controller[0].private_ip_address : null
}

output "appgate_fqdn" {
  description = "FQDN of the Appgate SDP combined VM public IP. Null when deploy_vms = false."
  value       = var.deploy_vms ? azurerm_public_ip.controller[0].fqdn : null
}
