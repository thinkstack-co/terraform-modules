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

output "dmz_subnet_ids" {
  description = "List of IDs of DMZ subnets"
  value       = azurerm_subnet.dmz_subnets[*].id
}

output "dmz_subnet_names" {
  description = "List of names of DMZ subnets"
  value       = azurerm_subnet.dmz_subnets[*].name
}

output "dmz_subnet_address_prefixes" {
  description = "List of address prefixes of DMZ subnets"
  value       = azurerm_subnet.dmz_subnets[*].address_prefixes
}

output "db_subnet_ids" {
  description = "List of IDs of database subnets"
  value       = azurerm_subnet.db_subnets[*].id
}

output "db_subnet_names" {
  description = "List of names of database subnets"
  value       = azurerm_subnet.db_subnets[*].name
}

output "db_subnet_address_prefixes" {
  description = "List of address prefixes of database subnets"
  value       = azurerm_subnet.db_subnets[*].address_prefixes
}

output "mgmt_subnet_ids" {
  description = "List of IDs of management subnets"
  value       = azurerm_subnet.mgmt_subnets[*].id
}

output "mgmt_subnet_names" {
  description = "List of names of management subnets"
  value       = azurerm_subnet.mgmt_subnets[*].name
}

output "mgmt_subnet_address_prefixes" {
  description = "List of address prefixes of management subnets"
  value       = azurerm_subnet.mgmt_subnets[*].address_prefixes
}

output "workspaces_subnet_ids" {
  description = "List of IDs of workspaces subnets"
  value       = azurerm_subnet.workspaces_subnets[*].id
}

output "workspaces_subnet_names" {
  description = "List of names of workspaces subnets"
  value       = azurerm_subnet.workspaces_subnets[*].name
}

output "workspaces_subnet_address_prefixes" {
  description = "List of address prefixes of workspaces subnets"
  value       = azurerm_subnet.workspaces_subnets[*].address_prefixes
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
  value       = azurerm_route_table.db_route_table[*].id
}

output "dmz_route_table_ids" {
  description = "List of IDs of DMZ route tables"
  value       = azurerm_route_table.dmz_route_table[*].id
}

output "mgmt_route_table_ids" {
  description = "List of IDs of management route tables"
  value       = azurerm_route_table.mgmt_route_table[*].id
}

output "workspaces_route_table_ids" {
  description = "List of IDs of workspaces route tables"
  value       = azurerm_route_table.workspaces_route_table[*].id
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
