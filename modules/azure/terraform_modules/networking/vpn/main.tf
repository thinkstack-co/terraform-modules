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
# Locals
###########################

locals {
  vnet_resource_group_name = var.vnet_resource_group_name != "" ? var.vnet_resource_group_name : var.resource_group_name
}

###########################
# Data Sources
###########################

# Lookup GatewaySubnet in the target VNet
data "azurerm_subnet" "gateway" {
  name                 = "GatewaySubnet"
  virtual_network_name = var.vnet_name
  resource_group_name  = local.vnet_resource_group_name
}

###########################
# Public IP for VPN Gateway
###########################

resource "azurerm_public_ip" "vpn" {
  name                = var.public_ip_name
  location            = var.location
  resource_group_name = var.resource_group_name
  allocation_method   = "Static"
  sku                 = "Standard"
  tags                = merge(tomap({ Name = var.name }), var.tags)
}

###########################
# Virtual Network Gateway
###########################

resource "azurerm_virtual_network_gateway" "vpn" {
  name                = var.name
  location            = var.location
  resource_group_name = var.resource_group_name

  type          = "Vpn"
  vpn_type      = var.vpn_type
  sku           = var.sku
  generation    = var.generation
  active_active = var.active_active
  enable_bgp    = var.enable_bgp

  ip_configuration {
    name                          = var.ip_configuration_name
    public_ip_address_id          = azurerm_public_ip.vpn.id
    private_ip_address_allocation = "Dynamic"
    subnet_id                     = data.azurerm_subnet.gateway.id
  }

  tags = merge(tomap({ Name = var.name }), var.tags)
}

###########################
# Local Network Gateway
###########################

resource "azurerm_local_network_gateway" "on_prem" {
  name                = var.local_network_gateway_name
  location            = var.location
  resource_group_name = var.resource_group_name

  gateway_address = var.local_gateway_address
  address_space   = var.local_address_space

  tags = merge(tomap({ Name = var.local_network_gateway_name }), var.tags)
}

###########################
# VPN Connection
###########################

resource "azurerm_virtual_network_gateway_connection" "vpn" {
  name                = var.connection_name
  location            = var.location
  resource_group_name = var.resource_group_name

  type                       = "IPsec"
  virtual_network_gateway_id = azurerm_virtual_network_gateway.vpn.id
  local_network_gateway_id   = azurerm_local_network_gateway.on_prem.id
  connection_protocol        = var.connection_protocol
  shared_key                 = var.shared_key
  enable_bgp                 = var.enable_bgp

  tags = merge(tomap({ Name = var.connection_name }), var.tags)
}
