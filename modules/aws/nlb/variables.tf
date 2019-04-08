variable "enable_deletion_protection" {
  type        = "string"
  description = "(Optional) If true, deletion of the load balancer will be disabled via the AWS API. This will prevent Terraform from deleting the load balancer. Defaults to false."
  default     = true
}

variable "enable_cross_zone_load_balancing" {
  type        = "string"
  description = "(Optional) If true, cross-zone load balancing of the load balancer will be enabled. This is a network load balancer feature. Defaults to false."
  default     = false
}

variable "name" {
  type        = "string"
  description = "(Optional) The name of the LB. This name must be unique within your AWS account, can have a maximum of 32 characters, must contain only alphanumeric characters or hyphens, and must not begin or end with a hyphen. If not specified, Terraform will autogenerate a name beginning with tf-lb."
}

variable "internal" {
  type        = "string"
  description = "(Optional) If true, the LB will be internal."
  default     = false
}

variable "ip_address_type" {
  type        = "string"
  description = "(Optional) The type of IP addresses used by the subnets for your load balancer. The possible values are ipv4 and dualstack"
  default     = ""
}

variable "load_balancer_type" {
  type        = "string"
  description = "(Optional) The type of load balancer to create. Possible values are application or network. The default value is application."
  default     = "network"
}

variable "subnets" {
  type        = "list"
  description = "(Optional) A list of subnet IDs to attach to the LB. Subnets cannot be updated for Load Balancers of type network. Changing this value for load balancers of type network will force a recreation of the resource."
}

variable "tags" {
  type        = "map"
  description = "(Optional) A mapping of tags to assign to the resource."
  default     = {}
}
