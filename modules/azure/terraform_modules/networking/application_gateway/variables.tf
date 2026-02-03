###########################
# Required
###########################

variable "name" {
  description = "(Required) Name of the Application Gateway."
  type        = string
}

variable "resource_group_name" {
  description = "(Required) The name of an existing resource group in which to create the Application Gateway."
  type        = string
}

variable "gateway_subnet_id" {
  description = "(Required) The subnet ID for the Application Gateway (dedicated subnet)."
  type        = string
}

variable "frontend_public_ip_id" {
  description = "(Required) The public IP ID for the frontend IP configuration."
  type        = string
}

variable "backend_pool_ip_addresses" {
  description = "(Required) List of backend IP addresses for the backend pool."
  type        = list(string)
}

###########################
# Optional
###########################

variable "location" {
  description = "(Optional) The Azure region where resources will be created."
  type        = string
  default     = "eastus"
}

variable "enable_http2" {
  description = "(Optional) Enable HTTP/2 on the Application Gateway."
  type        = bool
  default     = false
}

variable "waf_policy_id" {
  description = "(Optional) WAF policy ID to attach to the Application Gateway."
  type        = string
  default     = null
}

variable "sku_name" {
  description = "(Optional) Application Gateway SKU name."
  type        = string
  default     = "Standard_v2"

  validation {
    condition     = contains(["Standard_v2", "WAF_v2"], var.sku_name)
    error_message = "sku_name must be Standard_v2 or WAF_v2."
  }
}

variable "_validate_https_cert" {
  description = "(Internal) Ensures certificate data is provided when HTTPS is enabled."
  type        = bool
  default     = true

  validation {
    condition     = !var.enable_https_listener || (var.ssl_certificate_data != null && var.ssl_certificate_password != null)
    error_message = "ssl_certificate_data and ssl_certificate_password are required when enable_https_listener is true."
  }
}

variable "_validate_path_rules" {
  description = "(Internal) Ensures path rules are provided when path-based routing is enabled."
  type        = bool
  default     = true

  validation {
    condition     = !var.enable_path_based_routing || length(var.path_rules) > 0
    error_message = "path_rules must be provided when enable_path_based_routing is true."
  }
}

variable "sku_tier" {
  description = "(Optional) Application Gateway SKU tier."
  type        = string
  default     = "Standard_v2"

  validation {
    condition     = contains(["Standard_v2", "WAF_v2"], var.sku_tier)
    error_message = "sku_tier must be Standard_v2 or WAF_v2."
  }
}

variable "sku_capacity" {
  description = "(Optional) Instance capacity for the Application Gateway."
  type        = number
  default     = 2
}

variable "gateway_ip_configuration_name" {
  description = "(Optional) Name of the gateway IP configuration."
  type        = string
  default     = "appgw-gateway-ip"
}

variable "frontend_port_name" {
  description = "(Optional) Name of the frontend port."
  type        = string
  default     = "appgw-frontend-port"
}

variable "frontend_port" {
  description = "(Optional) Frontend port number."
  type        = number
  default     = 80
}

variable "enable_https_listener" {
  description = "(Optional) Enable an HTTPS listener with SSL certificate."
  type        = bool
  default     = false
}

variable "https_frontend_port_name" {
  description = "(Optional) Name of the HTTPS frontend port."
  type        = string
  default     = "appgw-https-frontend-port"
}

variable "https_frontend_port" {
  description = "(Optional) HTTPS frontend port number."
  type        = number
  default     = 443
}

variable "frontend_ip_configuration_name" {
  description = "(Optional) Name of the frontend IP configuration."
  type        = string
  default     = "appgw-frontend-ip"
}

variable "backend_address_pool_name" {
  description = "(Optional) Name of the backend address pool."
  type        = string
  default     = "appgw-backend-pool"
}

variable "additional_backend_pools" {
  description = "(Optional) Additional backend pools keyed by name with IP address lists."
  type        = map(list(string))
  default     = {}
}

variable "backend_http_settings_name" {
  description = "(Optional) Name of the backend HTTP settings."
  type        = string
  default     = "appgw-backend-http"
}

variable "backend_http_settings_port" {
  description = "(Optional) Backend HTTP port."
  type        = number
  default     = 80
}

