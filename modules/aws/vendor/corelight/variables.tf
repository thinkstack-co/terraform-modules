variable "sg_description" {
  type        = string
  description = "(Optional, Forces new resource) The security group description. Defaults to 'Managed by Terraform'. Cannot be ''. NOTE: This field maps to the AWS GroupDescription attribute, for which there is no Update API. If you'd like to classify your security groups in a way that can be updated, use tags."
  default     = "Corelight security group"
}

variable "sg_name" {
  type        = string
  description = "(Optional, Forces new resource) The name of the security group. If omitted, Terraform will assign a random, unique name"
  default     = "corelight_sg"
}

variable "vpc_id" {
  type        = string
  description = "(Required, Forces new resource) The VPC ID."
}

variable "vxlan_cidr_blocks" {
  type        = list(any)
  description = "(Required) List of IP addresses and cidr blocks which are allowed to send VPC mirror traffic"
}

variable "mgmt_cidr_blocks" {
  type        = list(any)
  description = "(Optional) List of IP addresses and cidr blocks which are allowed to access SSH and HTTPS to this instance"
  default     = []
}

variable "tags" {
  type        = map(any)
  description = "(Optional) A mapping of tags to assign to the resource."
  default = {
    created_by  = "terraform"
    backup      = "true"
    terraform   = "true"
    environment = "prod"
    role        = "corelight network monitor"
  }
}

variable "enable_deletion_protection" {
  type        = bool
  description = "(Optional) If true, deletion of the load balancer will be disabled via the AWS API. This will prevent Terraform from deleting the load balancer. Defaults to false."
  default     = false
}

variable "internal" {
  type        = bool
  description = "(Optional) If true, the LB will be internal."
  default     = true
}

variable "nlb_name" {
  type        = string
  description = "(Optional) The name of the LB. This name must be unique within your AWS account, can have a maximum of 32 characters, must contain only alphanumeric characters or hyphens, and must not begin or end with a hyphen. If not specified, Terraform will autogenerate a name beginning with tf-lb."
  default     = "aws-prod-corelight-nlb"
}

variable "number" {
  type        = number
  description = "(Optional) Number of instances and resources to launch"
  default     = 1
}

variable "listener_nic_description" {
  type        = string
  description = "(Optional) A description for the network interface."
  default     = "Corelight listener nic"
}

variable "mgmt_nic_description" {
  type        = string
  description = "(Optional) A description for the network interface."
  default     = "Corelight mgmt nic"
}

variable "ami" {
  type        = string
  description = "(Required) AMI ID to use when launching the instance"
}

variable "availability_zones" {
  type        = list(string)
  description = "(Required) The AZ to start the instance in"
}

variable "disable_api_termination" {
  type        = bool
  description = "(Optional) If true, enables EC2 Instance Termination Protection"
  default     = false
}

variable "ebs_optimized" {
  type        = bool
  description = "(Optional) If true, the launched EC2 instance will be EBS-optimized"
  default     = false
}

variable "iam_instance_profile" {
  type        = string
  description = "(Optional) The IAM Instance Profile to launch the instance with. Specified as the name of the Instance Profile."
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
  description = "(Optional) The AWS instance type  to utilize for the specifications of the instance"
  default     = "m5.xlarge"
}

variable "key_name" {
  type        = string
  description = "(Optional) The key name to use for the instance"
  default     = ""
}

variable "monitoring" {
  type        = bool
  description = "(Optional) If true, the launched EC2 instance will have detailed monitoring enabled"
  default     = false
}

variable "name" {
  type        = string
  description = "(Optional) Name to be used on all resources as a prefix for tags and names"
  default     = "aws_prod_corelight"
}

variable "placement_group" {
  type        = string
  description = "(Optional) The Placement Group to start the instance in"
  default     = ""
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

variable "region" {
  type        = string
  description = "(Required) VPC Region the resources exist in"
}

variable "root_delete_on_termination" {
  type        = string
  description = "(Optional) Whether the volume should be destroyed on instance termination (Default: true)"
  default     = true
}

variable "encrypted" {
  type        = bool
  description = "(Optional) Enable volume encryption. (Default: false). Must be configured to perform drift detection."
  default     = true
}

variable "root_volume_size" {
  type        = string
  description = "(Optional) The size of the volume in gigabytes."
  default     = "64"
}

variable "root_volume_type" {
  type        = string
  description = "(Optional) The type of volume. Can be standard, gp2, or io1. (Default: standard)"
  default     = "gp2"
}

variable "source_dest_check" {
  type        = bool
  description = "(Optional) Controls if traffic is routed to the instance when the destination address does not match the instance. Used for NAT or VPNs."
  default     = false
}

variable "mgmt_subnet_ids" {
  type        = list(any)
  description = "(Required) The VPC Subnet ID for the mgmt nic"
}

variable "listener_subnet_ids" {
  type        = list(any)
  description = "(Required) The VPC Subnet ID to launch in"
}

variable "tenancy" {
  type        = string
  description = "(Optional) The tenancy of the instance (if the instance is running in a VPC). Available values: default, dedicated, host."
  default     = "default"
  validation {
    condition     = can(regex("^(default|dedicated|host)$", var.tenancy))
    error_message = "The value must be either default, dedicated, or host."
  }
}

variable "user_data" {
  type        = string
  description = "(Required) Input the Customer ID from Corelight. Example: '57ee000-1214-999e-hfij-1827417d7421'"
}
