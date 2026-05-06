###########################
# Public IP Outputs
###########################

# Public IP ID
output "id" {
  description = "The ID of the Public IP."
  value       = module.public_ip.id
}

# Public IP name
output "name" {
  description = "The name of the Public IP."
  value       = module.public_ip.name
}

# Public IP address
output "ip_address" {
  description = "The allocated public IP address."
  value       = module.public_ip.ip_address
}

# Public IP FQDN
output "fqdn" {
  description = "The DNS FQDN assigned to the Public IP (if domain_name_label is set)."
  value       = module.public_ip.fqdn
}
