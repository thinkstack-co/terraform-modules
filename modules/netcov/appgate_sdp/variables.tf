######################################
# Required Variables
######################################

variable "name" {
  type        = string
  description = "(Required) Name applied to the AppGate gateway instance, EIP, and alarms, e.g. aws-prod-aggw01."
}

variable "instance_type" {
  type        = string
  description = "(Required) EC2 instance type for the AppGate gateway, e.g. t3a.medium."
}

variable "subnet_id" {
  type        = string
  description = "(Required) ID of the subnet in which to launch the AppGate gateway. Use a public subnet when associate_public_ip_address is true."
}

variable "vpc_security_group_ids" {
  type        = list(any)
  description = "(Required) List of security group IDs to associate with the AppGate gateway instance."
}

######################################
# Feature Flags
######################################

variable "create_eip" {
  type        = bool
  description = "(Optional) Whether to allocate and associate an Elastic IP with the gateway. Default true."
  default     = true
  validation {
    condition     = can(regex("^(true|false)$", var.create_eip))
    error_message = "The value must be either true or false."
  }
}

variable "associate_public_ip_address" {
  type        = bool
  description = "(Optional) Whether to assign a public IP at launch so the gateway is public-facing in a public subnet. When true, private_ip must be provided. Default true."
  default     = true
  validation {
    condition     = can(regex("^(true|false)$", var.associate_public_ip_address))
    error_message = "The value must be either true or false."
  }
}

variable "create_cloudwatch_alarms" {
  type        = bool
  description = "(Optional) Whether to create CloudWatch status-check alarms for the instance. Default true."
  default     = true
  validation {
    condition     = can(regex("^(true|false)$", var.create_cloudwatch_alarms))
    error_message = "The value must be either true or false."
  }
}

######################################
# AMI Selection
######################################

variable "ami_name_filter" {
  type        = string
  description = "(Optional) Name filter used to select the AppGate SDP marketplace AMI. Defaults to AppGate SDP 6.5.6 BYOL."
  default     = "Appgate-SDP-6.5.6-BYOL*"
}

variable "ami_architecture" {
  type        = string
  description = "(Optional) CPU architecture of the AppGate SDP AMI."
  default     = "x86_64"
}

variable "ami_virtualization_type" {
  type        = string
  description = "(Optional) Virtualization type of the AppGate SDP AMI."
  default     = "hvm"
}

######################################
# Instance Configuration
######################################

variable "availability_zone" {
  type        = string
  description = "(Optional) Availability zone in which to launch the gateway. Defaults to provider/subnet selection."
  default     = ""
}

variable "private_ip" {
  type        = string
  description = "(Optional) Static private IP to assign to the gateway within its subnet. Required when associate_public_ip_address is true, and must be an address within one of the public subnets."
  default     = null
}

variable "key_name" {
  type        = string
  description = "(Optional) Name of the EC2 key pair to associate with the instance."
  default     = ""
}

variable "iam_instance_profile" {
  type        = string
  description = "(Optional) IAM instance profile to attach. Defaults to the SSM quick-setup profile used for AppGate management."
  default     = "AmazonSSMRoleForInstancesQuickSetup"
}

variable "ebs_optimized" {
  type        = bool
  description = "(Optional) Whether the instance is EBS-optimized."
  default     = true
  validation {
    condition     = can(regex("^(true|false)$", var.ebs_optimized))
    error_message = "The value must be either true or false."
  }
}

variable "disable_api_termination" {
  type        = bool
  description = "(Optional) If true, enables EC2 instance termination protection."
  default     = false
  validation {
    condition     = can(regex("^(true|false)$", var.disable_api_termination))
    error_message = "The value must be either true or false."
  }
}

variable "instance_initiated_shutdown_behavior" {
  type        = string
  description = "(Optional) Shutdown behavior for the instance. stop or terminate."
  default     = "stop"
  validation {
    condition     = can(regex("stop|terminate", var.instance_initiated_shutdown_behavior))
    error_message = "The value must be either stop or terminate."
  }
}

variable "enable_detailed_monitoring" {
  type        = bool
  description = "(Optional) Enables detailed (1-min) monitoring. When false, basic (5-min, free) monitoring is used."
  default     = false
}

