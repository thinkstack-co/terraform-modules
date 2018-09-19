variable "description" {
  type = "string"
  description = "(Optional) The description of the DB parameter group. Defaults to 'Managed by Terraform'."
}

variable "family" {
  type = "string"
  description = "(Required) The family of the DB parameter group."
}

variable "name" {
  type = "string"
  description = "(Optional, Forces new resource) The name of the DB parameter group. If omitted, Terraform will assign a random, unique name."
}

variable "parameter" {
  type = "map"
  description = "(Optional) A list of DB parameters to apply. Note that parameters may differ from a family to an other. Full list of all parameters can be discovered via aws rds describe-db-parameters after initial creation of the group."
}

variable "tags" {
  type = "map"
  description = "(Optional) A mapping of tags to assign to the resource."
}
