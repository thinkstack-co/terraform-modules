terraform {
  required_version = ">= 1.0.0"
  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = ">= 3.0.0"
    }
  }
}

###########################
# Data Sources
###########################
data "azurerm_client_config" "current" {}

###########################
# Locals
###########################
# Note: Resource group must be created separately using the resource group module

locals {
  resource_group_name = var.resource_group_name
  # Calculate the VNet prefix length for VPN subnet derivation
  vnet_prefix_length = tonumber(regex("[0-9]+$", var.vnet_address_space))
  # Calculate the additional bits needed to reach /24
  vpn_subnet_newbits = 24 - local.vnet_prefix_length
  # Select the last /24 in the VNet address space
  service_subnet_total = pow(2, local.vpn_subnet_newbits)
  # Select the last /24s for service subnets when enabled
  vpn_subnet_index = var.enable_vpn_subnet ? local.service_subnet_total - 1 : null
  app_gateway_subnet_index = var.enable_application_gateway_subnet ? local.service_subnet_total - 1 - (var.enable_vpn_subnet ? 1 : 0) : null
  firewall_subnet_index = var.enable_firewall_subnet ? local.service_subnet_total - 1 - (var.enable_vpn_subnet ? 1 : 0) - (var.enable_application_gateway_subnet ? 1 : 0) : null
  # Compute the service subnet CIDRs when enabled
  vpn_gateway_subnet_cidr = var.enable_vpn_subnet ? cidrsubnet(var.vnet_address_space, local.vpn_subnet_newbits, local.vpn_subnet_index) : null
  app_gateway_subnet_cidr = var.enable_application_gateway_subnet ? cidrsubnet(var.vnet_address_space, local.vpn_subnet_newbits, local.app_gateway_subnet_index) : null
  firewall_subnet_cidr = var.enable_firewall_subnet ? cidrsubnet(var.vnet_address_space, local.vpn_subnet_newbits, local.firewall_subnet_index) : null
}

###########################
# Virtual Network
###########################

resource "azurerm_virtual_network" "vnet" {
  name                = var.name
  location            = var.location
  resource_group_name = local.resource_group_name
  address_space       = [var.vnet_address_space]
  dns_servers         = var.dns_servers
  tags                = merge(tomap({ Name = var.name }), var.tags)
}

###########################
# Network Security Group for Service Endpoints
###########################

resource "azurerm_network_security_group" "service_endpoints_nsg" {
  name                = "${var.name}-service-endpoints-nsg"
  location            = var.location
  resource_group_name = local.resource_group_name
  tags                = var.tags

  security_rule {
    name                       = "AllowHTTPS"
    priority                   = 100
    direction                  = "Inbound"
    access                     = "Allow"
    protocol                   = "Tcp"
    source_port_range          = "*"
    destination_port_range     = "443"
    source_address_prefix      = var.vnet_address_space
    destination_address_prefix = var.vnet_address_space
  }

  security_rule {
    name                       = "AllowOutbound"
    priority                   = 100
    direction                  = "Outbound"
    access                     = "Allow"
    protocol                   = "*"
    source_port_range          = "*"
    destination_port_range     = "*"
    source_address_prefix      = "*"
    destination_address_prefix = "*"
  }
}

###########################
# Subnets
###########################

# Dedicated VPN Gateway subnet (GatewaySubnet)
resource "azurerm_subnet" "vpn_gateway_subnet" {
  count                = var.enable_vpn_subnet ? 1 : 0
  name                 = "GatewaySubnet"
  resource_group_name  = local.resource_group_name
  virtual_network_name = azurerm_virtual_network.vnet.name
  address_prefixes     = [local.vpn_gateway_subnet_cidr]
}

# Dedicated Application Gateway subnet (AzureApplicationGatewaySubnet)
resource "azurerm_subnet" "application_gateway_subnet" {
  count                = var.enable_application_gateway_subnet ? 1 : 0
  name                 = "AzureApplicationGatewaySubnet"
  resource_group_name  = local.resource_group_name
  virtual_network_name = azurerm_virtual_network.vnet.name
  address_prefixes     = [local.app_gateway_subnet_cidr]
}

