variable "blackhole" {
  description = "(Optional) Indicates whether to drop traffic that matches this route (default to false)."
  default     = false
  type        = bool
}

variable "destination_cidr_block" {
  description = "(Required) IPv4 or IPv6 RFC1924 CIDR used for destination matches. Routing decisions are based on the most specific match."
  type        = string
}

variable "transit_gateway_attachment_id" {
  description = "(Optional) Identifier of EC2 Transit Gateway Attachment (required if blackhole is set to false)."
  default     = null
  type        = string
}

variable "transit_gateway_route_table_id" {
  description = "(Required) Identifier of EC2 Transit Gateway Route Table."
  type        = string
}