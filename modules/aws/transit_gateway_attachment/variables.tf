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
  type        = list
}

variable "tags" {
  description   = "(Optional) Map of tags for the EC2 Transit Gateway."
  default       = {
    terraform   = "true"
    environment = "prod"
    project     = "core_infrastructure"
  }
  type          = map
}

variable "transit_gateway_id" {
  description = "(Required) Identifier of EC2 Transit Gateway."
  type        = string
}

variable "vpc_id" {
  description = "(Required) Identifier of the VPC."
  type        = string
}