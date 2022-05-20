variable "team_id" {
  description = "(Required) ID of the team to add to the workspace."
  type = string
}

variable "workspace_id" {
  description = "(Required) ID of the workspace to which the team will be added."
  type = string
}

variable "access" {
  description = "(Required) Type of fixed access to grant. Valid values are admin, read, plan, or write. To use custom permissions, use a permissions block instead. This value must not be provided if permissions is provided."
  type = string
}
