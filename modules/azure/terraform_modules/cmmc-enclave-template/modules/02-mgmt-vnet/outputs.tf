output "vnet_id" {
  description = "Resource ID of the management virtual network."
  value       = azurerm_virtual_network.mgmt.id
}

output "vnet_name" {
  description = "Name of the management virtual network."
  value       = azurerm_virtual_network.mgmt.name
}

output "subnet_ids" {
  description = "Map of subnet name → subnet resource ID."
  value = {
    AzureFirewallSubnet = azurerm_subnet.firewall.id
    AzureBastionSubnet  = azurerm_subnet.bastion.id
    ztna                = azurerm_subnet.ztna.id
    mgmt_avd            = azurerm_subnet.mgmt_avd.id
  }
}

output "firewall_private_ip" {
  description = "Private IP address of the Azure Firewall."
  value       = azurerm_firewall.mgmt.ip_configuration[0].private_ip_address
}

output "firewall_public_ip" {
  description = "First public IP address of the Azure Firewall."
  value       = azurerm_public_ip.firewall[0].ip_address
}

output "firewall_public_ip_ids" {
  description = "List of public IP resource IDs for the Azure Firewall."
  value       = azurerm_public_ip.firewall[*].id
}

output "firewall_policy_id" {
  description = "Resource ID of the Azure Firewall Policy."
  value       = azurerm_firewall_policy.mgmt.id
}

output "log_analytics_workspace_id" {
  description = "Resource ID of the shared Log Analytics workspace."
  value       = azurerm_log_analytics_workspace.vnet.id
}

output "log_analytics_workspace_key" {
  description = "Primary shared key for the Log Analytics workspace."
  value       = azurerm_log_analytics_workspace.vnet.primary_shared_key
  sensitive   = true
}

output "firewall_log_analytics_workspace_id" {
  description = "Resource ID of the firewall-specific Log Analytics workspace."
  value       = azurerm_log_analytics_workspace.firewall.id
}
