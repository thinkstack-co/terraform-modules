variable "destination_cidr_block" {
  type        = string
  description = " (Optional) The destination CIDR block."
}

variable "destination_ipv6_cidr_block" {
  type        = string
  description = "(Optional) The destination IPv6 CIDR block."
  default     = null
}

variable "transit_gateway_id" {
  type        = string
  description = "(Required) Identifier of an EC2 Transit Gateway."
}

variable "route_table_id" {
  type        = list(any)
  description = "(Required) The ID of the routing table."
}

