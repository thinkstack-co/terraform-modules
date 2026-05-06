###########################
# Resource Group
###########################
# Note: Resource group must be created separately using the resource group module

# Storage account name
variable "storage_account_name" {
  type        = string
  description = "(Required) The globally unique name of the storage account."
}

# Resource group name
variable "resource_group_name" {
  type        = string
  description = "(Required) The name of the resource group in which to create the storage account."
}

# Storage account location
variable "location" {
  type        = string
  description = "(Optional) The Azure region where resources will be created."
  default     = "eastus"
}

###########################
# Storage Account Settings
###########################

# Storage account tier
variable "account_tier" {
  type        = string
  description = "(Optional) The storage account tier. Valid values are Standard or Premium."
  default     = "Standard"
  validation {
    condition     = contains(["Standard", "Premium"], var.account_tier)
    error_message = "account_tier must be Standard or Premium."
  }
}

###########################
# Cross-Variable Validation
###########################

# Validate HNS-dependent features
variable "_validate_hns_features" {
  type        = bool
  description = "(Internal) Ensures SFTP/NFS features require hierarchical namespace."
  default     = true

  validation {
    condition     = !(var.enable_sftp || var.enable_nfs_v3) || var.enable_hns
    error_message = "enable_hns must be true when enable_sftp or enable_nfs_v3 is enabled."
  }
}

# Validate identity IDs
variable "_validate_identity_ids" {
  type        = bool
  description = "(Internal) Ensures user-assigned identity IDs are provided when required."
  default     = true

  validation {
    condition     = !var.enable_identity || !(contains(["UserAssigned", "SystemAssigned, UserAssigned"], var.identity_type) && length(var.identity_ids) == 0)
    error_message = "identity_ids must be provided when identity_type includes UserAssigned."
  }
}

# Validate custom domain settings
variable "_validate_custom_domain" {
  type        = bool
  description = "(Internal) Ensures custom domain name is provided when enabled."
  default     = true

  validation {
    condition     = !var.enable_custom_domain || (var.custom_domain_name != null && var.custom_domain_name != "")
    error_message = "custom_domain_name must be provided when enable_custom_domain is true."
  }
}

# Storage account replication
variable "account_replication_type" {
  type        = string
  description = "(Optional) The storage account replication type."
  default     = "LRS"
  validation {
    condition     = contains(["LRS", "GRS", "RAGRS", "ZRS", "GZRS", "RAGZRS"], var.account_replication_type)
    error_message = "account_replication_type must be one of LRS, GRS, RAGRS, ZRS, GZRS, or RAGZRS."
  }
}

# Storage account kind
variable "account_kind" {
  type        = string
  description = "(Optional) The storage account kind."
  default     = "StorageV2"
  validation {
    condition     = contains(["StorageV2", "Storage", "BlobStorage", "BlockBlobStorage", "FileStorage"], var.account_kind)
    error_message = "account_kind must be one of StorageV2, Storage, BlobStorage, BlockBlobStorage, or FileStorage."
  }
}

# Storage access tier
variable "access_tier" {
  type        = string
  description = "(Optional) The access tier for BlobStorage or StorageV2 accounts."
  default     = "Hot"
  validation {
    condition     = contains(["Hot", "Cool"], var.access_tier)
    error_message = "access_tier must be Hot or Cool."
  }
}

# Minimum TLS version
variable "min_tls_version" {
  type        = string
  description = "(Optional) The minimum TLS version to enforce on the storage account."
  default     = "TLS1_2"
  validation {
    condition     = contains(["TLS1_0", "TLS1_1", "TLS1_2"], var.min_tls_version)
    error_message = "min_tls_version must be TLS1_0, TLS1_1, or TLS1_2."
  }
}

# Enforce HTTPS traffic only
variable "enable_https_traffic_only" {
  type        = bool
  description = "(Optional) Enforce HTTPS-only traffic to the storage account."
  default     = true
}

# Public network access
variable "public_network_access_enabled" {
  type        = bool
  description = "(Optional) Whether public network access is enabled for the storage account."
  default     = false
}

# Allow nested items to be public
variable "allow_nested_items_to_be_public" {
  type        = bool
  description = "(Optional) Whether to allow public access to nested items in containers."
  default     = false
}

###########################
# Advanced Storage Settings
###########################

# Enable hierarchical namespace (Data Lake Gen2)
variable "enable_hns" {
  type        = bool
  description = "(Optional) Enable hierarchical namespace (Data Lake Gen2)."
  default     = false
}

