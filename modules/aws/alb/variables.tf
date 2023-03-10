variable "access_logs_bucket" {
  type        = string
  description = "(Required) The S3 bucket name to store the logs in."
}

variable "access_logs_enabled" {
  type        = bool
  description = "(Optional) Boolean to enable / disable access_logs. Defaults to false, even when bucket is specified."
  default     = true
  validation {
    condition     = can(regex("^true|false$", var.access_logs_enabled))
    error_message = "The value of access_logs_enabled must be true or false."
  }
}

variable "access_logs_prefix" {
  type        = string
  description = "(Optional) The S3 bucket prefix. Logs are stored in the root if not configured."
  default     = "alb-log"
}

variable "drop_invalid_header_fields" {
  type        = bool
  description = "(Optional) Indicates whether HTTP headers with header fields that are not valid are removed by the load balancer (true) or routed to targets (false). The default is false. Elastic Load Balancing requires that message header names contain only alphanumeric characters and hyphens. Only valid for Load Balancers of type application."
  default     = true
  validation {
    condition     = can(regex("^true|false$", var.drop_invalid_header_fields))
    error_message = "The value of drop_invalid_header_fields must be true or false."
  }
}

variable "enable_cross_zone_load_balancing" {
  type        = bool
  description = "(Optional) If true, cross-zone load balancing of the load balancer will be enabled. This is a network load balancer feature. Defaults to false."
  default     = false
  validation {
    condition     = can(regex("^true|false$", var.enable_cross_zone_load_balancing))
    error_message = "The value of enable_cross_zone_load_balancing must be true or false."
  }
}

variable "enable_deletion_protection" {
  type        = bool
  description = "(Optional) If true, deletion of the load balancer will be disabled via the AWS API. This will prevent Terraform from deleting the load balancer. Defaults to false."
  default     = false
  validation {
    condition     = can(regex("^true|false$", var.enable_deletion_protection))
    error_message = "The value of enable_deletion_protection must be true or false."
  }
}

variable "enable_http2" {
  type        = bool
  description = "(Optional) Indicates whether HTTP/2 is enabled in application load balancers. Defaults to true."
  default     = true
  validation {
    condition     = can(regex("^true|false$", var.enable_http2))
    error_message = "The value of enable_http2 must be true or false."
  }
}

variable "idle_timeout" {
  type        = number
  description = "(Optional) The time in seconds that the connection is allowed to be idle. Only valid for Load Balancers of type application. Default: 60."
  default     = 60
  validation {
    condition     = can(regex("^([1-9][0-9]*)$", var.idle_timeout))
    error_message = "The value of idle_timeout must be a number."
  }
}

variable "internal" {
  type        = bool
  description = "(Optional) If true, the LB will be internal."
  default     = false
  validation {
    condition     = can(regex("^true|false$", var.internal))
    error_message = "The value of internal must be true or false."
  }
}

variable "ip_address_type" {
  type        = string
  description = "(Optional) The type of IP addresses used by the subnets for your load balancer. The possible values are ipv4 and dualstack"
  default     = "ipv4"
}

variable "load_balancer_type" {
  type        = string
  description = "(Optional) The type of load balancer to create. Possible values are application, gateway, or network. The default value is application."
  default     = "application"
  validation {
    condition     = can(regex("^application|gateway|network$", var.load_balancer_type))
    error_message = "The value of load_balancer_type must be application, gateway, or network."
  }
}

variable "name" {
  type        = string
  description = "(Required) The name of the LB. This name must be unique within your AWS account, can have a maximum of 32 characters, must contain only alphanumeric characters or hyphens, and must not begin or end with a hyphen. If not specified, Terraform will autogenerate a name beginning with tf-lb."
}

variable "number" {
  type        = number
  description = "(Optional) the number of resources to create"
  default     = 1
  validation {
    condition     = can(regex("^([1-9][0-9]*)$", var.number))
    error_message = "The value of number must be a positive integer."
  }
}

variable "security_groups" {
  type        = list(string)
  description = "(Required) A list of security group IDs to assign to the LB. Only valid for Load Balancers of type application."
}

variable "subnets" {
  type        = list(string)
  description = "(Optional) A list of subnet IDs to attach to the LB. Subnets cannot be updated for Load Balancers of type network. Changing this value for load balancers of type network will force a recreation of the resource."
}
