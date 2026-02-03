###########################
# Public IP Outputs
###########################

output "id" {
  description = "The ID of the Public IP."
  value       = azurerm_public_ip.this.id
}

output "name" {
  description = "The name of the Public IP."
  value       = azurerm_public_ip.this.name
}

output "ip_address" {
  description = "The allocated public IP address."
  value       = azurerm_public_ip.this.ip_address
}

output "fqdn" {
  description = "The DNS FQDN assigned to the Public IP (if domain_name_label is set)."
  value       = azurerm_public_ip.this.fqdn
}
