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
# Public IP Wrapper
###########################

# Wrapper module for compute context
module "public_ip" {
  source = "../../networking/public_ip"

  name                = var.name
  resource_group_name = var.resource_group_name
  location            = var.location
  sku                 = var.sku
  allocation_method   = var.allocation_method
  domain_name_label   = var.domain_name_label
  ip_version          = var.ip_version
  zones               = var.zones
  tags                = var.tags
}
