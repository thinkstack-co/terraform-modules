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
  type        = list
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
  # https://docs.aws.amazon.com/AWSEC2/latest/UserGuide/terminating-instances.html#Using_ChangingInstanceInitiatedShutdownBehavior
  description = "Shutdown behavior for the instance"
  default     = ""
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
  type        = list
  description = "(Optional) List of private IPs to assign to the ENI."
}

variable "mgmt0_description" {
  description = "(Optional) A description for the network interface."
  default     = "Silverpeak mgmt0 nic"
}

variable "mgmt0_private_ips" {
  type        = list
  description = "(Optional) List of private IPs to assign to the ENI."
}

variable "mgmt_subnet_id" {
  type        = list
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
  type        = list
  description = "(Required) Subnet ID to create the ENI in."
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
  description = "(Optional) The type of volume. Can be standard, gp2, or io1. (Default: standard)"
  default     = "gp2"
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
  type        = list
  description = "(Optional) List of private IPs to assign to the ENI."
}

variable "vpc_id" {
  description = "(Optional, Forces new resource) The VPC ID."
}
