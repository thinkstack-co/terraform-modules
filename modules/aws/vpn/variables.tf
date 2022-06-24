variable "vpc_id" {
  type        = string
  description = "(Required) The VPC ID to create in."
}

variable "availability_zone" {
  type        = string
  description = "(Optional) The Availability Zone for the virtual private gateway."
  default     = null
}

variable "amazon_side_asn" {
  type        = number
  description = "(Optional) The Autonomous System Number (ASN) for the Amazon side of the gateway. If you don't specify an ASN, the virtual private gateway is created with the default ASN."
  default     = null
}

variable "customer_gw_name" {
  type        = list
  description = "(Required) List of names to use for the customer gateways"
}

variable "tags" {
  description = "(Optional) A map of tags to assign to the resource. If configured with a provider default_tags configuration block present, tags with matching keys will overwrite those defined at the provider-level."
  default     = {}
}

variable "name" {
  type        = string
  description = "(Required) Name to be used on all the resources as identifier"
}

variable "bgp_asn" {
  type        = number
  description = "(Required) The gateway's Border Gateway Protocol (BGP) Autonomous System Number (ASN)."
  default     = 65000
}

variable "certificate_arn" {
  type        = string
  description = "(Optional) The Amazon Resource Name (ARN) for the customer gateway certificate."
  default     = null
}

variable "ip_address" {
  type        = list(string)
  description = "(Required) The IPv4 address for the customer gateway device's outside interface."
}

variable "vpn_type" {
  type        = string
  description = "(Required) The type of customer gateway. The only type AWS supports at this time is ipsec.1"
  default     = "ipsec.1"
}

variable "static_routes_only" {
  type        = bool
  description = "(Optional, Default true) Whether the VPN connection uses static routes exclusively. Static routes must be used for devices that don't support BGP."
  default     = true
}

variable "transit_gateway_id" {
  type        = string
  description = "(Optional) The ID of the EC2 Transit Gateway."
  default     = null
}

###################################
# General Usage Variables
###################################

variable "enable_transit_gateway_attachment" {
  type        = bool
  description = "(Required) A boolean flag to enable/disable the use of a transit gateway attachment rather than VPN gateway attachment. Defaults false."
  default     = false
}
