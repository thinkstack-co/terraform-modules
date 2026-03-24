output "oidc_client_id" {
  description = "Client (application) ID of the Appgate OIDC app registration."
  value       = azuread_application.appgate_oidc.client_id
}

output "key_vault_id" {
  description = "Resource ID of the Key Vault storing Appgate SSH private keys."
  value       = azurerm_key_vault.appgate.id
}

output "key_vault_name" {
  description = "Name of the Key Vault storing Appgate SSH private keys."
  value       = azurerm_key_vault.appgate.name
}

output "controller_private_ip" {
  description = "Private IP of the Appgate SDP Controller VM. Null when deploy_vms = false."
  value       = var.deploy_vms ? azurerm_network_interface.controller[0].private_ip_address : null
}

output "controller_fqdn" {
  description = "FQDN of the Appgate SDP Controller public IP. Null when deploy_vms = false."
  value       = var.deploy_vms ? azurerm_public_ip.controller[0].fqdn : null
}

output "gateway_private_ip" {
  description = "Private IP of the Appgate SDP Gateway VM. Null when deploy_vms = false."
  value       = var.deploy_vms ? azurerm_network_interface.gateway[0].private_ip_address : null
}

output "gateway_fqdn" {
  description = "FQDN of the Appgate SDP Gateway public IP. Null when deploy_vms = false."
  value       = var.deploy_vms ? azurerm_public_ip.gateway[0].fqdn : null
}
