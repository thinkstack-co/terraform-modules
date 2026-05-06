###########################
# VPN Outputs
###########################

# Virtual Network Gateway ID
output "virtual_network_gateway_id" {
  description = "The ID of the Virtual Network Gateway."
  value       = azurerm_virtual_network_gateway.vpn.id
}

# Virtual Network Gateway name
output "virtual_network_gateway_name" {
  description = "The name of the Virtual Network Gateway."
  value       = azurerm_virtual_network_gateway.vpn.name
}

# VPN gateway public IP
output "public_ip_address" {
  description = "The public IP address of the VPN gateway."
  value       = azurerm_public_ip.vpn.ip_address
}

# Local Network Gateway ID
output "local_network_gateway_id" {
  description = "The ID of the local network gateway."
  value       = azurerm_local_network_gateway.on_prem.id
}

# VPN connection ID
output "vpn_connection_id" {
  description = "The ID of the VPN connection."
  value       = azurerm_virtual_network_gateway_connection.vpn.id
}
