###########################
# Application Gateway Outputs
###########################

# Application Gateway ID
output "id" {
  description = "The ID of the Application Gateway."
  value       = azurerm_application_gateway.this.id
}

# Application Gateway name
output "name" {
  description = "The name of the Application Gateway."
  value       = azurerm_application_gateway.this.name
}

# Application Gateway frontend IP configuration name
output "frontend_ip_configuration_name" {
  description = "The frontend IP configuration name."
  value       = azurerm_application_gateway.this.frontend_ip_configuration[0].name
}

# Application Gateway frontend port name
output "frontend_port_name" {
  description = "The frontend port name."
  value       = azurerm_application_gateway.this.frontend_port[0].name
}

# Application Gateway backend address pool name
output "backend_address_pool_name" {
  description = "The backend address pool name."
  value       = azurerm_application_gateway.this.backend_address_pool[0].name
}

# Application Gateway backend HTTP settings name
output "backend_http_settings_name" {
  description = "The backend HTTP settings name."
  value       = azurerm_application_gateway.this.backend_http_settings[0].name
}

# Application Gateway HTTP listener name
output "http_listener_name" {
  description = "The HTTP listener name."
  value       = azurerm_application_gateway.this.http_listener[0].name
}

# Application Gateway HTTPS listener name
output "https_listener_name" {
  description = "The HTTPS listener name (if enabled)."
  value       = var.enable_https_listener ? one([for listener in azurerm_application_gateway.this.http_listener : listener.name if listener.name == var.https_listener_name]) : null
}

# Application Gateway routing rule name
output "request_routing_rule_name" {
  description = "The request routing rule name."
  value       = azurerm_application_gateway.this.request_routing_rule[0].name
}

# Application Gateway URL path map name
output "url_path_map_name" {
  description = "The URL path map name (if enabled)."
  value       = var.enable_path_based_routing ? azurerm_application_gateway.this.url_path_map[0].name : null
}

# Application Gateway WAF policy ID
output "waf_policy_id" {
  description = "The WAF policy ID attached to the Application Gateway (if set)."
  value       = azurerm_application_gateway.this.firewall_policy_id
}