variable "enable_recover_action" {
  type        = bool
  description = "(Optional) Whether to attach the EC2 recover action to the system status-check alarm. Null (default) auto-detects from the instance type."
  default     = null
}

variable "ipv6_addresses" {
  type        = list(string)
  description = "(Optional) One or more IPv6 addresses from the subnet range to associate with the primary network interface."
  default     = []
}

variable "placement_group" {
  type        = string
  description = "(Optional) The placement group to start the instance in."
  default     = ""
}

variable "source_dest_check" {
  type        = bool
  description = "(Optional) Controls if traffic is routed to the instance when the destination address does not match the instance."
  default     = true
  validation {
    condition     = can(regex("^(true|false)$", var.source_dest_check))
    error_message = "The value must be either true or false."
  }
}

variable "tenancy" {
  type        = string
  description = "(Optional) Tenancy of the instance: default, dedicated, or host."
  default     = "default"
  validation {
    condition     = can(regex("^(default|dedicated|host)$", var.tenancy))
    error_message = "The value must be either default, dedicated or host."
  }
}

variable "user_data" {
  type        = string
  description = "(Optional) User data to provide when launching the instance."
  default     = ""
}

variable "user_data_base64" {
  type        = string
  description = "(Optional) Base64-encoded user data to provide when launching the instance."
  default     = ""
}

variable "http_endpoint" {
  type        = string
  description = "(Optional) Whether the instance metadata service is available. enabled or disabled."
  default     = "enabled"
  validation {
    condition     = can(regex("^(enabled|disabled)$", var.http_endpoint))
    error_message = "The value must be either enabled or disabled."
  }
}

variable "http_tokens" {
  type        = string
  description = "(Optional) Whether the metadata service requires session tokens (IMDSv2). optional or required."
  default     = "required"
  validation {
    condition     = can(regex("^(optional|required)$", var.http_tokens))
    error_message = "The value must be either optional or required."
  }
}

######################################
# Root Volume
######################################

variable "encrypted" {
  type        = bool
  description = "(Optional) Whether the root volume is encrypted."
  default     = true
  validation {
    condition     = can(regex("^(true|false)$", var.encrypted))
    error_message = "The value must be either true or false."
  }
}

variable "root_delete_on_termination" {
  type        = bool
  description = "(Optional) Whether the root volume is destroyed on instance termination."
  default     = true
  validation {
    condition     = can(regex("^(true|false)$", var.root_delete_on_termination))
    error_message = "The value must be either true or false."
  }
}

variable "root_volume_size" {
  type        = string
  description = "(Optional) Size in GiB of the root EBS volume."
  default     = "100"
}

variable "root_volume_type" {
  type        = string
  description = "(Optional) Type of root volume: standard, gp2, gp3, io1, io2, sc1, or st1."
  default     = "gp3"
  validation {
    condition     = can(regex("^(standard|gp2|gp3|io1|io2|sc1|st1)$", var.root_volume_type))
    error_message = "The value must be either standard, gp2, gp3, io1, io2, sc1, or st1."
  }
}

variable "root_volume_iops" {
  type        = number
  description = "(Optional) IOPS for the root volume."
  default     = 3000
}

variable "root_volume_throughput" {
  type        = number
  description = "(Optional) Throughput for the root volume."
  default     = 125
}

variable "exclude_root_volume_snapshot" {
  type        = bool
  description = "(Optional) When true, excludes selected tag keys from the root EBS volume tags to keep it from being picked up separately by tag-based backup workflows."
  default     = false
}

variable "root_volume_excluded_tag_keys" {
  type        = list(string)
  description = "(Optional) Tag keys to remove from root EBS volume tags when exclude_root_volume_snapshot is true."
  default     = []
}

######################################
# Elastic IP
######################################

variable "eip_associate_with_private_ip" {
  type        = string
  description = "(Optional) Private IP to associate the EIP with. Defaults to the instance's primary private IP."
  default     = ""
}

######################################
# Tags
######################################

variable "tags" {
  type        = map(string)
  description = "(Optional) Tags applied to the gateway instance, root volume, and EIP."
  default = {
    terraform   = "true"
    created_by  = "Terraform"
    environment = "prod"
    role        = "appgate_server"
  }
}
