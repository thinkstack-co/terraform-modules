###########################
# Storage Account Outputs
###########################

# Storage account ID
output "storage_account_id" {
  description = "The ID of the storage account."
  value       = azurerm_storage_account.storage.id
}

# Storage account name
output "storage_account_name" {
  description = "The name of the storage account."
  value       = azurerm_storage_account.storage.name
}

# Storage account blob endpoint
output "primary_blob_endpoint" {
  description = "The primary blob endpoint URL."
  value       = azurerm_storage_account.storage.primary_blob_endpoint
}

# Storage account connection string
output "primary_connection_string" {
  description = "The primary connection string for the storage account."
  value       = azurerm_storage_account.storage.primary_connection_string
  sensitive   = true
}

# Storage account access key
output "primary_access_key" {
  description = "The primary access key for the storage account."
  value       = azurerm_storage_account.storage.primary_access_key
  sensitive   = true
}

# Static website endpoint
output "static_website_endpoint" {
  description = "The static website endpoint (if enabled)."
  value       = var.enable_static_website ? azurerm_storage_account.storage.primary_web_endpoint : null
}

# Static website host
output "static_website_host" {
  description = "The static website host (if enabled)."
  value       = var.enable_static_website ? azurerm_storage_account.storage.primary_web_host : null
}

###########################
# Container Outputs
###########################

# Container IDs
output "container_ids" {
  description = "Map of container names to container IDs."
  value       = { for name, container in azurerm_storage_container.containers : name => container.id }
}

###########################
# Identity Outputs
###########################

# Managed identity principal ID
output "identity_principal_id" {
  description = "The principal ID for the managed identity (if enabled)."
  value       = var.enable_identity ? azurerm_storage_account.storage.identity[0].principal_id : null
}

# Managed identity tenant ID
output "identity_tenant_id" {
  description = "The tenant ID for the managed identity (if enabled)."
  value       = var.enable_identity ? azurerm_storage_account.storage.identity[0].tenant_id : null
}

###########################
# Feature Flags Outputs
###########################

# Hierarchical namespace enabled
output "hns_enabled" {
  description = "Whether hierarchical namespace (HNS) is enabled."
  value       = azurerm_storage_account.storage.is_hns_enabled
}

# SFTP enabled
output "sftp_enabled" {
  description = "Whether SFTP is enabled."
  value       = azurerm_storage_account.storage.sftp_enabled
}

# NFS v3 enabled
output "nfs_v3_enabled" {
  description = "Whether NFS v3 is enabled."
  value       = azurerm_storage_account.storage.nfsv3_enabled
}

# Infrastructure encryption enabled
output "infrastructure_encryption_enabled" {
  description = "Whether infrastructure encryption is enabled."
  value       = azurerm_storage_account.storage.infrastructure_encryption_enabled
}

# Cross-tenant replication enabled
output "cross_tenant_replication_enabled" {
  description = "Whether cross-tenant replication is enabled."
  value       = azurerm_storage_account.storage.cross_tenant_replication_enabled
}

# Shared key access enabled
output "shared_access_key_enabled" {
  description = "Whether shared access key authentication is enabled."
  value       = azurerm_storage_account.storage.shared_access_key_enabled
}

# Default to OAuth authentication
output "default_to_oauth_authentication" {
  description = "Whether OAuth authentication is the default for data plane requests."
  value       = azurerm_storage_account.storage.default_to_oauth_authentication
}

###########################
# Custom Domain Outputs
###########################

# Custom domain name
output "custom_domain_name" {
  description = "The custom domain name (if enabled)."
  value       = var.enable_custom_domain ? azurerm_storage_account.storage.custom_domain[0].name : null
}

# Custom domain uses subdomain
output "custom_domain_use_subdomain" {
  description = "Whether the custom domain uses a subdomain (if enabled)."
  value       = var.enable_custom_domain ? azurerm_storage_account.storage.custom_domain[0].use_subdomain : null
}

###########################
# Routing Outputs
###########################

# Routing choice
output "routing_choice" {
  description = "The routing choice (if enabled)."
  value       = var.enable_routing ? azurerm_storage_account.storage.routing[0].choice : null
}

# Routing publish internet endpoints
output "routing_publish_internet_endpoints" {
  description = "Whether routing publishes internet endpoints (if enabled)."
  value       = var.enable_routing ? azurerm_storage_account.storage.routing[0].publish_internet_endpoints : null
}

# Routing publish Microsoft endpoints
output "routing_publish_microsoft_endpoints" {
  description = "Whether routing publishes Microsoft endpoints (if enabled)."
  value       = var.enable_routing ? azurerm_storage_account.storage.routing[0].publish_microsoft_endpoints : null
}

###########################
# Private Endpoint Outputs
###########################

# Private endpoint ID
output "private_endpoint_id" {
  description = "The ID of the private endpoint (if created)."
  value       = var.enable_private_endpoint ? azurerm_private_endpoint.storage_blob[0].id : null
}

# Private endpoint name
output "private_endpoint_name" {
  description = "The name of the private endpoint (if created)."
  value       = var.enable_private_endpoint ? azurerm_private_endpoint.storage_blob[0].name : null
}

# Private endpoint IP
output "private_endpoint_private_ip" {
  description = "The private IP address of the private endpoint (if created)."
  value       = var.enable_private_endpoint ? azurerm_private_endpoint.storage_blob[0].private_service_connection[0].private_ip_address : null
}

# Private DNS zone group ID
output "private_dns_zone_group_id" {
  description = "The ID of the private DNS zone group (if created)."
  value       = var.enable_private_endpoint && var.private_dns_zone_id != null ? azurerm_private_dns_zone_group.storage_blob[0].id : null
}
