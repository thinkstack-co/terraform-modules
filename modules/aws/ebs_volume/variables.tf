variable "availability_zone" {
  type        = string
  description = "(Required) The AZ where the EBS volume will exist."
}

variable "encrypted" {
  type        = bool
  description = "(Optional) If true, the disk will be encrypted."
  default     = true
  validation {
    condition     = var.encrypted == true
    error_message = "Encryption is required for EBS volumes."
  }
}

variable "final_snapshot" {
  type        = bool
  description = "(Optional) If true, snapshot will be created before volume deletion. Any tags on the volume will be migrated to the snapshot. By default set to false"
  default     = false
  validation {
    condition     = can(regex("true|false", var.final_snapshot))
    error_message = "final_snapshot must be either true or false"
  }
}

variable "iops" {
  type        = number
  description = "(Optional) The amount of IOPS to provision for the disk. Only valid for type of io1, io2 or gp3."
  default     = null
  validation {
    # iops must be greater than 0 or null
    condition     = var.iops > 0 || var.iops == null
    error_message = "iops must be greater than 0 or null"
  }
}

variable "kms_key_id" {
  type        = string
  description = "(Optional) The ARN for the KMS encryption key. When specifying kms_key_id, encrypted needs to be set to true. Note: Terraform must be running with credentials which have the GenerateDataKeyWithoutPlaintext permission on the specified KMS key as required by the EBS KMS CMK volume provisioning process to prevent a volume from being created and almost immediately deleted."
  default     = null
  validation {
    condition     = can(regex("arn:aws:kms:.*", var.kms_key_id)) || var.kms_key_id == null
    error_message = "kms_key_id must be a valid ARN or null"
  }
}

variable "multi_attach_enabled" {
  type        = bool
  description = "(Optional) Specifies whether to enable Amazon EBS Multi-Attach. Multi-Attach is supported on io1 and io2 volumes."
  default     = false
  validation {
    condition     = can(regex("true|false", var.multi_attach_enabled))
    error_message = "multi_attach_enable must be either true or false"
  }
}

variable "size" {
  type        = number
  description = "(Optional) The size of the drive in GiBs. "
  default     = 8
  validation {
    condition     = var.size > 0
    error_message = "size must be greater than 0"
  }
}

variable "snapshot_id" {
  type        = string
  description = "(Optional) A snapshot to base the EBS volume off of."
  default     = null
  validation {
    condition     = can(regex("snap-[0-9a-f]{8}", var.snapshot_id)) || var.snapshot_id == null
    error_message = "snapshot_id must be a valid snapshot ID or null"
  }
}

variable "type" {
  type        = string
  description = "(Optional) The type of EBS volume. Can be standard, gp2, gp3, io1, io2, sc1 or st1 (Default: gp3)."
  default     = "gp3"
  validation {
    condition     = can(regex("standard|gp2|gp3|io1|io2|sc1|st1", var.type))
    error_message = "type must be either standard, gp2, gp3, io1, io2, sc1 or st1"
  }
}

variable "tags" {
  type        = map(any)
  description = "(Optional) A map of tags to assign to the resource. If configured with a provider default_tags configuration block present, tags with matching keys will overwrite those defined at the provider-level."
  default = {
    terraform = "true"
  }
}

variable "throughput" {
  type        = number
  description = "(Optional) The throughput that the volume supports, in MiB/s. Only valid for type of gp3."
  default     = null
  /* validation {
    condition     = var.throughput > 0 || var.throughput == null
    error_message = "throughput must be greater than 0"
  } */
}

variable "device_name" {
  type        = string
  description = "(Required) The device name to expose to the instance (for example, /dev/sdh or xvdh). See Device Naming on Linux Instances and Device Naming on Windows Instances for more information."
  default     = "xvdf"
}

variable "force_detach" {
  type        = bool
  description = "(Optional, Boolean) Set to true if you want to force the volume to detach. Useful if previous attempts failed, but use this option only as a last resort, as this can result in data loss. See Detaching an Amazon EBS Volume from an Instance for more information."
  default     = false
  validation {
    condition     = can(regex("true|false", var.force_detach))
    error_message = "force_detach must be either true or false"
  }
}

variable "instance_id" {
  type        = string
  description = "(Required) ID of the Instance to attach to"
  validation {
    condition     = can(regex("i-[0-9a-f]{8}", var.instance_id))
    error_message = "instance_id must be a valid instance ID"
  }
}

variable "skip_destroy" {
  type        = bool
  description = "(Optional, Boolean) Set this to true if you do not wish to detach the volume from the instance to which it is attached at destroy time, and instead just remove the attachment from Terraform state. This is useful when destroying an instance which has volumes created by some other means attached."
  default     = false
  validation {
    condition     = can(regex("true|false", var.skip_destroy))
    error_message = "skip_destroy must be either true or false"
  }
}

variable "stop_instance_before_detaching" {
  type        = bool
  description = "(Optional, Boolean) Set this to true to ensure that the target instance is stopped before trying to detach the volume. Stops the instance, if it is not already stopped."
  default     = false
  validation {
    condition     = can(regex("true|false", var.stop_instance_before_detaching))
    error_message = "stop_instance_before_detaching must be either true or false"
  }
}
