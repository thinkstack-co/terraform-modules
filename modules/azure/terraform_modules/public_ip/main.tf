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
# Public IP Address (Azure EIP Equivalent)
###########################

resource "azurerm_public_ip" "this" {
  # Name of the Public IP resource
  name = var.name

  # Location and resource group where the Public IP will be created
  location            = var.location
  resource_group_name = var.resource_group_name

  # Standard SKU requires Static allocation
  allocation_method = var.allocation_method
  sku               = var.sku

  # Optional configuration
  domain_name_label = var.domain_name_label
  ip_version        = var.ip_version
  zones             = var.zones

  # Standard tags + Name tag for convenience
  tags = merge(tomap({ Name = var.name }), var.tags)
}
