# Azure Managed Disk Module
# This module creates a managed disk and optionally attaches it to a virtual machine

terraform {
  required_version = ">= 1.0.0"
  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = ">= 3.0.0"
    }
  }
}

# Create the managed disk
resource "azurerm_managed_disk" "disk" {
  name                 = var.name
  location             = var.location
  resource_group_name  = var.resource_group_name
  storage_account_type = var.storage_account_type
  create_option        = var.create_option
  disk_size_gb         = var.disk_size_gb

  # Optional settings
  zone                              = var.zone
  disk_iops_read_write              = var.disk_iops_read_write
  disk_mbps_read_write              = var.disk_mbps_read_write
  disk_iops_read_only               = var.disk_iops_read_only
  disk_mbps_read_only               = var.disk_mbps_read_only
  source_resource_id                = var.source_resource_id
  source_uri                        = var.source_uri
  storage_account_id                = var.storage_account_id
  image_reference_id                = var.image_reference_id
  gallery_image_reference_id        = var.gallery_image_reference_id
  disk_encryption_set_id            = var.disk_encryption_set_id
  disk_access_id                    = var.disk_access_id
  public_network_access_enabled     = var.public_network_access_enabled
  network_access_policy             = var.network_access_policy
  tier                              = var.tier
  max_shares                        = var.max_shares
  trusted_launch_enabled            = var.trusted_launch_enabled
  os_type                           = var.os_type
  hyper_v_generation                = var.hyper_v_generation
  on_demand_bursting_enabled        = var.on_demand_bursting_enabled
  upload_size_bytes                 = var.upload_size_bytes
  edge_zone                         = var.edge_zone
  logical_sector_size               = var.logical_sector_size
  optimized_frequent_attach_enabled = var.optimized_frequent_attach_enabled
  performance_plus_enabled          = var.performance_plus_enabled

  # Encryption settings block (optional)
  dynamic "encryption_settings" {
    for_each = var.encryption_settings != null ? [var.encryption_settings] : []
    content {
      dynamic "disk_encryption_key" {
        for_each = encryption_settings.value.disk_encryption_key != null ? [encryption_settings.value.disk_encryption_key] : []
        content {
          secret_url      = disk_encryption_key.value.secret_url
          source_vault_id = disk_encryption_key.value.source_vault_id
        }
      }
      dynamic "key_encryption_key" {
        for_each = encryption_settings.value.key_encryption_key != null ? [encryption_settings.value.key_encryption_key] : []
        content {
          key_url         = key_encryption_key.value.key_url
          source_vault_id = key_encryption_key.value.source_vault_id
        }
      }
    }
  }

  tags = var.tags
}

# Attach the disk to a virtual machine (optional)
resource "azurerm_virtual_machine_data_disk_attachment" "attachment" {
  count = var.virtual_machine_id != null ? 1 : 0

  managed_disk_id           = azurerm_managed_disk.disk.id
  virtual_machine_id        = var.virtual_machine_id
  lun                       = var.lun
  caching                   = var.caching
  create_option             = var.attachment_create_option
  write_accelerator_enabled = var.write_accelerator_enabled
}
