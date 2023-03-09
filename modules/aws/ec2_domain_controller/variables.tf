######################################
# EC2 Instance Variables
######################################

variable "ami" {
  type        = string
  description = "(Optional) AMI to use for the instance. Required unless launch_template is specified and the Launch Template specifes an AMI. If an AMI is specified in the Launch Template, setting ami will override the AMI specified in the Launch Template."
  validation {
    condition     = can(regex("^ami-[0-9a-f]{17}$", var.ami))
    error_message = "The value must be a valid AMI ID."
  }
}

variable "auto_recovery" {
  type        = string
  description = "(Optional) Whether the instance is protected from auto recovery by Auto Recovery from User Space (ARU) feature. Can be 'default' or 'disabled'. Defaults to default. See Auto Recovery from User Space for more information. https://docs.aws.amazon.com/AWSEC2/latest/UserGuide/instance-auto-recovery.html"
  default     = "default"
  validation {
    condition     = can(regex("default|disabled", var.auto_recovery))
    error_message = "The value must be either default or disabled."
  }
}

variable "disable_api_termination" {
  type        = bool
  description = "(Optional) If true, enables EC2 Instance Termination Protection"
  default     = false
  validation {
    condition     = can(regex("true|false", var.disable_api_termination))
    error_message = "The value must be either true or false."
  }
}

variable "ebs_optimized" {
  type        = bool
  description = "(Optional) If true, the launched EC2 instance will be EBS-optimized. Note that if this is not set on an instance type that is optimized by default then this will show as disabled but if the instance type is optimized by default then there is no need to set this and there is no effect to disabling it. See the EBS Optimized section of the AWS User Guide for more information."
  default     = false
  validation {
    condition     = can(regex("true|false", var.ebs_optimized))
    error_message = "The value must be either true or false."
  }
}

variable "encrypted" {
  type        = bool
  description = "(Optional) Enable volume encryption. (Default: true). Must be configured to perform drift detection."
  default     = true
  validation {
    condition     = can(regex("true|false", var.encrypted))
    error_message = "The value must be either true or false."
  }
}

variable "iam_instance_profile" {
  type        = string
  description = "(Optional) IAM Instance Profile to launch the instance with. Specified as the name of the Instance Profile. Ensure your credentials have the correct permission to assign the instance profile according to the EC2 documentation, notably iam:PassRole."
  default     = null
}

variable "instance_initiated_shutdown_behavior" {
  type        = string
  description = "(Optional) Shutdown behavior for the instance. Amazon defaults this to stop for EBS-backed instances and terminate for instance-store instances. Cannot be set on instance-store instances. See Shutdown Behavior for more information. https://docs.aws.amazon.com/AWSEC2/latest/UserGuide/terminating-instances.html#Using_ChangingInstanceInitiatedShutdownBehavior"
  default     = "stop"
  validation {
    condition     = can(regex("stop|terminate", var.instance_initiated_shutdown_behavior))
    error_message = "The value must be either stop or terminate."
  }
}

variable "instance_type" {
  type        = string
  description = "(Optional) Instance type to use for the instance. Required unless launch_template is specified and the Launch Template specifies an instance type. If an instance type is specified in the Launch Template, setting instance_type will override the instance type specified in the Launch Template. Updates to this field will trigger a stop/start of the EC2 instance."
  default     = "t3a.medium"
}

variable "key_name" {
  type        = string
  description = "(Optional) Key name of the Key Pair to use for the instance; which can be managed using the aws_key_pair resource."
  default     = null
  validation {
    condition     = can(regex("^([a-zA-Z0-9-_]+)$", var.key_name)) || var.key_name == null
    error_message = "The value must be a valid key name or null."
  }
}

variable "kms_key_id" {
  type        = string
  description = "(Optional) Amazon Resource Name (ARN) of the KMS Key to use when encrypting the volume. Must be configured to perform drift detection."
  default     = null
  validation {
    condition     = can(regex("^arn:aws:kms:[a-z]{2}-[a-z]{4,9}-[1-3]{1}:[0-9]{12}:key/[a-z0-9-]{36}$", var.kms_key_id)) || var.kms_key_id == null
    error_message = "The value must be a valid KMS Key ID or null."
  }
}

variable "monitoring" {
  type        = bool
  description = "(Optional) If true, the launched EC2 instance will have detailed monitoring enabled. (Available since v0.6.0)"
  default     = true
  validation {
    condition     = can(regex("true|false", var.monitoring))
    error_message = "The value must be either true or false."
  }
}

variable "placement_group" {
  type        = string
  description = "(Optional) Placement Group to start the instance in."
  default     = null
  validation {
    condition     = can(regex("^([a-zA-Z0-9-_]+)$", var.placement_group)) || var.placement_group == null
    error_message = "The value must be a valid placement group or null."
  }
}

variable "private_ip" {
  type        = list(string)
  description = "(Required) Private IP address(es) to associate with the instance(s) in a VPC."
}

