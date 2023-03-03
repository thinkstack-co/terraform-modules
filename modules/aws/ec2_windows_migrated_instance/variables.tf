variable "ami" {
  description = "ID of AMI to use for the instance"
}

variable "ebs_optimized" {
  description = "If true, the launched EC2 instance will be EBS-optimized"
  default     = false
}

variable "count" {
  description = "Number of instances to launch"
  default     = 1
}

variable "subnet_id" {
  description = "The VPC subnet the instance(s) will be assigned. Set in main.tf"
}

variable "instance_type" {
  description = "Select the instance type. Set in main.tf"
  default     = "t2.medium"
}

variable "key_name" {
  description = "keypair name to use for ec2 instance deployment. Keypairs are used to obtain the username/password"
}

variable "user_data" {
  description = "The path to a file with user_data for the instances"
  default     = ""
}

variable "private_ip" {
  description = "Private IP address to associate with the instance in a VPC"
  default     = null
}

variable "security_group_ids" {
  type        = list(any)
  description = "Lits of security group ids to attach to the instance"
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

variable "tags" {
  default = {
    created_by = "terraform"
    terraform  = "true"
  }
}

variable "instance_name_prefix" {
  description = "Used to populate the Name tag. Set in main.tf"
}
