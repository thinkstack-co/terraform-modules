###########################
# Required
###########################

variable "name" {
  description = "(Required) Name of the Virtual Network Gateway."
  type        = string
}

variable "resource_group_name" {
  description = "(Required) Resource group name for the VPN resources."
  type        = string
}

variable "location" {
  description = "(Required) Azure region for the VPN resources."
  type        = string
  default     = "eastus"
}

variable "vnet_name" {
  description = "(Required) VNet name where the GatewaySubnet exists."
  type        = string
}

variable "local_network_gateway_name" {
  description = "(Required) Name of the local network gateway."
  type        = string
}

variable "local_gateway_address" {
  description = "(Required) Public IP of the on-prem or vendor gateway."
  type        = string
}

variable "local_address_space" {
  description = "(Required) Address spaces for the on-prem or vendor network."
  type        = list(string)
}

variable "shared_key" {
  description = "(Required) Pre-shared key for the VPN connection."
  type        = string
  sensitive   = true
}

###########################
# Optional
###########################

variable "vnet_resource_group_name" {
  description = "(Optional) Resource group of the target VNet. Defaults to resource_group_name."
  type        = string
  default     = ""
}

variable "public_ip_name" {
  description = "(Optional) Public IP name for the VPN gateway."
  type        = string
  default     = "vpn-gateway-pip"
}

variable "ip_configuration_name" {
  description = "(Optional) IP configuration name for the VPN gateway."
  type        = string
  default     = "vpn-ipconfig"
}

variable "vpn_type" {
  description = "(Optional) VPN type (RouteBased or PolicyBased)."
  type        = string
  default     = "RouteBased"

  validation {
    condition     = contains(["RouteBased", "PolicyBased"], var.vpn_type)
    error_message = "vpn_type must be RouteBased or PolicyBased."
  }
}

variable "sku" {
  description = "(Optional) VPN gateway SKU."
  type        = string
  default     = "VpnGw1"
}

variable "generation" {
  description = "(Optional) VPN gateway generation (Generation1 or Generation2)."
  type        = string
  default     = "Generation1"

  validation {
    condition     = contains(["Generation1", "Generation2"], var.generation)
    error_message = "generation must be Generation1 or Generation2."
  }
}

variable "active_active" {
  description = "(Optional) Enable active-active VPN gateways."
  type        = bool
  default     = false
}

variable "enable_bgp" {
  description = "(Optional) Enable BGP for the VPN gateway and connection."
  type        = bool
  default     = false
}

variable "connection_name" {
  description = "(Optional) Name of the VPN connection."
  type        = string
  default     = "vpn-connection"
}

variable "connection_protocol" {
  description = "(Optional) VPN connection protocol."
  type        = string
  default     = "IKEv2"

  validation {
    condition     = contains(["IKEv2", "IKEv1"], var.connection_protocol)
    error_message = "connection_protocol must be IKEv1 or IKEv2."
  }
}

variable "tags" {
  description = "(Optional) A mapping of tags to assign to the resources."
  type        = map(string)
  default = {
    terraform   = "true"
    created_by  = "ThinkStack"
    environment = "prod"
    priority    = "high"
  }
}
