variable "name" {
  description = "(Required) The name of the transit gateway"
  type        = string
}

variable "protocol" {
  type        = string
  description = "(Optional) The tunnel protocol. Valida values: gre. Default is gre."
  default     = "gre"
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

variable "transit_gateway_default_route_table_association" {
  type        = bool
  description = "(Optional) Boolean whether the Connect should be associated with the EC2 Transit Gateway association default route table. This cannot be configured or perform drift detection with Resource Access Manager shared EC2 Transit Gateways. Default value: true."
  default     = true
}

variable "transit_gateway_default_route_table_propagation" {
  type        = bool
  description = "(Optional) Boolean whether the Connect should propagate routes with the EC2 Transit Gateway propagation default route table. This cannot be configured or perform drift detection with Resource Access Manager shared EC2 Transit Gateways. Default value: true."
  default     = true
}

variable "transport_attachment_id" {
  type        = string
  description = "(Required) The underlaying VPC attachment"
}

variable "transit_gateway_id" {
  type        = string
  description = "(Required) Identifier of EC2 Transit Gateway."
}
