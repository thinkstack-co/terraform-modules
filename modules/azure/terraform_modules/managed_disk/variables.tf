# Required variables

variable "name" {
  type        = string
  description = "(Required) The name of the managed disk. Changing this forces a new resource to be created."
}

variable "location" {
  type        = string
  description = "(Required) The Azure location where the managed disk should exist. Changing this forces a new resource to be created."
}

variable "resource_group_name" {
  type        = string
  description = "(Required) The name of the resource group in which to create the managed disk. Changing this forces a new resource to be created."
}

variable "storage_account_type" {
  type        = string
  description = "(Required) The type of storage to use for the managed disk. Possible values are Standard_LRS, StandardSSD_ZRS, Premium_LRS, PremiumV2_LRS, Premium_ZRS, StandardSSD_LRS or UltraSSD_LRS."
  default     = "StandardSSD_LRS"
  validation {
    condition     = contains(["Standard_LRS", "StandardSSD_ZRS", "Premium_LRS", "PremiumV2_LRS", "Premium_ZRS", "StandardSSD_LRS", "UltraSSD_LRS"], var.storage_account_type)
    error_message = "storage_account_type must be one of: Standard_LRS, StandardSSD_ZRS, Premium_LRS, PremiumV2_LRS, Premium_ZRS, StandardSSD_LRS, or UltraSSD_LRS."
  }
}

variable "create_option" {
  type        = string
  description = "(Required) The method to use when creating the managed disk. Possible values include: Import, ImportSecure, Empty, Copy, FromImage, Restore, Upload, UploadSecure."
  default     = "Empty"
  validation {
    condition     = contains(["Import", "ImportSecure", "Empty", "Copy", "FromImage", "Restore", "Upload", "UploadSecure"], var.create_option)
    error_message = "create_option must be one of: Import, ImportSecure, Empty, Copy, FromImage, Restore, Upload, or UploadSecure."
  }
}

variable "disk_size_gb" {
  type        = number
  description = "(Optional) Specifies the size of the managed disk to create in gigabytes. Required when create_option is Empty or Copy."
  default     = 128
  validation {
    condition     = var.disk_size_gb > 0
    error_message = "disk_size_gb must be greater than 0."
  }
}

# Optional variables

variable "zone" {
  type        = string
  description = "(Optional) Specifies the Availability Zone in which this Managed Disk should be located. Changing this forces a new resource to be created."
  default     = null
  validation {
    condition     = var.zone == null ? true : contains(["1", "2", "3"], var.zone)
    error_message = "zone must be 1, 2, or 3 when specified."
  }
}

variable "disk_iops_read_write" {
  type        = number
  description = "(Optional) The number of IOPS allowed for this disk. Only settable for UltraSSD and PremiumV2_LRS disks."
  default     = null
  validation {
    condition     = var.disk_iops_read_write == null ? true : var.disk_iops_read_write > 0
    error_message = "disk_iops_read_write must be greater than 0 when specified."
  }
}

variable "disk_mbps_read_write" {
  type        = number
  description = "(Optional) The bandwidth allowed for this disk in MB/s. Only settable for UltraSSD and PremiumV2_LRS disks."
  default     = null
  validation {
    condition     = var.disk_mbps_read_write == null ? true : var.disk_mbps_read_write > 0
    error_message = "disk_mbps_read_write must be greater than 0 when specified."
  }
}

variable "disk_iops_read_only" {
  type        = number
  description = "(Optional) The number of IOPS allowed across all VMs mounting the shared disk as read-only. Only settable for UltraSSD disks with shared disk enabled."
  default     = null
}

variable "disk_mbps_read_only" {
  type        = number
  description = "(Optional) The bandwidth allowed across all VMs mounting the shared disk as read-only in MB/s. Only settable for UltraSSD disks with shared disk enabled."
  default     = null
}

variable "source_resource_id" {
  type        = string
  description = "(Optional) The ID of an existing Managed Disk or Snapshot to copy when create_option is Copy or the ID of the Recovery Point to restore when create_option is Restore."
  default     = null
}

variable "source_uri" {
  type        = string
  description = "(Optional) URI to a valid VHD file to be used when create_option is Import or ImportSecure."
  default     = null
}

variable "storage_account_id" {
  type        = string
  description = "(Optional) The ID of the Storage Account where the source_uri is located. Required when create_option is Import or ImportSecure."
  default     = null
}

variable "image_reference_id" {
  type        = string
  description = "(Optional) ID of an existing platform/marketplace disk image to copy when create_option is FromImage."
  default     = null
}

variable "gallery_image_reference_id" {
  type        = string
  description = "(Optional) ID of a Gallery Image Version to copy when create_option is FromImage."
  default     = null
}

variable "disk_encryption_set_id" {
  type        = string
  description = "(Optional) The ID of a Disk Encryption Set which should be used to encrypt this Managed Disk."
  default     = null
}

variable "disk_access_id" {
  type        = string
  description = "(Optional) The ID of the disk access resource for using private endpoints on disks."
  default     = null
}

variable "public_network_access_enabled" {
  type        = bool
  description = "(Optional) Whether public network access is allowed for this Managed Disk. Defaults to true."
  default     = true
}

