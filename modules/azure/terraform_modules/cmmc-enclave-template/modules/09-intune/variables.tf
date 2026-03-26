variable "tenant_id" {
  description = "Entra ID tenant ID."
  type        = string
}

variable "target_group_ids" {
  description = "List of Entra ID group object IDs to assign Intune policies to."
  type        = list(string)
}

variable "bitlocker_encryption_method" {
  description = "BitLocker encryption method for OS drive. xtsAes128 or xtsAes256."
  type        = string
  default     = "xtsAes128"

  validation {
    condition     = contains(["xtsAes128", "xtsAes256"], var.bitlocker_encryption_method)
    error_message = "Must be 'xtsAes128' or 'xtsAes256'."
  }
}

variable "compliance_grace_period_hours" {
  description = "Grace period in hours before non-compliant devices are marked non-compliant."
  type        = number
  default     = 0
}

variable "customer_name" {
  description = "Customer name used in the interactive logon banner text and title."
  type        = string
}

variable "avd_host_group_id" {
  description = "Object ID of the All Azure Virtual Desktop Hosts group for AVD-targeted policies."
  type        = string
}

variable "all_users_group_id" {
  description = "Object ID of the All Users group for user-targeted policies."
  type        = string
}

variable "all_windows_devices_group_id" {
  description = "Object ID of the All Windows 10 and Later Devices group for device-targeted policies."
  type        = string
}

variable "gpu_vm_group_id" {
  description = "Object ID of the GPU-optimized Azure VMs group. If null, the GPU acceleration policy is skipped."
  type        = string
  default     = null
}

variable "tags" {
  description = "Tags applied to all resources (not supported by microsoft365 provider; reserved for future use)."
  type        = map(string)
  default     = {}
}
