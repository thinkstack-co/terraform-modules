###########################
# Required
###########################

# Public IP name
variable "name" {
  description = "(Required) Name of the Public IP resource."
  type        = string
}

# Resource group name
variable "resource_group_name" {
  description = "(Required) The name of an existing resource group in which to create the Public IP."
  type        = string
}

# Azure region
variable "location" {
  description = "(Required) The Azure region where resources will be created."
  type        = string
  default     = "eastus"
}

###########################
# Optional
###########################

# Public IP SKU
variable "sku" {
  description = "(Optional) The SKU of the Public IP. Valid values are Basic or Standard."
  type        = string
  default     = "Standard"

  validation {
    condition     = contains(["Basic", "Standard"], var.sku)
    error_message = "sku must be one of: Basic, Standard."
  }
}

# Public IP allocation method
variable "allocation_method" {
  description = "(Optional) Defines the allocation method for the Public IP address. Valid values are Static or Dynamic. Note: Standard SKU requires Static."
  type        = string
  default     = "Static"

  validation {
    condition     = contains(["Static", "Dynamic"], var.allocation_method)
    error_message = "allocation_method must be one of: Static, Dynamic."
  }
}

# Optional DNS label
variable "domain_name_label" {
  description = "(Optional) Label for a DNS name. If set, Azure will create an FQDN under *.cloudapp.azure.com."
  type        = string
  default     = null
}

# IP version
variable "ip_version" {
  description = "(Optional) The IP version to use. Valid values are IPv4 or IPv6."
  type        = string
  default     = "IPv4"

  validation {
    condition     = contains(["IPv4", "IPv6"], var.ip_version)
    error_message = "ip_version must be one of: IPv4, IPv6."
  }
}

# Availability zones
variable "zones" {
  description = "(Optional) A list of availability zones for the Public IP. For zonal Standard public IPs, set one zone (e.g. [\"1\"]). Empty means regional."
  type        = list(string)
  default     = []
}

# Resource tags
variable "tags" {
  type        = map(string)
  description = "(Optional) A mapping of tags to assign to the resource."
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

# Enforce standard SKU with static allocation
variable "_validate_standard_static" {
  description = "(Internal) Enforces that Standard Public IPs use Static allocation."
  type        = bool
  default     = true

  validation {
    condition     = !(var.sku == "Standard" && var.allocation_method != "Static")
    error_message = "When sku is Standard, allocation_method must be Static."
  }
}
