variable "auto_accept" {
  type        = string
  description = "(Optional) Whether or not to accept the peering request. Defaults to false."
}

variable "tags" {
  type        = map
  description = "(Optional) A mapping of tags to assign to the resource."
}

variable "vpc_peering_connection_id" {
  type        = string
  description = "(Required) The VPC Peering Connection ID to manage."
}