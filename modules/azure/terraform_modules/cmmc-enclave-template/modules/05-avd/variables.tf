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

variable "log_analytics_workspace_id" {
  description = "Resource ID of Log Analytics workspace for AVD diagnostics (from 02-mgmt-vnet)."
  type        = string
}

variable "avd_users_group_id" {
  description = "Object ID of the Entra ID group to assign Desktop Virtualization User role."
  type        = string
}

variable "customer_host_pool_type" {
  description = "Host pool type for the customer pool: 'Pooled' or 'Personal'."
  type        = string
  default     = "Pooled"

  validation {
    condition     = contains(["Pooled", "Personal"], var.customer_host_pool_type)
    error_message = "Must be 'Pooled' or 'Personal'."
  }
}

variable "customer_max_sessions" {
  description = "Max concurrent sessions per host in the customer pool (for Pooled type)."
  type        = number
  default     = 10
}

variable "customer_load_balancer_type" {
  description = "Load balancer type for the customer pool: 'BreadthFirst', 'DepthFirst', or 'Persistent' (Personal only)."
  type        = string
  default     = "BreadthFirst"
}

variable "tags" {
  description = "Tags applied to all resources."
  type        = map(string)
  default     = {}
}
