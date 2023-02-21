variable "comment" {
  type        = string
  description = "(Optional) A comment for the hosted zone. Defaults to 'Managed by Terraform'."
  default     = "Managed by Terraform"
}

variable "delegation_set_id" {
  type        = string
  description = "(Optional) The ID of the reusable delegation set whose NS records you want to assign to the hosted zone. Conflicts with vpc as delegation sets can only be used for public zones."
  default     = null
}

variable "name" {
  type        = string
  description = "(Required) This is the name of the hosted zone."
}

variable "tags" {
  type        = map
  description = "(Optional) A map of tags to assign to the zone."
  default = {
    terraform = true
  }
}

variable "vpc" {
  type        = string
  description = "(Optional) Configuration block(s) specifying VPC(s) to associate with a private hosted zone. Conflicts with the delegation_set_id argument in this resource and any aws_route53_zone_association resource specifying the same zone ID. Detailed below."
  default     = null
}
