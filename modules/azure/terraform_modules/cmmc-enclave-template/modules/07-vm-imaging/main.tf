terraform {
  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = "~> 4.0"
    }
  }
}

# ---------------------------------------------------------------------------
# Azure Compute Gallery
# ---------------------------------------------------------------------------

resource "azurerm_shared_image_gallery" "main" {
  name                = var.gallery_name
  resource_group_name = var.resource_group_name
  location            = var.location
  description         = "CMMC enclave golden images for ${var.gallery_name}"
  tags                = var.tags
}

# ---------------------------------------------------------------------------
# Image Definitions
# ---------------------------------------------------------------------------

resource "azurerm_shared_image" "definitions" {
  for_each = var.image_definitions

  name                = each.key
  gallery_name        = azurerm_shared_image_gallery.main.name
  resource_group_name = var.resource_group_name
  location            = var.location
  os_type             = each.value.os_type
  hyper_v_generation  = each.value.hyper_v_generation

  trusted_launch_enabled      = each.value.trusted_launch_enabled
  #accelerated_network_support = each.value.accelerated_network_enabled ? "True" : "False"

  identifier {
    publisher = each.value.publisher
    offer     = each.value.offer
    sku       = each.value.sku
  }

  tags = var.tags
}

# ---------------------------------------------------------------------------
# NOTE: Image versions are NOT managed by Terraform.
#
# Image versions are populated externally via:
#   1. Azure Image Builder (AIB) pipeline, OR
#   2. Manual: deploy VM → install apps → sysprep → generalize → capture
#      az vm generalize --resource-group <rg> --name <vm>
#      az image create --resource-group <rg> --name <img> --source <vm>
#      az sig image-version create ... --managed-image <img>
#
# This design keeps the gallery stable under Terraform management
# while allowing the image build pipeline to operate independently.
# ---------------------------------------------------------------------------
