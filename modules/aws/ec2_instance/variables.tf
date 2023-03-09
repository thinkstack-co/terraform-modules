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

variable "associate_public_ip_address" {
  type        = bool
  description = "If true, the EC2 instance will have associated public IP address"
  default     = false
  validation {
    condition     = can(regex("^(true|false)$", var.associate_public_ip_address))
    error_message = "The value must be either true or false."
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

variable "availability_zone" {
  type        = string
  description = "The AZ to start the instance in"
  default     = ""
}

variable "number" {
  type        = number
  description = "Number of instances to launch"
  default     = 1
}

variable "disable_api_termination" {
  type        = bool
  description = "If true, enables EC2 Instance Termination Protection"
  default     = false
  validation {
    condition     = can(regex("^(true|false)$", var.disable_api_termination))
    error_message = "The value must be either true or false."
  }
}

variable "ebs_optimized" {
  type        = bool
  description = "If true, the launched EC2 instance will be EBS-optimized"
  default     = false
  validation {
    condition     = can(regex("^(true|false)$", var.ebs_optimized))
    error_message = "The value must be either true or false."
  }
}

variable "encrypted" {
  type        = bool
  description = "(Optional) Enable volume encryption. (Default: false). Must be configured to perform drift detection."
  default     = true
  validation {
    condition     = can(regex("^(true|false)$", var.encrypted))
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
  description = "The AWS instance type to utilize for the specifications of the instance"
}

variable "ipv6_addresses" {
  type        = list(string)
  description = "Specify one or more IPv6 addresses from the range of the subnet to associate with the primary network interface"
  default     = []
}

variable "key_name" {
  type        = string
  description = "The key name to use for the instance"
  default     = ""
}

variable "monitoring" {
  type        = bool
  description = "If true, the launched EC2 instance will have detailed monitoring enabled"
  default     = false
}

variable "name" {
  type        = string
  description = "Name to be used on all resources as prefix"
}

variable "placement_group" {
  type        = string
  description = "The Placement Group to start the instance in"
  default     = ""
}

variable "private_ip" {
  type        = string
  description = "Private IP address to associate with the instance in a VPC"
  default     = null
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
  type        = bool
  description = "(Optional) Whether the volume should be destroyed on instance termination (Default: true)"
  default     = true
  validation {
    condition     = can(regex("^(true|false)$", var.root_delete_on_termination))
    error_message = "The value must be either true or false."
  }
}

variable "root_volume_size" {
  type        = string
  description = "(Optional) The size of the volume in gigabytes."
  default     = "100"
}

variable "root_volume_type" {
  type        = string
  description = "(Optional) Type of volume. Valid values include standard, gp2, gp3, io1, io2, sc1, or st1. Defaults to gp3."
  default     = "gp3"
  validation {
    condition     = can(regex("^(standard|gp2|gp3|io1|io2|sc1|st1)$", var.root_volume_type))
    error_message = "The value must be either standard, gp2, gp3, io1, io2, sc1, or st1."
  }
}

/* variable "root_iops" {
  type        = number
  description = "(Optional) The amount of provisioned IOPS. This is only valid for volume_type of io1, and must be specified if using that type"
  default     = null
} */

variable "source_dest_check" {
  type        = bool
  description = "Controls if traffic is routed to the instance when the destination address does not match the instance. Used for NAT or VPNs."
  default     = true
  validation {
    condition     = can(regex("^(true|false)$", var.source_dest_check))
    error_message = "The value must be either true or false."
  }
}

variable "subnet_id" {
  type        = string
  description = "The VPC Subnet ID to launch in"
  default     = ""
}

variable "tags" {
  type        = map(string)
  description = "A mapping of tags to assign to the resource"
  default     = {}
}

variable "tenancy" {
  type        = string
  description = "The tenancy of the instance (if the instance is running in a VPC). Available values: default, dedicated, host."
  default     = "default"
  validation {
    condition     = can(regex("^(default|dedicated|host)$", var.tenancy))
    error_message = "The value must be either default, dedicated or host."
  }
}

variable "user_data" {
  type        = string
  description = "The user data to provide when launching the instance"
  default     = ""
}

variable "vpc_security_group_ids" {
  description = "A list of security group IDs to associate with"
  type        = list(any)
}