# Dedicated Firewall subnet (AzureFirewallSubnet)
resource "azurerm_subnet" "firewall_subnet" {
  count                = var.enable_firewall_subnet ? 1 : 0
  name                 = "AzureFirewallSubnet"
  resource_group_name  = local.resource_group_name
  virtual_network_name = azurerm_virtual_network.vnet.name
  address_prefixes     = [local.firewall_subnet_cidr]
}

resource "azurerm_subnet" "private_subnets" {
  count                = length(var.private_subnets_list)
  name                 = format("%s-subnet-private-%s", var.name, count.index + 1)
  resource_group_name  = local.resource_group_name
  virtual_network_name = azurerm_virtual_network.vnet.name
  address_prefixes     = [var.private_subnets_list[count.index]]
  service_endpoints    = var.enable_service_endpoints ? var.service_endpoints : []
}

resource "azurerm_subnet" "public_subnets" {
  count                = length(var.public_subnets_list)
  name                 = format("%s-subnet-public-%s", var.name, count.index + 1)
  resource_group_name  = local.resource_group_name
  virtual_network_name = azurerm_virtual_network.vnet.name
  address_prefixes     = [var.public_subnets_list[count.index]]
}

resource "azurerm_subnet" "db_subnets" {
  count                = length(var.db_subnets_list)
  name                 = format("%s-subnet-db-%s", var.name, count.index + 1)
  resource_group_name  = local.resource_group_name
  virtual_network_name = azurerm_virtual_network.vnet.name
  address_prefixes     = [var.db_subnets_list[count.index]]
  service_endpoints    = var.enable_service_endpoints ? ["Microsoft.Sql"] : []
}

###########################
# Public IPs for NAT Gateway
###########################

resource "azurerm_public_ip" "nat_pip" {
  count               = var.enable_nat_gateway ? (var.single_nat_gateway ? 1 : length(var.private_subnets_list)) : 0
  name                = format("%s-nat-pip-%s", var.name, count.index + 1)
  location            = var.location
  resource_group_name = local.resource_group_name
  allocation_method   = "Static"
  sku                 = "Standard"
  zones               = var.nat_gateway_zones
  tags                = var.tags
}

###########################
# NAT Gateway
###########################

resource "azurerm_nat_gateway" "nat" {
  count                   = var.enable_nat_gateway ? (var.single_nat_gateway ? 1 : length(var.private_subnets_list)) : 0
  name                    = format("%s-nat-gateway-%s", var.name, count.index + 1)
  location                = var.location
  resource_group_name     = local.resource_group_name
  sku_name                = "Standard"
  idle_timeout_in_minutes = var.nat_gateway_idle_timeout
  zones                   = var.nat_gateway_zones
  tags                    = var.tags
}

resource "azurerm_nat_gateway_public_ip_association" "nat_pip_assoc" {
  count                = var.enable_nat_gateway ? (var.single_nat_gateway ? 1 : length(var.private_subnets_list)) : 0
  nat_gateway_id       = azurerm_nat_gateway.nat[count.index].id
  public_ip_address_id = azurerm_public_ip.nat_pip[count.index].id
}

###########################
# Route Tables
###########################

# Public Route Table
resource "azurerm_route_table" "public_route_table" {
  name                = format("%s-rt-public", var.name)
  location            = var.location
  resource_group_name = local.resource_group_name
  tags                = var.tags
}

# Private Route Tables (one per subnet for flexibility)
resource "azurerm_route_table" "private_route_table" {
  count               = length(var.private_subnets_list)
  name                = format("%s-rt-private-%s", var.name, count.index + 1)
  location            = var.location
  resource_group_name = local.resource_group_name
  tags                = var.tags
}

# DB Route Tables
resource "azurerm_route_table" "db_route_table" {
  count               = length(var.db_subnets_list)
  name                = format("%s-rt-db-%s", var.name, count.index + 1)
  location            = var.location
  resource_group_name = local.resource_group_name
  tags                = var.tags
}

