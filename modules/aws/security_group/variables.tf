variable "description" {
    description = "Description of the security group"
    default     = "Terraform created SG"
}

variable "name" {
    description = "Name of the security group"
}

variable "tags" {
    description = "Tags to apply to the security group"
    default     = {}
}

variable "vpc_id" {
    description = "VPC with which to add the security group to"
}
