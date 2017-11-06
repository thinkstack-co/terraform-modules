variable "vpc_id" {
  description = "The VPC id to add the security group"
}

variable "sg_name" {
  description = "Name of the security group"
  default     = "domain_controller_sg"
}

variable "sg_cidr_blocks" {
  description = "security group allowed cidr blocks"
  type        = "list"
}

variable "security_group_name" {
  description = "Name of the security group"
  default     = "domain_controller_sg"
}

variable "ami_id" {
  description = "The AMI to use"
}

variable "number_of_instances" {
  description = "number of instances to make"
  default     = 2
}

variable "subnet_id" {
  description = "The VPC subnet the instance(s) will be assigned. Set in main.tf"
  type        = "list"
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

#variable "security_group_ids" {
#  description = "Lits of security group ids to attach to the instance"
#}

variable "root_volume_type" {
  description = "Root volume EBS type"
  default     = "gp2"
}

variable "root_volume_size" {
  description = "root volume disk size"
  default     = "60"
}

variable "ebs_device_name" {
  description = "ebs volume mount name"
  default     = "/dev/xvdf"
}

variable "ebs_volume_type" {
  description = "ebs volume type"
  default     = "gp2"
}

variable "ebs_volume_size" {
  description = "ebs volume disk size"
  default     = "8"
}

variable "ebs_volume_encrypted" {
  description = "Boolean whether or not the ebs volume is encrypted"
  default     = true
}

variable "tags" {
  default = {
    created_by  = "terraform"
    terraform   = "yes"
    environment = "dev"
    role        = "domain_controller"
  }
}

variable "instance_name_prefix" {
  description = "Used to populate the Name tag. Set in main.tf"
  default     = "aws_dc"
}

variable "instance_role" {
    description = "Describe the role your instance will have"
    default     = "domain_controller"
}

variable "domain_name" {
  description = "Domain name suffix to add to DHCP DNS"
}
