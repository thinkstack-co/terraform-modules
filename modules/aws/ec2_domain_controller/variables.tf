variable "ami" {
  description = "The AMI to use"
}

variable "availability_zone" {
  description = "The AZ to start the instance in"
  default     = ""
}

variable "number" {
  description = "number of instances to make"
  default     = 2
}

variable "domain_name" {
  description = "Domain name suffix to add to DHCP DNS"
}

variable "disable_api_termination" {
  description = "If true, enables EC2 Instance Termination Protection"
  default     = false
}

variable "ebs_optimized" {
  description = "If true, the launched EC2 instance will be EBS-optimized"
  default     = false
}

variable "encrypted" {
  type        = bool
  description = "(Optional) Enable volume encryption. (Default: false). Must be configured to perform drift detection."
  default     = true
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
  description = "Select the instance type. Set in main.tf"
  default     = "t2.medium"
}

variable "key_name" {
  description = "keypair name to use for ec2 instance deployment. Keypairs are used to obtain the username/password"
  default     = ""
}

variable "monitoring" {
  description = "If true, the launched EC2 instance will have detailed monitoring enabled"
  default     = false
}

variable "name" {
  description = "Name of the instance"
}

variable "placement_group" {
  description = "The Placement Group to start the instance in"
  default     = ""
}

variable "private_ip" {
  description = "Private IP address to associate with the instance in a VPC"
  default     = []
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
  description = "(Optional) The amount of provisioned IOPS. This is only valid for volume_type of io1, and must be specified if using that type"
  default     = ""
}

variable "source_dest_check" {
  description = "Controls if traffic is routed to the instance when the destination address does not match the instance. Used for NAT or VPNs."
  default     = true
}

variable "subnet_id" {
  description = "The VPC subnet the instance(s) will be assigned. Set in main.tf"
  default     = []
}

variable "tenancy" {
  description = "The tenancy of the instance (if the instance is running in a VPC). Available values: default, dedicated, host."
  default     = "default"
}

variable "tags" {
  description = "A mapping of tags to assign to the resource"
  default     = {}
}

variable "user_data" {
  description = "The user data to provide when launching the instance"
  default     = ""
}

variable "vpc_id" {
  description = "The VPC id to add the security group"
}

variable "vpc_security_group_ids" {
  description = "A list of security group IDs to associate with"
  type        = list
}
