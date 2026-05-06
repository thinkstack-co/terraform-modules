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

# Private endpoint defaults
locals {
  private_endpoint_name_final = var.private_endpoint_name != null ? var.private_endpoint_name : "${var.storage_account_name}-pe"
  private_endpoint_rg_name    = var.private_endpoint_resource_group_name != null ? var.private_endpoint_resource_group_name : var.resource_group_name
  private_endpoint_location   = var.private_endpoint_location != null ? var.private_endpoint_location : var.location
}

###########################
# Blob Storage Account
###########################
# Note: Resource group must be created separately using the resource group module

resource "azurerm_storage_account" "storage" {
  name                              = var.storage_account_name
  resource_group_name               = var.resource_group_name
  location                          = var.location
  account_tier                      = var.account_tier
  account_replication_type          = var.account_replication_type
  account_kind                      = var.account_kind
  access_tier                       = var.access_tier
  min_tls_version                   = var.min_tls_version
  https_traffic_only_enabled        = var.enable_https_traffic_only
  public_network_access_enabled     = var.public_network_access_enabled
  allow_nested_items_to_be_public   = var.allow_nested_items_to_be_public
  is_hns_enabled                    = var.enable_hns
  sftp_enabled                      = var.enable_sftp
  nfsv3_enabled                     = var.enable_nfs_v3
  infrastructure_encryption_enabled = var.enable_infrastructure_encryption
  cross_tenant_replication_enabled  = var.enable_cross_tenant_replication
  shared_access_key_enabled         = var.enable_shared_key_access
  default_to_oauth_authentication   = var.default_to_oauth_authentication
  tags                              = var.tags

  # Optional managed identity
  dynamic "identity" {
    for_each = var.enable_identity ? [1] : []
    content {
      type         = var.identity_type
      identity_ids = contains(["UserAssigned", "SystemAssigned, UserAssigned"], var.identity_type) ? var.identity_ids : null
    }
  }

  # Optional blob properties configuration
  dynamic "blob_properties" {
    for_each = var.enable_blob_properties ? [1] : []
    content {
      versioning_enabled       = var.blob_versioning_enabled
      change_feed_enabled      = var.blob_change_feed_enabled
      last_access_time_enabled = var.blob_last_access_time_enabled
      default_service_version  = var.blob_default_service_version

      dynamic "delete_retention_policy" {
        for_each = var.blob_delete_retention_days != null ? [1] : []
        content {
          days = var.blob_delete_retention_days
        }
      }

      dynamic "container_delete_retention_policy" {
        for_each = var.blob_container_delete_retention_days != null ? [1] : []
        content {
          days = var.blob_container_delete_retention_days
        }
      }
    }
  }

  # Optional static website hosting
  dynamic "static_website" {
    for_each = var.enable_static_website ? [1] : []
    content {
      index_document     = var.static_website_index_document
      error_404_document = var.static_website_error_404_document
    }
  }

  # Optional custom domain mapping
  dynamic "custom_domain" {
    for_each = var.enable_custom_domain ? [1] : []
    content {
      name          = var.custom_domain_name
      use_subdomain = var.custom_domain_use_subdomain
    }
  }

  # Optional routing configuration
  dynamic "routing" {
    for_each = var.enable_routing ? [1] : []
    content {
      choice                      = var.routing_choice
      publish_internet_endpoints  = var.routing_publish_internet_endpoints
      publish_microsoft_endpoints = var.routing_publish_microsoft_endpoints
    }
  }

  dynamic "network_rules" {
    for_each = var.enable_network_rules ? [1] : []
    content {
      default_action             = var.network_rules_default_action
      bypass                     = var.network_rules_bypass
      ip_rules                   = var.network_rules_ip_rules
      virtual_network_subnet_ids = var.network_rules_virtual_network_subnet_ids

      dynamic "private_link_access" {
        for_each = var.network_rules_private_link_access
        content {
          endpoint_resource_id = private_link_access.value.endpoint_resource_id
          endpoint_tenant_id   = private_link_access.value.endpoint_tenant_id
        }
      }
    }
  }
}

###########################
# Blob Containers
###########################

resource "azurerm_storage_container" "containers" {
  for_each              = var.containers
  name                  = each.key
  storage_account_id    = azurerm_storage_account.storage.id
  container_access_type = each.value.access_type
}

###########################
# Private Endpoint
###########################

# Private endpoint for blob storage
resource "azurerm_private_endpoint" "storage_blob" {
  count               = var.enable_private_endpoint ? 1 : 0
  name                = local.private_endpoint_name_final
  resource_group_name = local.private_endpoint_rg_name
  location            = local.private_endpoint_location
  subnet_id           = var.private_endpoint_subnet_id
  tags                = var.tags

  private_service_connection {
    name                           = "${local.private_endpoint_name_final}-connection"
    private_connection_resource_id = azurerm_storage_account.storage.id
    subresource_names              = ["blob"]
    is_manual_connection           = false
  }
}

# Private DNS zone group (optional)
resource "azurerm_private_dns_zone_group" "storage_blob" {
  count               = var.enable_private_endpoint && var.private_dns_zone_id != null ? 1 : 0
  name                = "${local.private_endpoint_name_final}-dns"
  private_endpoint_id = azurerm_private_endpoint.storage_blob[0].id

  private_dns_zone_configs {
    name                = "blob-zone"
    private_dns_zone_id = var.private_dns_zone_id
  }
}
