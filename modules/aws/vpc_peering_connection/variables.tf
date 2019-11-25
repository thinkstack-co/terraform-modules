variable "allow_remote_vpc_dns_resolution" {
  type        = string
  description = "(Optional) Allow a local VPC to resolve public DNS hostnames to private IP addresses when queried from instances in the peer VPC. This is not supported for inter-region VPC peering."
  default     = ""
}

variable "auto_accept" {
  type        = string
  description = "(Optional) Accept the peering (both VPCs need to be in the same AWS account)."
  default     = true
}

variable "peer_owner_id" {
  type        = string
  description = "(Optional) The AWS account ID of the owner of the peer VPC. Defaults to the account ID the AWS provider is currently connected to."
  default     = ""
}

variable "peer_region" {
  type        = string
  description = "(Optional) The region of the accepter VPC of the [VPC Peering Connection]. auto_accept must be false, and use the aws_vpc_peering_connection_accepter to manage the accepter side."
  default     = ""
}

variable "peer_vpc_id" {
  type        = string
  description = "(Required) The ID of the VPC with which you are creating the VPC Peering Connection."
}

variable "tags" {
  type        = map
  description = "(Optional) A mapping of tags to assign to the resource."
}

variable "vpc_id" {
  type        = string
  description = "(Required) The ID of the requester VPC."
}
