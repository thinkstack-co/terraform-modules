variable "appliance_mdoe_support" {
  description = "(Optional) Whether Appliance Mode support is enabled. If enabled, a traffic flow between a source and destination uses the same Availability Zone for the VPC attachment for the lifetime of that flow."
  default = "disable"
}

variable "description" {
  description = "(Optional) Description of the EC2 Transit Gateway Attachment."
  default     = "Transit gateway attachment to allow access across VPCs or accounts."
}

variable "dns_support" {
  description = "(Optional) Whether DNS support is enabled."
  default = "enable"
}

variable "ipv6_support" {
  description = "(Optional) Whether IPv6 support is enabled."
  default = "disable"
}

variable "subnet_ids" {
  description = "(Required) Identifiers of EC2 Subnets."
  type = list
}

variable "tags" {
  description = "(Optional) Map of tags for the EC2 Transit Gateway."
  default     = {
    terraform   = "true"
    environment = "prod"
    project     = "core_infrastructure"
  }
}

variable "transit_gateway_default_route_table_association" {
  description = "(Optional) Boolean whether the VPC Attachment should be associated with the EC2 Transit Gateway association default route table. This cannot be configured or perform drift detection with Resource Access Manager shared EC2 Transit Gateways."
  type = bool
  default = true
}

variable "transit_gateway_default_route_table_propagation" {
  description = "(Optional) Boolean whether the VPC Attachment should be associated with the EC2 Transit Gateway association default route table. This cannot be configured or perform drift detection with Resource Access Manager shared EC2 Transit Gateways."
  type = bool
  default = true
}

variable "transit_gateway_id" {
  description = "(Optional) Boolean whether the VPC Attachment should propagate routes with the EC2 Transit Gateway propagation default route table. This cannot be configured or perform drift detection with Resource Access Manager shared EC2 Transit Gateways."
}

variable "vpc_id" {
  description = "(Required) Identifier of EC2 VPC."
}