variable "cidr_blocks" {
  description = "security group allowed cidr blocks"
  type        = list
}

variable "description" {
  type = string
  description = "(Optional, Forces new resource) The security group description. Defaults to 'Managed by Terraform'. Cannot be blank. NOTE: This field maps to the AWS GroupDescription attribute, for which there is no Update API. If you'd like to classify your security groups in a way that can be updated, use tags."
}

variable "name" {
  description = "(Optional, Forces new resource) The name of the security group. If omitted, Terraform will assign a random, unique name"
}

variable "tags" {
  description = "(Optional) A mapping of tags to assign to the resource."
  default     = {
    terraform = "true"
  }
}

variable "vpc_id" {
  description = "The VPC id to add the security group"
}
