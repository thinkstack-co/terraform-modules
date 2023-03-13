variable "description" {
  type        = string
  description = "(Optional) The description of the DB parameter group. Defaults to 'Managed by Terraform'."
}

variable "family" {
  type        = string
  description = "(Required) The family of the DB parameter group."
}

variable "name" {
  type        = string
  description = "(Optional, Forces new resource) The name of the DB parameter group. If omitted, Terraform will assign a random, unique name."
}

variable "tags" {
  type        = map(any)
  description = "(Optional) A mapping of tags to assign to the resource."
}
