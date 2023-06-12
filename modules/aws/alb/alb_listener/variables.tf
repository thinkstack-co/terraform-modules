variable "port" {
  type        = number
  description = "(Optional) Port on which the load balancer is listening. Not valid for Gateway Load Balancers."
  default     = 80
}

variable "protocol" {
  type        = string
  description = "(Optional) The protocol for connections from clients to the load balancer. Valid values are `TCP`, `HTTP`, and `HTTPS`. Defaults to `HTTP`."
  default     = "HTTP"
}

variable "ssl_certificate" {
  type        = string
  description = "(Optional) The ARN of the default SSL server certificate. Exactly one certificate is required if the protocol is HTTPS. For adding additional SSL certificates, see the `aws_lb_listener_certificate` resource."
}

variable "load_balancer_arn" {
  type        = string
  description = "(Required) The ARN of the Target Group to which to route traffic."
}

variable "type" {
  type        = string
  description = "(Required) Type of routing action. Valid values are forward, redirect, fixed-response, authenticate-cognito and authenticate-oidc."
  default     = "forward"
}

variable "target_groups" {
  description = "List of target groups"
  type        = list(object({
    arn    = string
    weight = number
  }))
}

variable "ssl_policy" {
  type        = string
  description = "(Optional) The name of the SSL Policy for the listener. Required if `protocol` is `HTTPS`."
}

variable "stickiness_enabled" {
  type        = bool
  description = "(Optional) Whether target group stickiness is enabled. Default is false."
  default = false
}

variable "stickiness_duration" {
  type        = number
  description = "(Required) Time period, in seconds, during which requests from a client should be routed to the same target group. The range is 1-604800 seconds (7 days)."
  default = 6000

    validation {
    condition     = var.stickiness_enabled == true
    error_message = "Stickiness duration is only required if stickiness_enabled is set to \"true\"."
  }
}