###########################
# Route Table Associations
###########################

# Associate NAT Gateway with Private Subnets
resource "azurerm_subnet_nat_gateway_association" "private_nat" {
  count          = var.enable_nat_gateway ? length(var.private_subnets_list) : 0
  subnet_id      = azurerm_subnet.private_subnets[count.index].id
  nat_gateway_id = var.single_nat_gateway ? azurerm_nat_gateway.nat[0].id : azurerm_nat_gateway.nat[count.index].id
}

# Associate NAT Gateway with DB Subnets
resource "azurerm_subnet_nat_gateway_association" "db_nat" {
  count          = var.enable_nat_gateway ? length(var.db_subnets_list) : 0
  subnet_id      = azurerm_subnet.db_subnets[count.index].id
  nat_gateway_id = var.single_nat_gateway ? azurerm_nat_gateway.nat[0].id : azurerm_nat_gateway.nat[count.index % length(azurerm_nat_gateway.nat)].id
}

# Associate NAT Gateway with DMZ Subnets

# Associate Route Tables with Subnets
resource "azurerm_subnet_route_table_association" "private" {
  count          = length(var.private_subnets_list)
  subnet_id      = azurerm_subnet.private_subnets[count.index].id
  route_table_id = azurerm_route_table.private_route_table[count.index].id
}

resource "azurerm_subnet_route_table_association" "public" {
  count          = length(var.public_subnets_list)
  subnet_id      = azurerm_subnet.public_subnets[count.index].id
  route_table_id = azurerm_route_table.public_route_table.id
}

resource "azurerm_subnet_route_table_association" "db" {
  count          = length(var.db_subnets_list)
  subnet_id      = azurerm_subnet.db_subnets[count.index].id
  route_table_id = azurerm_route_table.db_route_table[count.index].id
}


###########################
# Network Watcher (for Flow Logs)
###########################

# Network Watcher is typically created once per region per subscription
# We'll create it conditionally if flow logs are enabled
resource "azurerm_network_watcher" "nw" {
  count               = var.enable_flow_logs && var.create_network_watcher ? 1 : 0
  name                = format("%s-network-watcher", var.name)
  location            = var.location
  resource_group_name = local.resource_group_name
  tags                = var.tags
}

###########################
# Storage Account for Flow Logs
###########################

resource "azurerm_storage_account" "flow_logs" {
  count                     = var.enable_flow_logs ? 1 : 0
  name                      = replace(format("%sflowlogs%s", var.name, formatdate("YYYYMMDDhhmmss", timestamp())), "-", "")
  resource_group_name       = local.resource_group_name
  location                  = var.location
  account_tier                   = var.flow_logs_storage_account_tier
  account_replication_type       = var.flow_logs_storage_replication_type
  min_tls_version                = "TLS1_2"
  https_traffic_only_enabled     = true
  tags                           = var.tags

  lifecycle {
    ignore_changes = [name]
  }
}

###########################
# Network Security Group Flow Logs
###########################

resource "azurerm_network_watcher_flow_log" "vnet_flow_log" {
  count                = var.enable_flow_logs ? 1 : 0
  name                 = format("%s-vnet-flow-log", var.name)
  network_watcher_name = var.create_network_watcher ? azurerm_network_watcher.nw[0].name : var.network_watcher_name
  resource_group_name  = var.create_network_watcher ? local.resource_group_name : var.network_watcher_resource_group_name
  target_resource_id   = azurerm_network_security_group.service_endpoints_nsg.id
  storage_account_id   = azurerm_storage_account.flow_logs[0].id
  enabled              = true
  version              = 2
  retention_policy {
    enabled = true
    days    = var.flow_logs_retention_days
  }

  traffic_analytics {
    enabled               = var.enable_traffic_analytics
    workspace_id          = var.log_analytics_workspace_id
    workspace_region      = var.location
    workspace_resource_id = var.log_analytics_workspace_resource_id
    interval_in_minutes   = var.traffic_analytics_interval
  }

  tags = var.tags
}
