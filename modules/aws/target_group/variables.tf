variable "health_check_interval" {
  description = "(Optional) Approximate amount of time, in seconds, between health checks of an individual target. The range is 5-300. For lambda target groups, it needs to be greater than the timeout of the underlying lambda. Defaults to 30."
  type        = number
  default     = 30
}

variable "health_check_matcher" {
  description = " (May be required) Response codes to use when checking for a healthy responses from a target. You can specify multiple values (for example, 200,202 for HTTP(s) or 0,12 for GRPC) or a range of values (for example, 200-299 or 0-99). Required for HTTP/HTTPS/GRPC ALB. Only applies to Application Load Balancers (i.e., HTTP/HTTPS/GRPC) not Network Load Balancers (i.e., TCP)."
  type        = list(number)
  default     = [200, 204, 301, 302]
}

variable "health_check_path" {
  description = "(May be required) Destination for the health check request. Required for HTTP/HTTPS ALB and HTTP NLB. Only applies to HTTP/HTTPS."
  type        = string
  default     = "/"
}

variable "health_check_port" {
  description = "(Optional) The port the load balancer uses when performing health checks on targets. Default is traffic-port."
  type        = number
  default     = 80
}

variable "health_check_protocol" {
  description = "(Optional) Protocol the load balancer uses when performing health checks on targets. Must be either TCP, HTTP, or HTTPS. The TCP protocol is not supported for health checks if the protocol of the target group is HTTP or HTTPS. Defaults to HTTP."
  type        = string
  default     = "HTTP"
}

variable "health_check_threshold" {
  description = "(Optional) Number of consecutive health check successes required before considering a target healthy. The range is 2-10. Defaults to 3."
  type        = number
  default     = 3
}

variable "health_check_timeout" {
  description = "(optional) Amount of time, in seconds, during which no response from a target means a failed health check. The range is 2–120 seconds. For target groups with a protocol of HTTP, the default is 6 seconds. For target groups with a protocol of TCP, TLS or HTTPS, the default is 10 seconds. For target groups with a protocol of GENEVE, the default is 5 seconds. If the target type is lambda, the default is 30 seconds."
  type        = number
  default     = 30
}

variable "name" {
  description = "(Optional, Forces new resource) Name of the target group. If omitted, Terraform will assign a random, unique name."
  type        = string
}

variable "port" {
  description = "(May be required, Forces new resource) Port on which targets receive traffic, unless overridden when registering a specific target. Required when target_type is instance, ip or alb. Does not apply when target_type is lambda."
  type        = number
}

variable "protocol" {
  description = "(May be required, Forces new resource) Protocol to use for routing traffic to the targets. Should be one of GENEVE, HTTP, HTTPS, TCP, TCP_UDP, TLS, or UDP. Required when target_type is instance, ip or alb. Does not apply when target_type is lambda."
  type        = string
}

variable "stickiness_cookie_duration" {
  description = "(Optional) Only used when the type is lb_cookie. The time period, in seconds, during which requests from a client should be routed to the same target. After this time period expires, the load balancer-generated cookie is considered stale. The range is 1 second to 1 week (604800 seconds). The default value is 1 day (86400 seconds)."
  type        = number
  default     = 86400
}

variable "stickiness_enabled" {
  description = "(Optional) Boolean to enable / disable stickiness. Default is true."
  type        = bool
  default     = true
}

variable "stickiness_type" {
  description = "(Required) The type of sticky sessions. The only current possible values are lb_cookie, app_cookie for ALBs, source_ip for NLBs, and source_ip_dest_ip, source_ip_dest_ip_proto for GWLBs."
  type        = string
  default     = "lb_cookie"
}

variable "target_type" {
  description = "(May be required, Forces new resource) Type of target that you must specify when registering targets with this target group. See doc for supported values. The default is instance."
  type        = string
  default     = "instance"
}

variable "tags" {
  description = "(Optional) Map of tags to assign to the resource. If configured with a provider default_tags configuration block present, tags with matching keys will overwrite those defined at the provider-level."
  type        = map(string)
  default     = {}
}

variable "vpc_id" {
  description = "(Optional, Forces new resource) Identifier of the VPC in which to create the target group. Required when target_type is instance, ip or alb. Does not apply when target_type is lambda."
  type        = string
}