variable "network_access_policy" {
  type        = string
  description = "(Optional) Policy for accessing the disk via network. Possible values are AllowAll, AllowPrivate, and DenyAll."
  default     = null
  validation {
    condition     = var.network_access_policy == null ? true : contains(["AllowAll", "AllowPrivate", "DenyAll"], var.network_access_policy)
    error_message = "network_access_policy must be one of: AllowAll, AllowPrivate, or DenyAll."
  }
}

variable "tier" {
  type        = string
  description = "(Optional) The disk performance tier to use. Only available for disks with Premium_LRS storage account type."
  default     = null
}

variable "max_shares" {
  type        = number
  description = "(Optional) The maximum number of VMs that can attach to the disk at the same time. Value greater than one enables shared disk (multi-attach)."
  default     = null
  validation {
    condition     = var.max_shares == null ? true : var.max_shares > 0
    error_message = "max_shares must be greater than 0 when specified."
  }
}

variable "trusted_launch_enabled" {
  type        = bool
  description = "(Optional) Specifies if Trusted Launch is enabled for the Managed Disk."
  default     = null
}

variable "os_type" {
  type        = string
  description = "(Optional) Specify a value when the source of an Import, ImportSecure or Copy operation targets a source that contains an operating system. Valid values are Linux or Windows."
  default     = null
  validation {
    condition     = var.os_type == null ? true : contains(["Linux", "Windows"], var.os_type)
    error_message = "os_type must be either Linux or Windows when specified."
  }
}

variable "hyper_v_generation" {
  type        = string
  description = "(Optional) The HyperV Generation of the Disk when the source of an Import or Copy operation targets a source that contains an operating system. Possible values are V1 and V2."
  default     = null
  validation {
    condition     = var.hyper_v_generation == null ? true : contains(["V1", "V2"], var.hyper_v_generation)
    error_message = "hyper_v_generation must be either V1 or V2 when specified."
  }
}

variable "on_demand_bursting_enabled" {
  type        = bool
  description = "(Optional) Specifies if On-Demand Bursting is enabled for the Managed Disk."
  default     = null
}

variable "upload_size_bytes" {
  type        = number
  description = "(Optional) Specifies the size of the managed disk to create in bytes. Required when create_option is Upload or UploadSecure."
  default     = null
}

variable "edge_zone" {
  type        = string
  description = "(Optional) Specifies the Edge Zone within the Azure Region where this Managed Disk should exist."
  default     = null
}

variable "logical_sector_size" {
  type        = number
  description = "(Optional) Logical Sector Size. Possible values are 512 and 4096. Only supported for UltraSSD_LRS disks."
  default     = null
  validation {
    condition     = var.logical_sector_size == null ? true : contains([512, 4096], var.logical_sector_size)
    error_message = "logical_sector_size must be either 512 or 4096 when specified."
  }
}

variable "optimized_frequent_attach_enabled" {
  type        = bool
  description = "(Optional) Specifies whether this Managed Disk should be optimized for frequent disk attachments."
  default     = null
}

variable "performance_plus_enabled" {
  type        = bool
  description = "(Optional) Specifies whether Performance Plus is enabled for this Managed Disk."
  default     = null
}

variable "encryption_settings" {
  type = object({
    disk_encryption_key = optional(object({
      secret_url      = string
      source_vault_id = string
    }))
    key_encryption_key = optional(object({
      key_url         = string
      source_vault_id = string
    }))
  })
  description = "(Optional) A block for disk encryption settings using Azure Disk Encryption."
  default     = null
}

variable "tags" {
  type        = map(any)
  description = "(Optional) A mapping of tags to assign to the resource."
  default = {
    terraform = "true"
  }
}

# Disk attachment variables

variable "virtual_machine_id" {
  type        = string
  description = "(Optional) The ID of the Virtual Machine to which the Data Disk should be attached. If null, the disk will not be attached."
  default     = null
}

variable "lun" {
  type        = number
  description = "(Required when attaching) The Logical Unit Number of the Data Disk, which needs to be unique within the Virtual Machine. Range is 0-63."
  default     = 0
  validation {
    condition     = var.lun >= 0 && var.lun <= 63
    error_message = "lun must be between 0 and 63."
  }
}

variable "caching" {
  type        = string
  description = "(Optional) Specifies the caching requirements for this Data Disk. Possible values include None, ReadOnly and ReadWrite."
  default     = "ReadWrite"
  validation {
    condition     = contains(["None", "ReadOnly", "ReadWrite"], var.caching)
    error_message = "caching must be one of: None, ReadOnly, or ReadWrite."
  }
}

variable "attachment_create_option" {
  type        = string
  description = "(Optional) The Create Option of the Data Disk, such as Empty or Attach. Defaults to Attach."
  default     = "Attach"
  validation {
    condition     = contains(["Empty", "Attach"], var.attachment_create_option)
    error_message = "attachment_create_option must be either Empty or Attach."
  }
}

variable "write_accelerator_enabled" {
  type        = bool
  description = "(Optional) Specifies if Write Accelerator is enabled on the disk. This can only be enabled on Premium_LRS managed disks with no caching and M-Series VMs."
  default     = false
}
