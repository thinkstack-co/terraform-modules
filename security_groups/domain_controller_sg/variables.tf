variable "cidr_blocks" {
  description = "security group allowed cidr blocks"
  type        = list
}

variable "name" {
  description = "Name of the security group"
  default     = "domain_controller_sg"
}

variable "vpc_id" {
  description = "The VPC id to add the security group"
}
