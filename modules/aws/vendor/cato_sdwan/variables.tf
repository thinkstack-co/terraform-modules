############################################
# Security Groups
############################################

variable "wan_mgmt_sg_name" {
  description = "(Optional, Forces new resource) Name of the security group. If omitted, Terraform will assign a random, unique name."
  default     = "cato_wan_mgmt_sg"
  type        = string
}

variable "vpc_id" {
  description = "(Required, Forces new resource) VPC ID. Defaults to the region's default VPC."
  type        = string
}

variable "lan_sg_name" {
  description = "(Optional, Forces new resource) Name of the security group. If omitted, Terraform will assign a random, unique name."
  default     = "cato_lan_sg"
  type        = string
}

variable "cato_lan_cidr_blocks" {
  type        = list(string)
  description = "(Optional) List of CIDR blocks allowed to utilize the Cato instance for SDWAN communication."
  default     = null
}

############################################
# ENI
############################################

variable "mgmt_nic_description" {
  description = "(Optional) Description for the network interface."
  default     = "Cato mgmt nic"
  type        = string
}

variable "mgmt_ips" {
  description = "(Optional) List of private IPs to assign to the ENI."
  default     = ["10.11.61.12", "10.11.62.12", "10.11.63.12"]
  type        = list(string)
}

variable "mgmt_subnet_id" {
  description = "(Required) Subnet ID to create the ENI in."
  type        = list(string)
}

variable "public_nic_description" {
  description = "(Optional) Description for the network interface."
  default     = "Cato public nic"
  type        = string
}

variable "public_subnet_id" {
  description = "(Required) Subnet ID to create the ENI in."
  type        = list(string)
}

variable "public_ips" {
  description = "(Optional) Private IP addresses to associate with the instance in a VPC."
  default     = ["10.11.201.12", "10.11.202.12", "10.11.203.12"]
  type        = list(string)
}

variable "private_subnet_id" {
  description = "(Required) Subnet ID to create the ENI in."
  type        = list(string)
}

variable "private_nic_description" {
  description = "(Optional) Description for the network interface."
  default     = "Cato private nic"
  type        = string
}

variable "private_ips" {
  description = "(Optional) List of private IPs to assign to the ENI."
  default     = ["10.11.1.12", "10.11.2.12", "10.11.3.12"]
  type        = list(string)
}

variable "source_dest_check" {
  description = "(Optional) Whether to enable source destination checking for the ENI. Default false."
  default     = false
  type        = bool
}

############################################
# EC2 Instance
############################################

variable "ebs_optimized" {
  description = "(Optional) If true, the launched EC2 instance will be EBS-optimized. Note that if this is not set on an instance type that is optimized by default then this will show as disabled but if the instance type is optimized by default then there is no need to set this and there is no effect to disabling it. See the EBS Optimized section of the AWS User Guide for more information."
  default     = true
  type        = bool
}

variable "monitoring" {
  description = "(Optional) If true, the launched EC2 instance will have detailed monitoring enabled. (Available since v0.6.0)"
  default     = true
  type        = bool
}

variable "ami" {
  description = "(Required) AMI to use for the instance. Required unless launch_template is specified and the Launch Template specifes an AMI. If an AMI is specified in the Launch Template, setting ami will override the AMI specified in the Launch Template."
  type        = string
}

variable "instance_type" {
  description = "(Optional) Instance type to use for the instance. Updates to this field will trigger a stop/start of the EC2 instance."
  default     = "c5.xlarge"
  type        = string
}

variable "key_name" {
  description = "(Required) Key name of the Key Pair to use for the instance; which can be managed using the aws_key_pair resource."
  type        = string
}

variable "iam_instance_profile" {
  description = "(Optional) IAM Instance Profile to launch the instance with. Specified as the name of the Instance Profile. Ensure your credentials have the correct permission to assign the instance profile according to the EC2 documentation, notably iam:PassRole."
  default     = null
  type        = string
}

variable "instance_name_prefix" {
  description = "(Optional) Used to populate the Name tag."
  default     = "aws_prod_cato"
  type        = string
}

variable "root_volume_type" {
  description = "(Optional) Type of volume. Valid values include standard, gp2, gp3, io1, io2, sc1, or st1. Defaults to gp3"
  default     = "gp3"
  type        = string
}

variable "root_volume_size" {
  description = "(Optional) Size of the root volume in gibibytes (GiB)."
  default     = 16
  type        = number
}

variable "root_ebs_volume_encrypted" {
  description = "(Optional) Whether to enable volume encryption on the root ebs volume. Defaults to true. Must be configured to perform drift detection."
  default     = true
  type        = bool
}

variable "user_data" {
  type        = string
  description = "(Optional) User data to provide when launching the instance. Do not pass gzip-compressed data via this argument; see user_data_base64 instead. Updates to this field will trigger a stop/start of the EC2 instance by default. If the user_data_replace_on_change is set then updates to this field will trigger a destroy and recreate."
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

###############################################################
# General Use Variables
###############################################################

variable "tags" {
  description = "(Optional) Map of tags to assign to the device."
  default = {
    created_by  = "terraform"
    terraform   = "true"
    environment = "prod"
    role        = "cato_sdwan"
  }
  type = map(any)
}

variable "number" {
  description = "(Optional) Quantity of resources to make with this module. Example: Setting this to 2 will create 2 of all the required resources. Default: 1"
  default     = 1
  type        = number
}