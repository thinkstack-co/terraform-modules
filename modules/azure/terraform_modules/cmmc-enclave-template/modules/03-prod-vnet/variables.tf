variable "resource_group_name" {
  description = "Name of the resource group to deploy into."
  type        = string
}

variable "location" {
  description = "Azure Government region."
  type        = string
}

variable "customer_name" {
  description = "Short customer name used in resource naming."
  type        = string
}

variable "prod_vnet_cidr" {
  description = "Address space for the production virtual network."
  type        = string
  default     = "172.17.0.0/16"
}

variable "subnet_count" {
  description = "Number of customer subnets to create (uses /24 slices of prod_vnet_cidr)."
  type        = number
  default     = 2
}

variable "mgmt_vnet_id" {
  description = "Resource ID of the management virtual network (for peering)."
  type        = string
}

variable "mgmt_vnet_name" {
  description = "Name of the management virtual network (for peering)."
  type        = string
}

variable "mgmt_resource_group_name" {
  description = "Resource group containing the management virtual network."
  type        = string
}

variable "firewall_private_ip" {
  description = "Private IP of the management Azure Firewall (for route table)."
  type        = string
}

variable "log_retention_days" {
  description = "Retention period in days for Log Analytics workspace."
  type        = number
  default     = 30
}

variable "tags" {
  description = "Tags applied to all resources."
  type        = map(string)
  default     = {}
}