variable "backend_http_settings_protocol" {
  description = "(Optional) Backend HTTP protocol."
  type        = string
  default     = "Http"

  validation {
    condition     = contains(["Http", "Https"], var.backend_http_settings_protocol)
    error_message = "backend_http_settings_protocol must be Http or Https."
  }
}

variable "backend_http_settings_cookie_based_affinity" {
  description = "(Optional) Cookie-based affinity setting (Enabled or Disabled)."
  type        = string
  default     = "Disabled"

  validation {
    condition     = contains(["Enabled", "Disabled"], var.backend_http_settings_cookie_based_affinity)
    error_message = "backend_http_settings_cookie_based_affinity must be Enabled or Disabled."
  }
}

variable "backend_http_settings_request_timeout" {
  description = "(Optional) Request timeout in seconds."
  type        = number
  default     = 30
}

variable "additional_backend_http_settings" {
  description = "(Optional) Additional backend HTTP settings keyed by name."
  type = map(object({
    port                  = number
    protocol              = string
    cookie_based_affinity = string
    request_timeout       = number
  }))
  default = {}
}

variable "http_listener_name" {
  description = "(Optional) Name of the HTTP listener."
  type        = string
  default     = "appgw-http-listener"
}

variable "http_listener_protocol" {
  description = "(Optional) Listener protocol."
  type        = string
  default     = "Http"

  validation {
    condition     = contains(["Http", "Https"], var.http_listener_protocol)
    error_message = "http_listener_protocol must be Http or Https."
  }
}

variable "http_listener_host_name" {
  description = "(Optional) Host name for the listener."
  type        = string
  default     = null
}

variable "https_listener_name" {
  description = "(Optional) Name of the HTTPS listener."
  type        = string
  default     = "appgw-https-listener"
}

variable "https_listener_host_name" {
  description = "(Optional) Host name for the HTTPS listener."
  type        = string
  default     = null
}

variable "ssl_certificate_name" {
  description = "(Optional) Name of the SSL certificate when HTTPS is enabled."
  type        = string
  default     = "appgw-ssl-cert"
}

variable "ssl_certificate_data" {
  description = "(Optional) Base64-encoded PFX data for the SSL certificate."
  type        = string
  default     = null
}

variable "ssl_certificate_password" {
  description = "(Optional) Password for the SSL certificate PFX."
  type        = string
  default     = null
  sensitive   = true
}

variable "request_routing_rule_name" {
  description = "(Optional) Name of the request routing rule."
  type        = string
  default     = "appgw-routing-rule"
}

variable "request_routing_rule_type" {
  description = "(Optional) Routing rule type (Basic or PathBasedRouting)."
  type        = string
  default     = "Basic"

  validation {
    condition     = contains(["Basic", "PathBasedRouting"], var.request_routing_rule_type)
    error_message = "request_routing_rule_type must be Basic or PathBasedRouting."
  }
}

variable "request_routing_rule_priority" {
  description = "(Optional) Priority for the request routing rule."
  type        = number
  default     = 100
}

variable "enable_path_based_routing" {
  description = "(Optional) Enable path-based routing with URL path maps."
  type        = bool
  default     = false
}

variable "path_map_name" {
  description = "(Optional) Name of the URL path map."
  type        = string
  default     = "appgw-path-map"
}

variable "path_map_default_backend_pool_name" {
  description = "(Optional) Default backend pool name for the path map."
  type        = string
  default     = "appgw-backend-pool"
}

variable "path_map_default_backend_http_settings_name" {
  description = "(Optional) Default backend HTTP settings name for the path map."
  type        = string
  default     = "appgw-backend-http"
}

variable "path_rules" {
  description = "(Optional) Path rules for path-based routing."
  type = list(object({
    name                       = string
    paths                      = list(string)
    backend_address_pool_name  = string
    backend_http_settings_name = string
  }))
  default = []
}

variable "tags" {
  description = "(Optional) A mapping of tags to assign to the resource."
  type        = map(string)
  default = {
    terraform   = "true"
    created_by  = "ThinkStack"
    environment = "prod"
    priority    = "high"
  }
}

###########################
# Cross-variable validation
###########################

variable "_validate_sku_tier" {
  description = "(Internal) Enforces that sku_name and sku_tier align."
  type        = bool
  default     = true

  validation {
    condition     = var.sku_name == var.sku_tier
    error_message = "sku_name and sku_tier must match (Standard_v2 or WAF_v2)."
  }
}
