variable "ami" {
  description = "(Required) AMI ID to use when launching the instance"
}

variable "associate_public_ip_address" {
  description = "If true, the EC2 instance will have associated public IP address"
  default     = false
}

variable "availability_zone" {
  description = "The AZ to start the instance in"
  default     = ""
}

variable "number" {
  description = "Number of instances to launch"
  default     = 1
}

variable "disable_api_termination" {
  description = "If true, enables EC2 Instance Termination Protection"
  default     = false
}

variable "ebs_block_device" {
  description = "Additional EBS block devices to attach to the instance"
  default     = []
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
  description = "The AWS instance type  to utilize for the specifications of the instance"
}

variable "ipv6_address_count" {
  description = "A number of IPv6 addresses to associate with the primary network interface. Amazon EC2 chooses the IPv6 addresses from the range of your subnet."
  default     = 0
}

variable "ipv6_addresses" {
  description = "Specify one or more IPv6 addresses from the range of the subnet to associate with the primary network interface"
  default     = []
}

variable "key_name" {
  description = "The key name to use for the instance"
  default     = ""
}

variable "monitoring" {
  description = "If true, the launched EC2 instance will have detailed monitoring enabled"
  default     = false
}

variable "name" {
  description = "Name to be used on all resources as prefix"
}

variable "placement_group" {
  description = "The Placement Group to start the instance in"
  default     = ""
}

variable "private_ip" {
  description = "Private IP address to associate with the instance in a VPC"
  default     = ""
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
  description = "The VPC Subnet ID to launch in"
  default     = ""
}

variable "tags" {
  description = "A mapping of tags to assign to the resource"
  default     = {}
}

variable "tenancy" {
  description = "The tenancy of the instance (if the instance is running in a VPC). Available values: default, dedicated, host."
  default     = "default"
}

variable "user_data" {
  description = "The user data to provide when launching the instance"
  default     = ""
}

variable "vpc_security_group_ids" {
  description = "A list of security group IDs to associate with"
  type        = list
}
