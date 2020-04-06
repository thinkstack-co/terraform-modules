variable "access_logs_bucket" {
  type        = string
  description = "(Required) The S3 bucket name to store the logs in."
}

variable "access_logs_enabled" {
  type        = string
  description = "(Optional) Boolean to enable / disable access_logs. Defaults to false, even when bucket is specified."
  default     = true
}

variable "access_logs_prefix" {
  type        = string
  description = "(Optional) The S3 bucket prefix. Logs are stored in the root if not configured."
  default     = "alb-log"
}

variable "enable_cross_zone_load_balancing" {
  type        = string
  description = "(Optional) If true, cross-zone load balancing of the load balancer will be enabled. This is a network load balancer feature. Defaults to false."
  default     = false
}

variable "enable_deletion_protection" {
  type        = string
  description = "(Optional) If true, deletion of the load balancer will be disabled via the AWS API. This will prevent Terraform from deleting the load balancer. Defaults to false."
  default     = false
}

variable "enable_http2" {
  type        = string
  description = "(Optional) Indicates whether HTTP/2 is enabled in application load balancers. Defaults to true."
  default     = true
}

variable "idle_timeout" {
  type        = string
  description = "(Optional) The time in seconds that the connection is allowed to be idle. Only valid for Load Balancers of type application. Default: 60."
  default     = 60
}

variable "internal" {
  type        = string
  description = "(Optional) If true, the LB will be internal."
  default     = false
}

variable "ip_address_type" {
  type        = string
  description = "(Optional) The type of IP addresses used by the subnets for your load balancer. The possible values are ipv4 and dualstack"
  default     = "ipv4"
}

variable "load_balancer_type" {
  type        = string
  description = "(Optional) The type of load balancer to create. Possible values are application or network. The default value is application."
  default     = application
}

variable "name" {
  type        = string
  description = "(Required) The name of the LB. This name must be unique within your AWS account, can have a maximum of 32 characters, must contain only alphanumeric characters or hyphens, and must not begin or end with a hyphen. If not specified, Terraform will autogenerate a name beginning with tf-lb."
}

variable "number" {
  type        = string
  description = "(Optional) the number of resources to create"
  default     = 1
}

variable "security_groups" {
  type        = list(string)
  description = "(Required) A list of security group IDs to assign to the LB. Only valid for Load Balancers of type application."
}

variable "subnets" {
  type        = list(string)
  description = "(Optional) A list of subnet IDs to attach to the LB. Subnets cannot be updated for Load Balancers of type network. Changing this value for load balancers of type network will force a recreation of the resource."
}
