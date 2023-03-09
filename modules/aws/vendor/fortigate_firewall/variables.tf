variable "dmz_nic_description" {
  description = "Description of the dmz network interface"
  default     = "Fortigate FW DMZ nic"
  type        = string
}

variable "dmz_private_ips" {
  description = "(Optional) List of private IPs to assign to the ENI."
  default     = ["10.11.101.10", "10.11.102.10"]
  type        = list(string)
}

variable "dmz_subnet_id" {
  description = "The VPC subnet the instance(s) will be assigned. Set in main.tf"
  type        = list(any)
}

variable "enable_dmz" {
  description = "describe your variable"
  default     = true
  type        = bool
}

variable "ebs_optimized" {
  description = "If true, the launched EC2 instance will be EBS-optimized"
  default     = false
  type        = bool
}

variable "sg_name" {
  description = "Name of the security group"
  default     = "fortigate_fw_sg"
  type        = string
}

variable "vpc_id" {
  description = "The VPC id to add the security group"
  type        = string
}

variable "tags" {
  type = map(any)
  default = {
    created_by  = "terraform"
    terraform   = "yes"
    environment = "dev"
    role        = "fortigate_firewall"
  }
}

variable "number" {
  type        = number
  description = "number of resources to make"
  default     = 2
}

variable "public_subnet_id" {
  description = "The VPC subnet the instance(s) will be assigned. Set in main.tf"
  type        = list(any)
}

variable "private_subnet_id" {
  description = "The VPC subnet the instance(s) will be assigned. Set in main.tf"
  type        = list(any)
}

variable "private_nic_description" {
  description = "Description of the private network interface"
  default     = "Fortigate FW private nic"
  type        = string
}

variable "public_nic_description" {
  description = "Description of the public network interface"
  default     = "Fortigate FW public nic"
  type        = string
}

variable "wan_private_ips" {
  description = "(Optional) Private IP addresses to associate with the instance in a VPC."
  default     = ["10.11.201.10", "10.11.202.10"]
  type        = list(string)
}

variable "lan_private_ips" {
  description = "(Optional) List of private IPs to assign to the ENI."
  default     = ["10.11.1.10", "10.11.2.10"]
  type        = list(string)
}

variable "monitoring" {
  description = "If true, the launched EC2 instance will have detailed monitoring enabled"
  default     = true
  type        = bool
}

variable "source_dest_check" {
  description = "Boolean for source and destination checking on the nics"
  default     = false
  type        = bool
}

variable "ami_id" {
  description = "The AMI to use"
  type        = string
}

variable "instance_type" {
  description = "Select the instance type. Set in main.tf"
  default     = "c5.large"
  type        = string
}

variable "key_name" {
  description = "keypair name to use for ec2 instance deployment. Keypairs are used to obtain the username/password"
  type        = string
}

variable "iam_instance_profile" {
  description = "The IAM Instance Profile to launch the instance with. Specified as the name of the Instance Profile."
  default     = ""
  type        = string
}

variable "instance_name_prefix" {
  description = "Used to populate the Name tag. Set in main.tf"
  default     = "aws_fw"
  type        = string
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
  type        = number
  description = "root volume disk size"
  default     = 20
}

variable "ebs_device_name" {
  description = "ebs volume mount name"
  default     = "/dev/sdb"
  type        = string
}

variable "ebs_volume_type" {
  description = "ebs volume type"
  default     = "gp3"
  type        = string
}

variable "ebs_volume_size" {
  type        = number
  description = "ebs volume disk size"
  default     = 30
}

variable "ebs_volume_encrypted" {
  description = "Boolean whether or not the ebs volume is encrypted"
  default     = true
  type        = bool
}
