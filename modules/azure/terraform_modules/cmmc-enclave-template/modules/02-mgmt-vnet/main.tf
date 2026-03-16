terraform {
  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = "~> 4.0"
    }
  }
}

locals {
  name_prefix = "mgmt-${var.location}"
}

# ---------------------------------------------------------------------------
# Log Analytics Workspaces
# ---------------------------------------------------------------------------

resource "azurerm_log_analytics_workspace" "vnet" {
  name                = "${local.name_prefix}-vnet-law"
  location            = var.location
  resource_group_name = var.resource_group_name
  sku                 = "PerGB2018"
  retention_in_days   = var.log_retention_days
  tags                = var.tags
}

resource "azurerm_log_analytics_workspace" "firewall" {
  name                = "${local.name_prefix}-afw-law"
  location            = var.location
  resource_group_name = var.resource_group_name
  sku                 = "PerGB2018"
  retention_in_days   = var.log_retention_days
  tags                = var.tags
}

# ---------------------------------------------------------------------------
# Virtual Network
# ---------------------------------------------------------------------------

resource "azurerm_virtual_network" "mgmt" {
  name                = "${local.name_prefix}-vnet-1"
  location            = var.location
  resource_group_name = var.resource_group_name
  address_space       = [var.mgmt_vnet_cidr]
  tags                = var.tags
}

resource "azurerm_monitor_diagnostic_setting" "vnet" {
  name                       = "${local.name_prefix}-vnet-diag"
  target_resource_id         = azurerm_virtual_network.mgmt.id
  log_analytics_workspace_id = azurerm_log_analytics_workspace.vnet.id

  enabled_metric { category = "AllMetrics" }
}

# ---------------------------------------------------------------------------
# Subnets (imported from routes.tf and bastion.tf)
# ---------------------------------------------------------------------------

resource "azurerm_subnet" "firewall" {
  name                 = "AzureFirewallSubnet"
  resource_group_name  = var.resource_group_name
  virtual_network_name = azurerm_virtual_network.mgmt.name
  address_prefixes     = [var.firewall_subnet_cidr]
}

resource "azurerm_subnet" "bastion" {
  name                 = "AzureBastionSubnet"
  resource_group_name  = var.resource_group_name
  virtual_network_name = azurerm_virtual_network.mgmt.name
  address_prefixes     = [var.bastion_subnet_cidr]
}

resource "azurerm_subnet" "ztna" {
  name                 = "${local.name_prefix}-vnet-1-ztna-snet"
  resource_group_name  = var.resource_group_name
  virtual_network_name = azurerm_virtual_network.mgmt.name
  address_prefixes     = [var.ztna_subnet_cidr]
}

resource "azurerm_subnet" "mgmt_avd" {
  name                 = "${local.name_prefix}-vnet-1-mgmt-avd-snet"
  resource_group_name  = var.resource_group_name
  virtual_network_name = azurerm_virtual_network.mgmt.name
  address_prefixes     = [var.mgmt_avd_subnet_cidr]
}
