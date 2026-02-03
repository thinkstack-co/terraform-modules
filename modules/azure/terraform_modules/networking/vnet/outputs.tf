###########################
# Resource Group
###########################

output "resource_group_name" {
  description = "The name of the resource group"
  value       = local.resource_group_name
}

###########################
# Virtual Network
###########################

output "vnet_id" {
  description = "The ID of the Virtual Network"
  value       = azurerm_virtual_network.vnet.id
}

output "vnet_name" {
  description = "The name of the Virtual Network"
  value       = azurerm_virtual_network.vnet.name
}

output "vnet_address_space" {
  description = "The address space of the Virtual Network"
  value       = azurerm_virtual_network.vnet.address_space
}

###########################
# Subnets
###########################

output "private_subnet_ids" {
  description = "List of IDs of private subnets"
  value       = azurerm_subnet.private_subnets[*].id
}

output "private_subnet_names" {
  description = "List of names of private subnets"
  value       = azurerm_subnet.private_subnets[*].name
}

output "private_subnet_address_prefixes" {
  description = "List of address prefixes of private subnets"
  value       = azurerm_subnet.private_subnets[*].address_prefixes
}

output "public_subnet_ids" {
  description = "List of IDs of public subnets"
  value       = azurerm_subnet.public_subnets[*].id
}

output "public_subnet_names" {
  description = "List of names of public subnets"
  value       = azurerm_subnet.public_subnets[*].name
}

output "public_subnet_address_prefixes" {
  description = "List of address prefixes of public subnets"
  value       = azurerm_subnet.public_subnets[*].address_prefixes
}


output "db_subnet_ids" {
  description = "List of IDs of database subnets"
  value       = var.enable_db_subnets ? azurerm_subnet.db_subnets[*].id : []
}

output "db_subnet_names" {
  description = "List of names of database subnets"
  value       = var.enable_db_subnets ? azurerm_subnet.db_subnets[*].name : []
}

output "db_subnet_address_prefixes" {
  description = "List of address prefixes of database subnets"
  value       = var.enable_db_subnets ? azurerm_subnet.db_subnets[*].address_prefixes : []
}


output "vpn_gateway_subnet_id" {
  description = "ID of the VPN GatewaySubnet (if created)"
  value       = var.enable_vpn_subnet ? azurerm_subnet.vpn_gateway_subnet[0].id : null
}

output "vpn_gateway_subnet_name" {
  description = "Name of the VPN GatewaySubnet (if created)"
  value       = var.enable_vpn_subnet ? azurerm_subnet.vpn_gateway_subnet[0].name : null
}

output "vpn_gateway_subnet_address_prefix" {
  description = "Address prefix of the VPN GatewaySubnet (if created)"
  value       = var.enable_vpn_subnet ? azurerm_subnet.vpn_gateway_subnet[0].address_prefixes[0] : null
}

output "application_gateway_subnet_id" {
  description = "ID of the AzureApplicationGatewaySubnet (if created)"
  value       = var.enable_application_gateway_subnet ? azurerm_subnet.application_gateway_subnet[0].id : null
}

output "application_gateway_subnet_name" {
  description = "Name of the AzureApplicationGatewaySubnet (if created)"
  value       = var.enable_application_gateway_subnet ? azurerm_subnet.application_gateway_subnet[0].name : null
}

output "application_gateway_subnet_address_prefix" {
  description = "Address prefix of the AzureApplicationGatewaySubnet (if created)"
  value       = var.enable_application_gateway_subnet ? azurerm_subnet.application_gateway_subnet[0].address_prefixes[0] : null
}

output "firewall_subnet_id" {
  description = "ID of the AzureFirewallSubnet (if created)"
  value       = var.enable_firewall_subnet ? azurerm_subnet.firewall_subnet[0].id : null
}

output "firewall_subnet_name" {
  description = "Name of the AzureFirewallSubnet (if created)"
  value       = var.enable_firewall_subnet ? azurerm_subnet.firewall_subnet[0].name : null
}

output "firewall_subnet_address_prefix" {
  description = "Address prefix of the AzureFirewallSubnet (if created)"
  value       = var.enable_firewall_subnet ? azurerm_subnet.firewall_subnet[0].address_prefixes[0] : null
}

###########################
# NAT Gateway
###########################

output "nat_gateway_ids" {
  description = "List of IDs of NAT Gateways"
  value       = azurerm_nat_gateway.nat[*].id
}

output "nat_gateway_public_ips" {
  description = "List of public IP addresses of NAT Gateways"
  value       = azurerm_public_ip.nat_pip[*].ip_address
}

output "nat_gateway_public_ip_ids" {
  description = "List of public IP resource IDs of NAT Gateways"
  value       = azurerm_public_ip.nat_pip[*].id
}

###########################
# Route Tables
###########################

output "public_route_table_id" {
  description = "ID of the public route table"
  value       = azurerm_route_table.public_route_table.id
}

output "private_route_table_ids" {
  description = "List of IDs of private route tables"
  value       = azurerm_route_table.private_route_table[*].id
}

output "db_route_table_ids" {
  description = "List of IDs of database route tables"
  value       = var.enable_db_subnets ? azurerm_route_table.db_route_table[*].id : []
}


###########################
# Network Security Group
###########################

output "service_endpoints_nsg_id" {
  description = "ID of the service endpoints network security group"
  value       = azurerm_network_security_group.service_endpoints_nsg.id
}

output "service_endpoints_nsg_name" {
  description = "Name of the service endpoints network security group"
  value       = azurerm_network_security_group.service_endpoints_nsg.name
}

###########################
# Flow Logs
###########################

output "flow_logs_storage_account_id" {
  description = "ID of the storage account used for flow logs"
  value       = var.enable_flow_logs ? azurerm_storage_account.flow_logs[0].id : null
}

output "flow_logs_storage_account_name" {
  description = "Name of the storage account used for flow logs"
  value       = var.enable_flow_logs ? azurerm_storage_account.flow_logs[0].name : null
}

output "network_watcher_id" {
  description = "ID of the Network Watcher (if created)"
  value       = var.enable_flow_logs && var.create_network_watcher ? azurerm_network_watcher.nw[0].id : null
}

output "network_watcher_name" {
  description = "Name of the Network Watcher (if created)"
  value       = var.enable_flow_logs && var.create_network_watcher ? azurerm_network_watcher.nw[0].name : null
}
