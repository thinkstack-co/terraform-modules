variable "description" {
  type        = string
  description = "(Optional) The description of the DB subnet group. Defaults to 'Managed by Terraform'."
}

variable "name" {
  type        = string
  description = "(Optional, Forces new resource) The name of the DB subnet group. If omitted, Terraform will assign a random, unique name."
}

variable "subnet_ids" {
  description = "(Required) A list of VPC subnet IDs."
  default     = []
}

variable "tags" {
  type        = map
  description = "(Optional) A mapping of tags to assign to the resource."
  default     = {}
}
