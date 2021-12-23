variable "auto_accept" {
  default     = false
  type        = string
  description = "(Optional) Whether or not to accept the peering request. Defaults to false."
}

variable "tags" {
  default = {
    terraform   = "true"
    created_by  = "Jake Jones"
    environment = "prod"
    role        = "vpc_peering_connection_accepter"
  }
  type        = map
  description = "(Optional) A mapping of tags to assign to the resource."
}

variable "vpc_peering_connection_id" {
  type        = string
  description = "(Required) The VPC Peering Connection ID to manage."
}