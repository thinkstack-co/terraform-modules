variable "dmz_nic_description" {
  description = "Description of the dmz network interface"
  default     = "Fortigate FW DMZ nic"
}

variable "dmz_private_ips" {
  type        = list
  description = "(Optional) List of private IPs to assign to the ENI."
  default     = ["10.11.101.10", "10.11.102.10"]
}

variable "dmz_subnet_id" {
  description = "The VPC subnet the instance(s) will be assigned. Set in main.tf"
  type        = list
}

variable "enable_dmz" {
  description = "describe your variable"
  default     = true
}

variable "ebs_optimized" {
  description = "If true, the launched EC2 instance will be EBS-optimized"
  default     = false
}

variable "sg_name" {
  description = "Name of the security group"
  default     = "fortigate_fw_sg"
}

variable "vpc_id" {
  description = "The VPC id to add the security group"
}

variable "tags" {
  default = {
    created_by  = "terraform"
    terraform   = "yes"
    environment = "dev"
    role        = "fortigate_firewall"
  }
}

variable "number" {
  description = "number of resources to make"
  default     = 2
}

variable "public_subnet_id" {
  description = "The VPC subnet the instance(s) will be assigned. Set in main.tf"
  type        = list
}

variable "private_subnet_id" {
  description = "The VPC subnet the instance(s) will be assigned. Set in main.tf"
  type        = list
}

variable "private_nic_description" {
  description = "Description of the private network interface"
  default     = "Fortigate FW private nic"
}

variable "public_nic_description" {
  description = "Description of the public network interface"
  default     = "Fortigate FW public nic"
}

variable "wan_private_ips" {
  type        = list
  description = "(Optional) Private IP addresses to associate with the instance in a VPC."
  default     = ["10.11.201.10", "10.11.202.10"]
}

variable "lan_private_ips" {
  type        = list
  description = "(Optional) List of private IPs to assign to the ENI."
  default     = ["10.11.1.10", "10.11.2.10"]
}

variable "monitoring" {
  description = "If true, the launched EC2 instance will have detailed monitoring enabled"
  default     = true
}

variable "source_dest_check" {
  description = "Boolean for source and destination checking on the nics"
  default     = false
}

variable "ami_id" {
  description = "The AMI to use"
}

variable "instance_type" {
  description = "Select the instance type. Set in main.tf"
  default     = "m3.medium"
}

variable "key_name" {
  description = "keypair name to use for ec2 instance deployment. Keypairs are used to obtain the username/password"
}

variable "instance_name_prefix" {
  description = "Used to populate the Name tag. Set in main.tf"
  default     = "aws_fw"
}

variable "region" {
  type        = string
  description = "(Required) VPC Region the resources exist in"
}

variable "root_volume_type" {
  description = "Root volume EBS type"
  default     = "gp3"
}

variable "root_volume_size" {
  description = "root volume disk size"
  default     = "20"
}

variable "ebs_device_name" {
  description = "ebs volume mount name"
  default     = "/dev/sdb"
}

variable "ebs_volume_type" {
  description = "ebs volume type"
  default     = "gp2"
}

variable "ebs_volume_size" {
  description = "ebs volume disk size"
  default     = "30"
}

variable "ebs_volume_encrypted" {
  description = "Boolean whether or not the ebs volume is encrypted"
  default     = true
}

variable "instance_role" {
  description = "Describe the role your instance will have"
  default     = "fortigate_firewall"
}
