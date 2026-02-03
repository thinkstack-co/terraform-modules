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
# Application Gateway
###########################

locals {
  # Use HTTPS listener for routing when enabled
  routing_listener_name = var.enable_https_listener ? var.https_listener_name : var.http_listener_name

  # Force path-based routing rule type when enabled
  routing_rule_type = var.enable_path_based_routing ? "PathBasedRouting" : var.request_routing_rule_type
}

resource "azurerm_application_gateway" "this" {
  # Application Gateway name
  name = var.name

  # Location and resource group where the Application Gateway will be created
  location            = var.location
  resource_group_name = var.resource_group_name

  # Optional HTTP/2 support
  enable_http2 = var.enable_http2

  # Optional WAF policy attachment
  firewall_policy_id = var.waf_policy_id

  # Gateway SKU and capacity
  sku {
    name     = var.sku_name
    tier     = var.sku_tier
    capacity = var.sku_capacity
  }

  # Gateway subnet configuration (dedicated subnet required)
  gateway_ip_configuration {
    name      = var.gateway_ip_configuration_name
    subnet_id = var.gateway_subnet_id
  }

  # Frontend listener port
  frontend_port {
    name = var.frontend_port_name
    port = var.frontend_port
  }

  # HTTPS frontend port (when enabled)
  dynamic "frontend_port" {
    for_each = var.enable_https_listener ? [1] : []
    content {
      name = var.https_frontend_port_name
      port = var.https_frontend_port
    }
  }

  # Frontend IP configuration (public IP)
  frontend_ip_configuration {
    name                 = var.frontend_ip_configuration_name
    public_ip_address_id = var.frontend_public_ip_id
  }

  # Backend pool configuration
  backend_address_pool {
    name         = var.backend_address_pool_name
    ip_addresses = var.backend_pool_ip_addresses
  }

  # Additional backend pools (optional)
  dynamic "backend_address_pool" {
    for_each = var.additional_backend_pools
    content {
      name         = backend_address_pool.key
      ip_addresses = backend_address_pool.value
    }
  }

  # Backend HTTP settings
  backend_http_settings {
    name                  = var.backend_http_settings_name
    port                  = var.backend_http_settings_port
    protocol              = var.backend_http_settings_protocol
    cookie_based_affinity = var.backend_http_settings_cookie_based_affinity
    request_timeout       = var.backend_http_settings_request_timeout
  }

  # Additional backend HTTP settings (optional)
  dynamic "backend_http_settings" {
    for_each = var.additional_backend_http_settings
    content {
      name                  = backend_http_settings.key
      port                  = backend_http_settings.value.port
      protocol              = backend_http_settings.value.protocol
      cookie_based_affinity = backend_http_settings.value.cookie_based_affinity
      request_timeout       = backend_http_settings.value.request_timeout
    }
  }

  # HTTP listener configuration
  http_listener {
    name                           = var.http_listener_name
    frontend_ip_configuration_name = var.frontend_ip_configuration_name
    frontend_port_name             = var.frontend_port_name
    protocol                       = var.http_listener_protocol
    host_name                      = var.http_listener_host_name
  }

  # HTTPS listener configuration (when enabled)
  dynamic "http_listener" {
    for_each = var.enable_https_listener ? [1] : []
    content {
      name                           = var.https_listener_name
      frontend_ip_configuration_name = var.frontend_ip_configuration_name
      frontend_port_name             = var.https_frontend_port_name
      protocol                       = "Https"
      host_name                      = var.https_listener_host_name
      ssl_certificate_name           = var.ssl_certificate_name
    }
  }

  # SSL certificate configuration (when HTTPS is enabled)
  dynamic "ssl_certificate" {
    for_each = var.enable_https_listener ? [1] : []
    content {
      name     = var.ssl_certificate_name
      data     = var.ssl_certificate_data
      password = var.ssl_certificate_password
    }
  }

  # URL path map configuration (when path-based routing is enabled)
  dynamic "url_path_map" {
    for_each = var.enable_path_based_routing ? [1] : []
    content {
      name                               = var.path_map_name
      default_backend_address_pool_name  = var.path_map_default_backend_pool_name
      default_backend_http_settings_name = var.path_map_default_backend_http_settings_name

      dynamic "path_rule" {
        for_each = var.path_rules
        content {
          name                       = path_rule.value.name
          paths                      = path_rule.value.paths
          backend_address_pool_name  = path_rule.value.backend_address_pool_name
          backend_http_settings_name = path_rule.value.backend_http_settings_name
        }
      }
    }
  }

  # Request routing rule
  request_routing_rule {
    name                       = var.request_routing_rule_name
    rule_type                  = local.routing_rule_type
    http_listener_name         = local.routing_listener_name
    backend_address_pool_name  = var.enable_path_based_routing ? null : var.backend_address_pool_name
    backend_http_settings_name = var.enable_path_based_routing ? null : var.backend_http_settings_name
    url_path_map_name          = var.enable_path_based_routing ? var.path_map_name : null
    priority                   = var.request_routing_rule_priority
  }

  # Standard tags + Name tag for convenience
  tags = merge(tomap({ Name = var.name }), var.tags)
}
