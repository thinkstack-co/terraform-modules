variable "bgp_asn" {
  type        = number
  description = "(Optional) The BGP ASN number assigned customer device. If not provided, it will use the same BGP ASN as is associated with Transit Gateway."
  default     = 64512
}

variable "inside_cidr_blocks" {
  type        = list(string)
  description = "(Required) The CIDR block that will be used for addressing within the tunnel. It must contain exactly one IPv4 CIDR block and up to one IPv6 CIDR block. The IPv4 CIDR block must be /29 size and must be within 169.254.0.0/16 range, with exception of: 169.254.0.0/29, 169.254.1.0/29, 169.254.2.0/29, 169.254.3.0/29, 169.254.4.0/29, 169.254.5.0/29, 169.254.169.248/29. The IPv6 CIDR block must be /125 size and must be within fd00::/8. The first IP from each CIDR block is assigned for customer gateway, the second and third is for Transit Gateway (An example: from range 169.254.100.0/29, .1 is assigned to customer gateway and .2 and .3 are assigned to Transit Gateway)"
}

variable "name" {
  description = "(Required) The name of the transit gateway"
  type        = string
}

variable "peer_address" {
  type        = string
  description = "(Required) The IP addressed assigned to customer device, which will be used as tunnel endpoint. It can be IPv4 or IPv6 address, but must be the same address family as transit_gateway_address"
}

variable "tags" {
  type        = map(any)
  description = "(Optional) Key-value tags for the EC2 Transit Gateway Connect. If configured with a provider default_tags configuration block present, tags with matching keys will overwrite those defined at the provider-level."
  default = {
    terraform   = "true"
    environment = "prod"
    project     = "core_infrastructure"
  }
}

variable "transit_gateway_address" {
  type        = string
  description = "(Required) The IP address assigned to Transit Gateway, which will be used as tunnel endpoint. This address must be from associated Transit Gateway CIDR block. The address must be from the same address family as peer_address. If not set explicitly, it will be selected from associated Transit Gateway CIDR blocks"
}

variable "transit_gateway_attachment_id" {
  type        = string
  description = "(Required) The Transit Gateway Connect"
}
