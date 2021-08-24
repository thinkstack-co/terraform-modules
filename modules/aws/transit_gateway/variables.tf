variable "amazon_side_asn" {
  description = "(Optional) Private Autonomous System Number (ASN) for the Amazon side of a BGP session."
  default     = "64525"
}

variable "auto_accept_shared_attachments" {
  description = "(Optional) Whether resource attachment requests are automatically accepted. "
  default     = "disable"
}

variable "default_route_table_association" {
  description = "(Optional) Whether resource attachments are automatically associated with the default association route table."
  default     = "enable"
}

variable "default_route_table_propagation" {
  description = "(Optional) Whether resource attachments automatically propagate routes to the default propagation route table."
  default     = "enable"
}

variable "description" {
  description = "(Optional) Description of the EC2 Transit Gateway."
  default     = "Transit gateway to allow access across VPCs or accounts."
}

variable "dns_support" {
  description = "(Optional) Whether DNS support is enabled."
  default     = "enable"
}

variable "tags" {
  description = "(Optional) Map of tags for the EC2 Transit Gateway."
  default     = {
    terraform   = "true"
    environment = "prod"
    project     = "core_infrastructure"
  }
}

variable "vpn_ecmp_support" {
  description = "(Optional) Whether VPN Equal Cost Multipath Protocol support is enabled."
  default     = "enable"
}