variable "name" {
    description = "Name of the security group"
}

variable "description" {
    description = "Description of the security group"
    default     = "Terraform created SG"
}

variable "vpc_id" {
    description = "VPC with which to add the security group to"
}

variable "tags" {
    description = "Tags to apply to the security group"
    default     = {}
}
