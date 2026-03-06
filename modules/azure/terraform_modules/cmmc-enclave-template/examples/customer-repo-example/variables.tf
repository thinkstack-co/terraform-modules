# -------------------------------------------------------------------------
# Required — must be provided in terraform.tfvars
# -------------------------------------------------------------------------

variable "tenant_id" {
  description = "Entra ID tenant ID."
  type        = string
}

variable "subscription_id" {
  description = "Azure Government subscription ID."
  type        = string
}

variable "customer_name" {
  description = "Short customer identifier used in resource naming (e.g., 'acme')."
  type        = string
}

variable "storage_account_name" {
  description = "Globally unique name for the FSLogix storage account (max 24 lowercase alphanumeric chars)."
  type        = string
}

variable "admin_source_ips" {
  description = "List of IP addresses/CIDRs allowed to SSH to Appgate Controller and Gateway."
  type        = list(string)
}

variable "admin_upns" {
  description = "UPNs of initial Entra ID Global Admin group members."
  type        = list(string)
}

variable "vm_admin_password" {
  description = "Local administrator password for AVD session host VMs."
  type        = string
  sensitive   = true
}

# -------------------------------------------------------------------------
# Optional — sensible defaults provided
# -------------------------------------------------------------------------

variable "location" {
  description = "Primary Azure Government region."
  type        = string
  default     = "usgovarizona"
}

variable "mgmt_vnet_cidr" {
  description = "Management VNet address space."
  type        = string
  default     = "172.16.0.0/16"
}

variable "prod_vnet_cidr" {
  description = "Production VNet address space."
  type        = string
  default     = "172.17.0.0/16"
}

variable "session_host_count" {
  description = "Number of AVD session host VMs."
  type        = number
  default     = 5
}

variable "vm_size" {
  description = "AVD session host VM size."
  type        = string
  default     = "Standard_D4s_v5"
}

variable "customer_host_pool_type" {
  description = "Customer host pool type: 'Pooled' or 'Personal'."
  type        = string
  default     = "Pooled"
}

variable "customer_max_sessions" {
  description = "Max sessions per host in the customer pool."
  type        = number
  default     = 10
}

variable "fslogix_share_size_gb" {
  description = "FSLogix file share quota in GiB."
  type        = number
  default     = 512
}

variable "vm_admin_username" {
  description = "Local administrator username for AVD session host VMs."
  type        = string
  default     = "avdadmin"
}

variable "environment" {
  description = "Environment tag value."
  type        = string
  default     = "production"
}
