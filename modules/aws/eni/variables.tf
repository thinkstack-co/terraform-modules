###############################
# ENI
###############################

variable "description" {
  description = "(Required) A description for the network interface."
  type        = string
}

variable "private_ips" {
  description = "(Optional) List of private IPs to assign to the ENI."
  type        = list
  default     = []
}

variable "private_ips_count" {
  description = "(Optional) Number of secondary private IPs to assign to the ENI. The total number of private IPs will be 1 + private_ips_count, as a primary private IP will be assiged to an ENI by default."
  type        = number
  default     = 1
}

variable "private_ip_list_enabled" {
  description = "(Optional) Whether private_ip_list is allowed and controls the IPs to assign to the ENI and private_ips and private_ips_count become read-only. Default false."
  default = "false"
}

variable "security_groups" {
  description = "(Required) List of security group IDs to assign to the ENI."
  type        = list
}

variable "source_dest_check" {
  description = "(Optional) Whether to enable source destination checking for the ENI. Default true."
  type        = bool
  default     = true
}

variable "subnet_id" {
  description = "(Required) Subnet ID to create the ENI in."
  type        = string
}

variable "tags" {
  description = "(Optional) A map of tags to assign to the resource. If configured with a provider default_tags configuration block present, tags with matching keys will overwrite those defined at the provider-level."
  type        = map
}

variable "device_index" {
  description = "(Required) Integer to define the devices index."
  type        = number
}

variable "instance_id" {
  description = "(Required) ID of the instance to attach to."
  type        = string
}