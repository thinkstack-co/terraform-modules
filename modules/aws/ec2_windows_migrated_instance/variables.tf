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
    default = "t2.medium"
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
  default     = ""
}

variable "security_group_ids" {
  type = list
  description = "Lits of security group ids to attach to the instance"
}

/*variable "root_volume_type" {
  description = "Root volume EBS type"
  default     = "gp2"
}

variable "root_volume_size" {
  description = "root volume disk size"
  default     = "80"
}

variable "ebs_device_name" {
  description = "ebs volume mount name"
  default     = "/dev/sdf"
}

variable "ebs_volume_type" {
  description = "ebs volume type"
  default     = "gp2"
}

variable "ebs_volume_size" {
  description = "ebs volume disk size"
  default     = "8"
}*/

variable "region" {
  type = string
  description = "(Required) VPC Region the resources exist in"
}

variable "tags" {
  default = {
    created_by  = "terraform"
    terraform   = "true"
  }
}

variable "instance_name_prefix" {
  description = "Used to populate the Name tag. Set in main.tf"
}
