terraform {
  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = "~> 4.0"
    }
  }
}

locals {
  name_prefix = "${var.customer_name}-${var.location}"
}

# ---------------------------------------------------------------------------
# Log Analytics Workspace
# ---------------------------------------------------------------------------

resource "azurerm_log_analytics_workspace" "prod" {
  name                = "${local.name_prefix}-vnet-law"
  location            = var.location
  resource_group_name = var.resource_group_name
  sku                 = "PerGB2018"
  retention_in_days   = var.log_retention_days
  tags                = var.tags
}

# ---------------------------------------------------------------------------
# Production Virtual Network
# ---------------------------------------------------------------------------

resource "azurerm_virtual_network" "prod" {
  name                = "${local.name_prefix}-vnet-1"
  location            = var.location
  resource_group_name = var.resource_group_name
  address_space       = [var.prod_vnet_cidr]
  tags                = var.tags
}

resource "azurerm_monitor_diagnostic_setting" "prod_vnet" {
  name                       = "${local.name_prefix}-vnet-diag"
  target_resource_id         = azurerm_virtual_network.prod.id
  log_analytics_workspace_id = azurerm_log_analytics_workspace.prod.id

  enabled_log { category = "VMProtectionAlerts" }
  enabled_metric { category = "AllMetrics" }
}

# ---------------------------------------------------------------------------
# Customer subnets — /24 slices
# ---------------------------------------------------------------------------

resource "azurerm_subnet" "customer" {
  count                = var.subnet_count
  name                 = "${local.name_prefix}-vnet-1-snet-${count.index + 1}"
  resource_group_name  = var.resource_group_name
  virtual_network_name = azurerm_virtual_network.prod.name
  address_prefixes     = [cidrsubnet(var.prod_vnet_cidr, 8, count.index)]

  service_endpoints = ["Microsoft.Storage"]
}

# ---------------------------------------------------------------------------
# Route table — route through management firewall
# ---------------------------------------------------------------------------

resource "azurerm_route_table" "prod" {
  name                = "${local.name_prefix}-rt-1"
  location            = var.location
  resource_group_name = var.resource_group_name
  tags                = var.tags

  bgp_route_propagation_enabled = false
}

resource "azurerm_route" "default_to_firewall" {
  name                   = "default-to-firewall"
  resource_group_name    = var.resource_group_name
  route_table_name       = azurerm_route_table.prod.name
  address_prefix         = "0.0.0.0/0"
  next_hop_type          = "VirtualAppliance"
  next_hop_in_ip_address = var.firewall_private_ip
}

resource "azurerm_subnet_route_table_association" "customer" {
  count          = var.subnet_count
  subnet_id      = azurerm_subnet.customer[count.index].id
  route_table_id = azurerm_route_table.prod.id
}

# ---------------------------------------------------------------------------
# VNet Peering — bidirectional with management VNet
# ---------------------------------------------------------------------------

resource "azurerm_virtual_network_peering" "prod_to_mgmt" {
  name                      = "${azurerm_virtual_network.prod.name}-to-mgmt"
  resource_group_name       = var.resource_group_name
  virtual_network_name      = azurerm_virtual_network.prod.name
  remote_virtual_network_id = var.mgmt_vnet_id

  allow_forwarded_traffic      = true
  allow_gateway_transit        = false
  use_remote_gateways          = false
  allow_virtual_network_access = true
}

resource "azurerm_virtual_network_peering" "mgmt_to_prod" {
  name                      = "${var.mgmt_vnet_name}-to-${azurerm_virtual_network.prod.name}"
  resource_group_name       = var.mgmt_resource_group_name
  virtual_network_name      = var.mgmt_vnet_name
  remote_virtual_network_id = azurerm_virtual_network.prod.id

  allow_forwarded_traffic      = true
  allow_gateway_transit        = false
  use_remote_gateways          = false
  allow_virtual_network_access = true
}
