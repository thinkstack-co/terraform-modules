variable "destination_cidr_block" {
  type = string
  description = " (Optional) The destination CIDR block."
}

variable "destination_ipv6_cidr_block" {
  type = string
  description = "(Optional) The destination IPv6 CIDR block."
  default = null
}

variable "egress_only_gateway_id" {
  type = string
  description = "(Optional) An ID of a VPC Egress Only Internet Gateway."
  default = ""
}

variable "gateway_id" {
  type = string
  description = "(Optional) An ID of a VPC internet gateway or a virtual private gateway."
  default = ""
}

variable "instance_id" {
  type = string
  description = "(Optional) An ID of an EC2 instance."
  default = ""
}

variable "nat_gateway_id" {
  type = string
  description = "(Optional) An ID of a VPC NAT gateway."
  default = ""
}

variable "network_interface_id" {
  type = list
  description = "(Optional) An ID of a network interface."
  default = []
}

variable "route_table_id" {
  type = list
  description = "(Required) The ID of the routing table."
}

variable "vpc_peering_connection_id" {
  type = string
  description = "(Optional) An ID of a VPC peering connection."
  default = ""
}