# Enable SFTP support
variable "enable_sftp" {
  type        = bool
  description = "(Optional) Enable SFTP for the storage account (requires hierarchical namespace)."
  default     = false
}

# Enable NFS v3 support
variable "enable_nfs_v3" {
  type        = bool
  description = "(Optional) Enable NFS v3 for the storage account (requires hierarchical namespace)."
  default     = false
}

# Enable infrastructure encryption
variable "enable_infrastructure_encryption" {
  type        = bool
  description = "(Optional) Enable infrastructure encryption for the storage account."
  default     = false
}

# Enable cross-tenant replication
variable "enable_cross_tenant_replication" {
  type        = bool
  description = "(Optional) Enable cross-tenant replication."
  default     = true
}

# Enable shared access key authentication
variable "enable_shared_key_access" {
  type        = bool
  description = "(Optional) Enable shared key access (account keys)."
  default     = true
}

# Default to OAuth authentication
variable "default_to_oauth_authentication" {
  type        = bool
  description = "(Optional) Default to Azure AD authentication for data plane requests."
  default     = false
}

###########################
# Managed Identity
###########################

# Enable managed identity
variable "enable_identity" {
  type        = bool
  description = "(Optional) Enable managed identity on the storage account."
  default     = false
}

# Managed identity type
variable "identity_type" {
  type        = string
  description = "(Optional) Managed identity type (SystemAssigned, UserAssigned, or SystemAssigned, UserAssigned)."
  default     = "SystemAssigned"
  validation {
    condition     = contains(["SystemAssigned", "UserAssigned", "SystemAssigned, UserAssigned"], var.identity_type)
    error_message = "identity_type must be SystemAssigned, UserAssigned, or SystemAssigned, UserAssigned."
  }
}

# Managed identity IDs
variable "identity_ids" {
  type        = list(string)
  description = "(Optional) List of user-assigned managed identity IDs."
  default     = []
}

###########################
# Blob Properties
###########################

# Enable blob properties configuration
variable "enable_blob_properties" {
  type        = bool
  description = "(Optional) Enable blob properties configuration."
  default     = false
}

# Enable blob versioning
variable "blob_versioning_enabled" {
  type        = bool
  description = "(Optional) Enable blob versioning."
  default     = false
}

# Enable change feed
variable "blob_change_feed_enabled" {
  type        = bool
  description = "(Optional) Enable blob change feed."
  default     = false
}

# Enable last access time tracking
variable "blob_last_access_time_enabled" {
  type        = bool
  description = "(Optional) Enable blob last access time tracking."
  default     = false
}

# Default service version
variable "blob_default_service_version" {
  type        = string
  description = "(Optional) Default service version for blob requests."
  default     = null
}

# Delete retention policy days
variable "blob_delete_retention_days" {
  type        = number
  description = "(Optional) Number of days to retain deleted blobs."
  default     = null
  validation {
    condition     = var.blob_delete_retention_days == null || (var.blob_delete_retention_days >= 1 && var.blob_delete_retention_days <= 365)
    error_message = "blob_delete_retention_days must be between 1 and 365."
  }
}

# Container delete retention policy days
variable "blob_container_delete_retention_days" {
  type        = number
  description = "(Optional) Number of days to retain deleted containers."
  default     = null
  validation {
    condition     = var.blob_container_delete_retention_days == null || (var.blob_container_delete_retention_days >= 1 && var.blob_container_delete_retention_days <= 365)
    error_message = "blob_container_delete_retention_days must be between 1 and 365."
  }
}

###########################
# Static Website
###########################

# Enable static website hosting
variable "enable_static_website" {
  type        = bool
  description = "(Optional) Enable static website hosting."
  default     = false
}

# Static website index document
variable "static_website_index_document" {
  type        = string
  description = "(Optional) Index document for static website hosting."
  default     = "index.html"
}

# Static website error document
variable "static_website_error_404_document" {
  type        = string
  description = "(Optional) Error document for static website hosting."
  default     = "404.html"
}

###########################
# Custom Domain
###########################

# Enable custom domain
variable "enable_custom_domain" {
  type        = bool
  description = "(Optional) Enable custom domain mapping."
  default     = false
}

# Custom domain name
variable "custom_domain_name" {
  type        = string
  description = "(Optional) Custom domain name for the storage account."
  default     = null
}

