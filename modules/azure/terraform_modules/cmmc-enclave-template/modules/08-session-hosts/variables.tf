variable "resource_group_name" {
  description = "Name of the resource group to deploy into."
  type        = string
}

variable "location" {
  description = "Azure Government region."
  type        = string
}

variable "customer_name" {
  description = "Short customer name used in VM naming."
  type        = string
}

variable "host_count" {
  description = "Number of session host VMs to create."
  type        = number
  default     = 5
}

variable "vm_size" {
  description = "Azure VM size for session hosts."
  type        = string
  default     = "Standard_D4s_v5"
}

variable "subnet_id" {
  description = "Resource ID of the subnet for session host NICs (Mgmt-AVD subnet from 02-mgmt-vnet)."
  type        = string
}

variable "gallery_image_id" {
  description = "Resource ID of the Azure Compute Gallery image definition to use."
  type        = string
}

variable "image_version" {
  description = "Image version to use from the gallery. Defaults to 'latest'."
  type        = string
  default     = "latest"
}

variable "host_pool_id" {
  description = "Resource ID of the AVD host pool to register VMs to."
  type        = string
}

variable "registration_token" {
  description = "AVD host pool registration token (from 05-avd, valid for 2 hours)."
  type        = string
  sensitive   = true
}

variable "fslogix_storage_account" {
  description = "Name of the FSLogix storage account (from 06-storage)."
  type        = string
}

variable "fslogix_storage_key" {
  description = "Primary access key of the FSLogix storage account (from 06-storage)."
  type        = string
  sensitive   = true
}

variable "fslogix_share_name" {
  description = "Name of the FSLogix file share."
  type        = string
  default     = "fslogixprofiles"
}

variable "admin_username" {
  description = "Local administrator username for session host VMs."
  type        = string
  default     = "avdadmin"
}

variable "admin_password" {
  description = "Local administrator password for session host VMs."
  type        = string
  sensitive   = true
}

variable "os_disk_type" {
  description = "Storage type for OS disk."
  type        = string
  default     = "Premium_LRS"

  validation {
    condition     = contains(["Premium_LRS", "StandardSSD_LRS", "Standard_LRS"], var.os_disk_type)
    error_message = "Must be Premium_LRS, StandardSSD_LRS, or Standard_LRS."
  }
}

variable "tags" {
  description = "Tags applied to all resources."
  type        = map(string)
  default     = {}
}
