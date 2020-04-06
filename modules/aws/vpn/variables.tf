variable "vpc_id" {
    description = "VPC ID"
}

variable "availability_zone" {
    description = "Availability zone in which to apply the VPN"
    default     = ""
}

variable "customer_gw_name" {
    type = list
    description = "(Required) List of names to use for the customer gateways"
}

variable "tags" {
    description = "Tags assigned to all created resources"
    default     = {}
}

variable "name" {
  description = "Name to be used on all the resources as identifier"
  default     = "vpn_terraform"
}

variable "bgp_asn" {
    description = "BGP ASN used for dynamic routing between the customer gateway and AWS gateway"
    default     = 65000
}

variable "ip_address" {
    type = list
    description = "Customer gateway external IP address"
}

variable "vpn_type" {
    description = "Type of VPN tunnel. Currently only supports ipsec.1"
    default     = "ipsec.1"
}

variable "static_routes_only" {
    description = "Flag to determine whether or not dynamic or static routing is enabled"
    default     = true
}
