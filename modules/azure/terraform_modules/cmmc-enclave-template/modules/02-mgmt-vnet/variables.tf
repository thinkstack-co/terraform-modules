variable "resource_group_name" {
  description = "Name of the resource group to deploy into."
  type        = string
}

variable "location" {
  description = "Azure Government region (e.g., 'usgovarizona')."
  type        = string
}

variable "mgmt_vnet_cidr" {
  description = "Address space for the management virtual network."
  type        = string
  default     = "172.16.0.0/16"
}

variable "firewall_subnet_cidr" {
  description = "CIDR for AzureFirewallSubnet. Must be at least /26."
  type        = string
  default     = "172.16.0.0/26"
}

variable "bastion_subnet_cidr" {
  description = "CIDR for AzureBastionSubnet. Must be at least /26."
  type        = string
  default     = "172.16.0.64/26"
}

variable "ztna_subnet_cidr" {
  description = "CIDR for the ZTNA (Appgate) subnet."
  type        = string
  default     = "172.16.0.128/26"
}

variable "mgmt_avd_subnet_cidr" {
  description = "CIDR for the management AVD subnet."
  type        = string
  default     = "172.16.0.192/26"
}

variable "log_retention_days" {
  description = "Retention period in days for Log Analytics workspaces."
  type        = number
  default     = 30
}

variable "tags" {
  description = "Tags applied to all resources."
  type        = map(string)
  default     = {}
}
