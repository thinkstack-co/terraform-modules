###########################
# Resource Group
###########################
# Note: Resource group must be created separately using the resource group module

variable "resource_group_name" {
  description = "(Required) The name of an existing resource group in which to create the VNet."
  type        = string
}

variable "location" {
  description = "(Required) The Azure region where resources will be created."
  type        = string
  default     = "eastus"
}

###########################
# Virtual Network
###########################

variable "vnet_address_space" {
  description = "The address space for the Virtual Network"
  type        = string
  default     = "10.100.0.0/16"
}

variable "enable_vpn_subnet" {
  description = "(Optional) Create a dedicated GatewaySubnet in the last /24 of the VNet address space."
  type        = bool
  default     = false
}

variable "enable_application_gateway_subnet" {
  description = "(Optional) Create a dedicated AzureApplicationGatewaySubnet in the last /24s of the VNet address space."
  type        = bool
  default     = false
}

variable "enable_firewall_subnet" {
  description = "(Optional) Create a dedicated AzureFirewallSubnet in the last /24s of the VNet address space."
  type        = bool
  default     = false
}

variable "dns_servers" {
  description = "(Optional) List of DNS servers to use for the VNet. If empty, Azure default DNS is used."
  type        = list(string)
  default     = []
}

###########################
# Subnets
###########################

variable "private_subnets_list" {
  type        = list(string)
  description = "A list of private subnets inside the VNet."
  default     = ["10.100.1.0/24"]
}

variable "public_subnets_list" {
  type        = list(string)
  description = "A list of public subnets inside the VNet."
  default     = ["10.100.2.0/24"]
}

variable "enable_db_subnets" {
  description = "(Optional) Enable creation of database subnets."
  type        = bool
  default     = false
}

variable "db_subnets_list" {
  type        = list(string)
  description = "A list of database subnets inside the VNet."
  default     = ["10.100.11.0/24"]
}

###########################
# CIDR Validation
###########################

variable "_validate_vnet_prefix" {
  description = "(Internal) Enforces that the VNet is /16."
  type        = bool
  default     = true

  validation {
    # Only validate when the internal flag is enabled.
    condition     = var._validate_vnet_prefix ? tonumber(regex("[0-9]+$", var.vnet_address_space)) == 16 : true
    error_message = "vnet_address_space must be /16 (e.g., 10.100.0.0/16)."
  }
}

variable "_validate_subnet_prefixes" {
  description = "(Internal) Enforces that all subnets are /24."
  type        = bool
  default     = true

  validation {
    # Only validate when the internal flag is enabled.
    condition = var._validate_subnet_prefixes ? alltrue([
      for cidr in concat(
        var.private_subnets_list,
        var.public_subnets_list,
        var.enable_db_subnets ? var.db_subnets_list : []
      ) : tonumber(regex("[0-9]+$", cidr)) == 24
    ]) : true
    error_message = "All subnet CIDRs must be /24."
  }
}

variable "_validate_subnet_counts" {
  description = "(Internal) Enforces one subnet for private/public and optional single DB subnet when enabled."
  type        = bool
  default     = true

  validation {
    # Only validate when the internal flag is enabled.
    condition = var._validate_subnet_counts ? length(var.private_subnets_list) == 1 && length(var.public_subnets_list) == 1 && (var.enable_db_subnets ? length(var.db_subnets_list) == 1 : length(var.db_subnets_list) <= 1) : true
    error_message = "private_subnets_list and public_subnets_list must each contain exactly one /24 subnet. If enable_db_subnets is true, db_subnets_list must contain exactly one /24 subnet."
  }
}

###########################
# Service Endpoints
###########################

variable "enable_service_endpoints" {
  type        = bool
  description = "(Optional) A boolean flag to enable/disable service endpoints on private subnets. Defaults false."
  default     = false
}

variable "service_endpoints" {
  type        = list(string)
  description = "(Optional) List of service endpoints to enable on private subnets."
  default     = ["Microsoft.Storage", "Microsoft.KeyVault", "Microsoft.Sql"]
}

###########################
# NAT Gateway
###########################

variable "enable_nat_gateway" {
  description = "(Optional) A boolean flag to enable/disable the use of NAT gateways in the private subnets. Defaults True."
  type        = bool
  default     = true
}

variable "single_nat_gateway" {
  type        = bool
  description = "(Optional) A boolean flag to enable/disable use of only a single shared NAT Gateway across all private networks. Defaults False."
  default     = false
}

variable "nat_gateway_idle_timeout" {
  type        = number
  description = "(Optional) Idle timeout in minutes for NAT Gateway. Valid values are between 4 and 120. Defaults to 4."
  default     = 4
}

variable "nat_gateway_zones" {
  type        = list(string)
  description = "(Optional) A list of availability zones where the NAT Gateway should be created. Defaults to no zones (regional)."
  default     = []
}

###########################
# Network Watcher & Flow Logs
###########################

variable "enable_flow_logs" {
  description = "(Optional) A boolean flag to enable/disable the use of VNet flow logs. Defaults True."
  type        = bool
  default     = true
}

variable "create_network_watcher" {
  description = "(Optional) Whether to create a new Network Watcher. If false, existing Network Watcher must be provided. Defaults False."
  type        = bool
  default     = false
}

variable "network_watcher_name" {
  description = "(Optional) Name of existing Network Watcher to use for flow logs. Required if create_network_watcher is false and enable_flow_logs is true."
  type        = string
  default     = ""
}

variable "network_watcher_resource_group_name" {
  description = "(Optional) Resource group name of existing Network Watcher. Required if create_network_watcher is false and enable_flow_logs is true."
  type        = string
  default     = ""
}

variable "flow_logs_storage_account_tier" {
  description = "(Optional) Storage account tier for flow logs. Valid values are Standard or Premium. Defaults to Standard."
  type        = string
  default     = "Standard"
}

variable "flow_logs_storage_replication_type" {
  description = "(Optional) Storage account replication type for flow logs. Valid values are LRS, GRS, RAGRS, ZRS, GZRS, RAGZRS. Defaults to LRS."
  type        = string
  default     = "LRS"
}

variable "flow_logs_retention_days" {
  description = "(Optional) Number of days to retain flow logs. Defaults to 90."
  type        = number
  default     = 90
}

variable "enable_traffic_analytics" {
  description = "(Optional) Enable traffic analytics for flow logs. Requires Log Analytics workspace. Defaults False."
  type        = bool
  default     = false
}

variable "log_analytics_workspace_id" {
  description = "(Optional) Log Analytics workspace ID for traffic analytics. Required if enable_traffic_analytics is true."
  type        = string
  default     = ""
}

variable "log_analytics_workspace_resource_id" {
  description = "(Optional) Log Analytics workspace resource ID for traffic analytics. Required if enable_traffic_analytics is true."
  type        = string
  default     = ""
}

variable "traffic_analytics_interval" {
  description = "(Optional) Traffic analytics interval in minutes. Valid values are 10 or 60. Defaults to 60."
  type        = number
  default     = 60
}

###########################
# General Use Variables
###########################

variable "name" {
  description = "(Required) Name to be tagged on all of the resources as an identifier"
  type        = string
}

variable "tags" {
  type        = map(string)
  description = "(Optional) A mapping of tags to assign to the resources."
  default = {
    terraform   = "true"
    created_by  = "ThinkStack"
    environment = "prod"
    priority    = "high"
  }
}
