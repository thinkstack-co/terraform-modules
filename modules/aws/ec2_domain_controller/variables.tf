variable "ami" {
  type        = string
  description = "(Optional) AMI to use for the instance. Required unless launch_template is specified and the Launch Template specifes an AMI. If an AMI is specified in the Launch Template, setting ami will override the AMI specified in the Launch Template."
}

variable "availability_zone" {
  type        = string
  description = "(Optional) AZ to start the instance in."
  default     = ""
}

variable "number" {
  type        = number
  description = "number of instances to make"
  default     = 2
}

variable "enable_dhcp_options" {
  description = "boolean to determine if DHCP options are enabled"
  type        = bool
  default     = true
}

variable "domain_name" {
  type        = string
  description = "Domain name suffix to add to DHCP DNS"
}

variable "disable_api_termination" {
  type        = bool
  description = "If true, enables EC2 Instance Termination Protection"
  default     = false
}

variable "ebs_optimized" {
  type        = bool
  description = "If true, the launched EC2 instance will be EBS-optimized"
  default     = false
}

variable "encrypted" {
  type        = bool
  description = "(Optional) Enable volume encryption. (Default: false). Must be configured to perform drift detection."
  default     = true
}

variable "iam_instance_profile" {
  type        = string
  description = "The IAM Instance Profile to launch the instance with. Specified as the name of the Instance Profile."
  default     = ""
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
  description = "Select the instance type. Set in main.tf"
  default     = "t3a.medium"
}

variable "key_name" {
  type        = string
  description = "keypair name to use for ec2 instance deployment. Keypairs are used to obtain the username/password"
  default     = ""
}

variable "monitoring" {
  type        = bool
  description = "If true, the launched EC2 instance will have detailed monitoring enabled"
  default     = false
}

variable "name" {
  type        = string
  description = "Name of the instance"
}

variable "placement_group" {
  type        = string
  description = "The Placement Group to start the instance in"
  default     = ""
}

variable "private_ip" {
  type        = list(string)
  description = "Private IP address to associate with the instance in a VPC"
  default     = null
}

variable "region" {
  type        = string
  description = "(Required) VPC Region the resources exist in"
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
  description = "(Optional) Whether the volume should be destroyed on instance termination (Default: true)"
  default     = true
}

variable "root_volume_size" {
  type        = string
  description = "(Optional) The size of the volume in gigabytes."
  default     = "100"
}

variable "root_volume_type" {
  type        = string
  description = "(Optional) The type of volume. Can be standard, gp2, gp3 or io1. (Default: standard)"
  default     = "gp3"
}

variable "root_iops" {
  type        = number
  description = "(Optional) The amount of provisioned IOPS. This is only valid for volume_type of io1, and must be specified if using that type"
  default     = null
}

variable "source_dest_check" {
  type        = bool
  description = "Controls if traffic is routed to the instance when the destination address does not match the instance. Used for NAT or VPNs."
  default     = true
}

variable "subnet_id" {
  type        = list(string)
  description = "The VPC subnet the instance(s) will be assigned. Set in main.tf"
  default     = []
}

variable "tenancy" {
  type        = string
  description = "The tenancy of the instance (if the instance is running in a VPC). Available values: default, dedicated, host."
  default     = "default"
}

variable "tags" {
  type        = map(string)
  description = "A mapping of tags to assign to the resource"
  default     = {}
}

variable "user_data" {
  type        = string
  description = "The user data to provide when launching the instance"
  default     = ""
}

variable "vpc_id" {
  type        = string
  description = "The VPC id to add the security group"
}

variable "vpc_security_group_ids" {
  type        = list(any)
  description = "A list of security group IDs to associate with"
}
