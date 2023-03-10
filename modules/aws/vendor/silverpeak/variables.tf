variable "ami" {
  description = "ID of AMI to use for the instance"
}

variable "availability_zone" {
  description = "The AZ to start the instance in"
  default     = ""
}

variable "count" {
  description = "The total number of resources to create"
  default     = 1
}

variable "disable_api_termination" {
  description = "If true, enables EC2 Instance Termination Protection"
  default     = false
}

variable "dmz_subnet_id" {
  type        = list(any)
  description = "(Required) Subnet ID to create the ENI in."
}

variable "ebs_block_device" {
  description = "Additional EBS block devices to attach to the instance"
  default     = []
}

variable "ebs_optimized" {
  description = "If true, the launched EC2 instance will be EBS-optimized"
  default     = false
}

variable "ephemeral_block_device" {
  description = "Customize Ephemeral (also known as Instance Store) volumes on the instance"
  default     = []
}

variable "iam_instance_profile" {
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
  description = "The type of instance to start"
  default     = "c4.large"
}

variable "key_name" {
  description = "The key name to use for the instance"
  default     = ""
}

variable "lan0_description" {
  description = "(Optional) A description for the network interface."
  default     = "Silverpeak lan0 nic"
}

variable "lan0_private_ips" {
  type        = list(any)
  description = "(Optional) List of private IPs to assign to the ENI."
}

variable "mgmt0_description" {
  description = "(Optional) A description for the network interface."
  default     = "Silverpeak mgmt0 nic"
}

variable "mgmt0_private_ips" {
  type        = list(any)
  description = "(Optional) List of private IPs to assign to the ENI."
}

variable "mgmt_subnet_id" {
  type        = list(any)
  description = "(Required) Subnet ID to create the ENI in."
}

variable "monitoring" {
  description = "If true, the launched EC2 instance will have detailed monitoring enabled"
  default     = true
}

variable "name" {
  description = "Name to be used on all resources as prefix"
}

variable "placement_group" {
  description = "The Placement Group to start the instance in"
  default     = ""
}

variable "private_subnet_id" {
  type        = list(any)
  description = "(Required) Subnet ID to create the ENI in."
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

variable "encrypted" {
  type        = bool
  description = "(Optional) Enable volume encryption. (Default: false). Must be configured to perform drift detection."
  default     = true
  validation {
    condition     = can(regex("^(true|false)$", var.encrypted))
    error_message = "The value must be either true or false."
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

variable "root_volume_type" {
  type        = string
  description = "(Optional) Type of volume. Valid values include standard, gp2, gp3, io1, io2, sc1, or st1. Defaults to gp3."
  default     = "gp3"
  validation {
    condition     = can(regex("^(standard|gp2|gp3|io1|io2|sc1|st1)$", var.root_volume_type))
    error_message = "The value must be either standard, gp2, gp3, io1, io2, sc1, or st1."
  }
}

variable "root_volume_size" {
  type        = string
  description = "(Optional) The size of the volume in gigabytes."
  default     = "100"
}

variable "sg_description" {
  type        = string
  description = "(Optional, Forces new resource) The security group description. Defaults to 'Managed by Terraform'. Cannot be ''. NOTE: This field maps to the AWS GroupDescription attribute, for which there is no Update API. If you'd like to classify your security groups in a way that can be updated, use tags."
  default     = "Silverpeak SDWAN security group"
}

variable "sg_name" {
  description = "(Optional, Forces new resource) The name of the security group. If omitted, Terraform will assign a random, unique name"
  default     = "silverpeak_sg"
}

variable "source_dest_check" {
  type        = string
  description = "(Optional) Whether to enable source destination checking for the ENI. Default true."
  default     = false
}

variable "tags" {
  description = "(Optional) A mapping of tags to assign to the resource."
  default = {
    created_by  = "terraform"
    backup      = "true"
    terraform   = "true"
    environment = "prod"
    role        = "silverpeak_sdwan"
  }
}

variable "tenancy" {
  description = "The tenancy of the instance (if the instance is running in a VPC). Available values: default, dedicated, host."
  default     = "default"
}

variable "user_data" {
  description = "The user data to provide when launching the instance"
  default     = ""
}

variable "wan0_description" {
  description = "(Optional) A description for the network interface."
  default     = "Silverpeak wan0 nic"
}

variable "wan0_private_ips" {
  type        = list(any)
  description = "(Optional) List of private IPs to assign to the ENI."
}

variable "vpc_id" {
  description = "(Optional, Forces new resource) The VPC ID."
}
