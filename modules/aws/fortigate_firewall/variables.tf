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
    role        = "domain_controller"
  }
}

variable "number_of_instances" {
  description = "number of instances to make"
  default     = 2
}

variable "public_subnet_id" {
  description = "The VPC subnet the instance(s) will be assigned. Set in main.tf"
  type        = "list"
}

variable "private_subnet_id" {
  description = "The VPC subnet the instance(s) will be assigned. Set in main.tf"
  type        = "list"
}

variable "private_nic_description" {
  description = "Description of the private network interface"
  default     = "Fortigate FW private nic"
}

variable "public_nic_description" {
  description = "Description of the public network interface"
  default     = "Fortigate FW public nic"
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

variable "root_volume_type" {
  description = "Root volume EBS type"
  default     = "gp2"
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
