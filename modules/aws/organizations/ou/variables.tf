variable "name" {
  type        = string
  description = "(Required) The name of the Organizational Unit."
}

variable "parent_id" {
  type        = string
  description = "(Required) The unique identifier (ID) of the parent root or organizational unit (OU) that you want to create the OU in."
}

variable "tags" {
  type        = map(string)
  description = "(Optional) A mapping of tags to assign to the resource."
  default     = {
    terraform = "true"
  }
}
