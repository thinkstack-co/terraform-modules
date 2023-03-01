variable "health_check_interval" {
  description = "The approximate amount of time between health checks of an individual target"
  type        = number
  default     = 30
}

variable "health_check_matcher" {
  description = "The HTTP codes to use when checking for a successful response from a target"
  type        = list(number)
  default     = [200, 204, 301, 302]
}

variable "health_check_path" {
  description = "The ping path that is the destination on the targets for health checks"
  type        = string
  default     = "/"
}

variable "health_check_port" {
  description = "The port number to use to connect with the target for health checks"
  type        = number
  default     = 80
}

variable "health_check_protocol" {
  description = "The protocol to use for health checks"
  type        = string
  default     = "HTTP"
}

variable "health_check_threshold" {
  description = "The number of consecutive health checks that must succeed before considering an unhealthy target healthy"
  type        = number
  default     = 2
}

variable "health_check_timeout" {
  description = "The amount of time, in seconds, during which no response means a failed health check"
  type        = number
  default     = 5
}

variable "name" {
  description = "The name of the target group"
  type        = string
}

variable "port" {
  description = "The port number on which the targets receive traffic"
  type        = number
}

variable "protocol" {
  description = "The protocol to use for routing traffic to the targets"
  type        = string
}

variable "stickiness_cookie_duration" {
  description = "The time period during which requests from a client should be routed to the same target"
  type        = number
  default     = 86400
}

variable "stickiness_enabled" {
  description = "Whether to enable sticky sessions for the target group"
  type        = bool
  default     = false
}

variable "stickiness_type" {
  description = "The type of sticky session to enable for the target group"
  type        = string
  default     = "lb_cookie"
}

variable "target_type" {
  description = "The type of targets that can be registered with this target group"
  type        = string
  default     = "instance"
}

variable "tags" {
  description = "A mapping of tags to assign to the target group"
  type        = map(string)
  default     = {}
}

variable "vpc_id" {
  description = "The identifier of the VPC in which to create the target group"
  type        = string
}