variable "http_endpoint" {
  type        = string
  description = "(Optional) Whether the metadata service is available. Valid values include enabled or disabled. Defaults to enabled."
  default     = "enabled"
  validation {
    condition     = can(regex("^(enabled|disabled)$", var.http_endpoint))
    error_message = "The value must be either enabled or disabled."
  }
}

variable "http_tokens" {
  type        = string
  description = "(Optional) Whether or not the metadata service requires session tokens, also referred to as Instance Metadata Service Version 2 (IMDSv2). Valid values include optional or required. Defaults to optional."
  default     = "required"
  validation {
    condition     = can(regex("^(optional|required)$", var.http_tokens))
    error_message = "The value must be either optional or required."
  }
}

variable "root_delete_on_termination" {
  type        = string
  description = "(Optional) Whether the volume should be destroyed on instance termination. Defaults to true."
  default     = true
  validation {
    condition     = can(regex("true|false", var.root_delete_on_termination))
    error_message = "The value must be either true or false."
  }
}

variable "root_iops" {
  type        = number
  description = "(Optional) Amount of provisioned IOPS. Only valid for volume_type of io1, io2 or gp3."
  default     = null
}

variable "root_volume_size" {
  type        = number
  description = "(Optional) The size of the volume in gigabytes."
  default     = 100
  validation {
    condition     = can(regex("^[0-9]+$", var.root_volume_size))
    error_message = "The value must be a valid number."
  }
}

variable "root_volume_type" {
  type        = string
  description = "(Optional) The type of volume. Can be standard, gp2, gp3 or io1. (Default: standard)"
  default     = "gp3"
}

variable "source_dest_check" {
  type        = bool
  description = "(Optional) Controls if traffic is routed to the instance when the destination address does not match the instance. Used for NAT or VPNs. Defaults true."
  default     = true
  validation {
    condition     = can(regex("true|false", var.source_dest_check))
    error_message = "The value must be either true or false."
  }
}

variable "subnet_id" {
  type        = list(string)
  description = "(Required) The VPC subnet(s) the instance(s) will be assigned and launched in."
}

variable "tenancy" {
  type        = string
  description = "(Optional) Tenancy of the instance (if the instance is running in a VPC). An instance with a tenancy of dedicated runs on single-tenant hardware. The host tenancy is not supported for the import-instance command. Valid values are default, dedicated, and host."
  default     = "default"
  validation {
    condition     = can(regex("^(default|dedicated|host)$", var.tenancy))
    error_message = "The value must be either default, dedicated or host."
  }
}

variable "tags" {
  type        = map(string)
  description = "(Optional) Map of tags to assign to the resource. Note that these tags apply to the instance and not block storage devices. If configured with a provider default_tags configuration block present, tags with matching keys will overwrite those defined at the provider-level."
  default = {
    terraform = "true"
  }
}

variable "user_data" {
  type        = string
  description = "(Optional) User data to provide when launching the instance. Do not pass gzip-compressed data via this argument; see user_data_base64 instead. Updates to this field will trigger a stop/start of the EC2 instance by default. If the user_data_replace_on_change is set then updates to this field will trigger a destroy and recreate."
  default     = null
  validation {
    condition     = can(regex("^([a-zA-Z0-9-_]+)$", var.user_data)) || var.user_data == null
    error_message = "The value must be a valid user data or null."
  }
}

variable "vpc_security_group_ids" {
  type        = list(any)
  description = "(Required, VPC only) List of security group IDs to associate with."
  /*   validation {
    condition     = can(regex("^sg-[a-z0-9]+$", var.vpc_security_group_ids))
    error_message = "The value must be a valid security group ID."
  } */
}

######################################
# DHCP Options Variables
######################################

variable "domain_name" {
  type        = string
  description = "(Required) the suffix domain name to use by default when resolving non Fully Qualified Domain Names. In other words, this is what ends up being the search value in the /etc/resolv.conf file."
}

variable "vpc_id" {
  type        = string
  description = "(Required) The ID of the VPC to which we would like to associate a DHCP Options Set."
  validation {
    condition     = can(regex("^vpc-[a-z0-9]+$", var.vpc_id))
    error_message = "The value must be a valid VPC ID."
  }
}

######################################
# General Variables
######################################

variable "enable_dhcp_options" {
  description = "(Optional) boolean to determine if DHCP options are enabled"
  type        = bool
  default     = true
  validation {
    condition     = can(regex("true|false", var.enable_dhcp_options))
    error_message = "The value must be either true or false."
  }
}

variable "name" {
  type        = string
  description = "Name of the instance. Used in tags for resources."
  validation {
    condition     = can(regex("^([a-zA-Z0-9-_]+)$", var.name))
    error_message = "The value must be a valid name."
  }
}

variable "number" {
  type        = number
  description = "(Optional) The number of instances and supporting resources to create. This allows high availability configurations. Default is 2."
  default     = 2
  validation {
    condition     = var.number >= 1
    error_message = "The value must be greater than or equal to 1."
  }
}
