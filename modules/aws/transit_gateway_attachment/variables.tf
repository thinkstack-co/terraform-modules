variable "appliance_mode_support" {
  description = "(Optional) Whether Appliance Mode support is enabled. If enabled, a traffic flow between a source and destination uses the same Availability Zone for the VPC attachment for the lifetime of that flow."
  default     = "disable"
  type        = string
}

variable "dns_support" {
  description = "(Optional) Whether DNS support is enabled. Valid values: disable, enable. Default value: enable."
  default     = "enable"
  type        = string
}

variable "ipv6_support" {
  description = "(Optional) Whether IPv6 support is enabled. Valid values: disable, enable. Default value: disable."
  default     = "disable"
  type        = string
}

variable "name" {
  description = "(Required) The name of the transit gateway attachment"
  type        = string
}

variable "subnet_ids" {
  description = "(Required) Identifiers of EC2 Subnets."
  type        = list(any)
}

variable "tags" {
  description = "(Optional) Map of tags for the EC2 Transit Gateway."
  default = {
    terraform   = "true"
    environment = "prod"
    project     = "core_infrastructure"
  }
  type = map(any)
}

variable "transit_gateway_id" {
  description = "(Required) Identifier of EC2 Transit Gateway."
  type        = string
}

variable "transit_gateway_default_route_table_association" {
  type        = bool
  description = "(Optional) Boolean whether the VPC Attachment should be associated with the EC2 Transit Gateway association default route table. This cannot be configured or perform drift detection with Resource Access Manager shared EC2 Transit Gateways. Default value: true."
  default     = true
}

variable "transit_gateway_default_route_table_propagation" {
  type        = bool
  description = "(Optional) Boolean whether the VPC Attachment should propagate routes with the EC2 Transit Gateway propagation default route table. This cannot be configured or perform drift detection with Resource Access Manager shared EC2 Transit Gateways. Default value: true."
  default     = true
}

variable "vpc_id" {
  description = "(Required) Identifier of the VPC."
  type        = string
}