# Use subdomain for custom domain
variable "custom_domain_use_subdomain" {
  type        = bool
  description = "(Optional) Use subdomain for the custom domain (e.g., cdn verify)."
  default     = false
}

###########################
# Routing
###########################

# Enable routing configuration
variable "enable_routing" {
  type        = bool
  description = "(Optional) Enable routing configuration."
  default     = false
}

# Routing choice
variable "routing_choice" {
  type        = string
  description = "(Optional) Routing choice for the storage account (MicrosoftRouting or InternetRouting)."
  default     = "MicrosoftRouting"
  validation {
    condition     = contains(["MicrosoftRouting", "InternetRouting"], var.routing_choice)
    error_message = "routing_choice must be MicrosoftRouting or InternetRouting."
  }
}

# Publish internet endpoints
variable "routing_publish_internet_endpoints" {
  type        = bool
  description = "(Optional) Publish internet endpoints for routing."
  default     = false
}

# Publish Microsoft endpoints
variable "routing_publish_microsoft_endpoints" {
  type        = bool
  description = "(Optional) Publish Microsoft endpoints for routing."
  default     = false
}

###########################
# Storage Account Network Rules
###########################

# Enable storage account network rules
variable "enable_network_rules" {
  type        = bool
  description = "(Optional) Enable storage account network rules."
  default     = false
}

# Network rules default action
variable "network_rules_default_action" {
  type        = string
  description = "(Optional) Default action for storage account network rules."
  default     = "Deny"
  validation {
    condition     = contains(["Allow", "Deny"], var.network_rules_default_action)
    error_message = "network_rules_default_action must be Allow or Deny."
  }
}

# Network rules bypass
variable "network_rules_bypass" {
  type        = list(string)
  description = "(Optional) Services to bypass storage account network rules."
  default     = ["AzureServices"]
}

# Network rules IP allow list
variable "network_rules_ip_rules" {
  type        = list(string)
  description = "(Optional) List of public IPs or CIDRs to allow."
  default     = []
}

# Network rules VNet allow list
variable "network_rules_virtual_network_subnet_ids" {
  type        = list(string)
  description = "(Optional) List of subnet IDs to allow."
  default     = []
}

# Network rules private link access list
variable "network_rules_private_link_access" {
  type = list(object({
    endpoint_resource_id = string
    endpoint_tenant_id   = string
  }))
  description = "(Optional) List of private link access definitions."
  default     = []
}

###########################
# Private Endpoint
###########################

# Enable private endpoint
variable "enable_private_endpoint" {
  type        = bool
  description = "(Optional) Enable a private endpoint for the storage account."
  default     = false
}

# Private endpoint name
variable "private_endpoint_name" {
  type        = string
  description = "(Optional) Name of the private endpoint."
  default     = null
}

# Private endpoint subnet ID
variable "private_endpoint_subnet_id" {
  type        = string
  description = "(Optional) Subnet ID for the private endpoint. Required when enable_private_endpoint is true."
  default     = null
  validation {
    condition     = var.enable_private_endpoint == false || (var.private_endpoint_subnet_id != null && var.private_endpoint_subnet_id != "")
    error_message = "private_endpoint_subnet_id must be provided when enable_private_endpoint is true."
  }
}

# Private endpoint resource group name
variable "private_endpoint_resource_group_name" {
  type        = string
  description = "(Optional) Resource group name for the private endpoint. Defaults to storage account resource group."
  default     = null
}

# Private endpoint location
variable "private_endpoint_location" {
  type        = string
  description = "(Optional) Location for the private endpoint. Defaults to storage account location."
  default     = null
}

# Private DNS zone ID
variable "private_dns_zone_id" {
  type        = string
  description = "(Optional) Private DNS zone ID for blob private endpoint integration."
  default     = null
}

###########################
# Blob Containers
###########################

# Containers map
variable "containers" {
  type = map(object({
    access_type = string
  }))
  description = "(Optional) Map of container names to access settings. Access type options: private, blob, or container."
  default     = {}
  validation {
    condition     = alltrue([for container in values(var.containers) : contains(["private", "blob", "container"], container.access_type)])
    error_message = "containers access_type must be private, blob, or container."
  }
}

###########################
# Tags
###########################

# Resource tags
variable "tags" {
  type        = map(any)
  description = "(Optional) A mapping of tags to assign to the resources."
  default = {
    terraform = "true"
  }
}
