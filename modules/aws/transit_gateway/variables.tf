variable "amazon_side_asn" {
  description = "(Optional) Private Autonomous System Number (ASN) for the Amazon side of a BGP session."
  default     = "64525"
  type        = string
}

variable "auto_accept_shared_attachments" {
  description = "(Optional) Whether resource attachment requests are automatically accepted. "
  default     = "disable"
  type        = string
}

variable "default_route_table_association" {
  description = "(Optional) Whether resource attachments are automatically associated with the default association route table."
  default     = "enable"
  type        = string
}

variable "default_route_table_propagation" {
  description = "(Optional) Whether resource attachments automatically propagate routes to the default propagation route table."
  default     = "enable"
  type        = string
}

variable "description" {
  description = "(Optional) Description of the EC2 Transit Gateway."
  default     = "Transit gateway to allow access across VPCs or accounts."
  type        = string
}

variable "dns_support" {
  description = "(Optional) Whether DNS support is enabled."
  default     = "enable"
  type        = string
}

variable "name" {
  description = "(Required) The name of the transit gateway"
  type        = string
}

variable "tags" {
  description = "(Optional) Map of tags for the EC2 Transit Gateway."
  type        = map(any)
  default = {
    terraform   = "true"
    environment = "prod"
    project     = "core_infrastructure"
  }
}

variable "transit_gateway_cidr_blocks" {
  type        = list(string)
  description = "(Optional) One or more IPv4 or IPv6 CIDR blocks for the transit gateway. Must be a size /24 CIDR block or larger for IPv4, or a size /64 CIDR block or larger for IPv6."
  default     = null
}

variable "vpn_ecmp_support" {
  description = "(Optional) Whether VPN Equal Cost Multipath Protocol support is enabled."
  default     = "enable"
  type        = string
}