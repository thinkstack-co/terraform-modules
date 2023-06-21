variable "load_balancer_arn" {
  type        = string
  description = "(Required) The ARN of the Target Group to which to route traffic."
}

variable "port" {
  type        = number
  description = "(Optional) Port on which the load balancer is listening. Not valid for Gateway Load Balancers."
  default     = 80
}

variable "protocol" {
  type        = string
  description = "For Network Load Balancers, valid values are TCP, TLS, UDP, and TCP_UDP. Not valid to use UDP or TCP_UDP if dual-stack mode is enabled."
  default     = "TCP"
}

variable "target_groups" {
  description = "List of target groups"
  type = list(object({
    arn    = string
    weight = number
  }))
}

variable "tags" {
  type        = map(string)
  description = "A mapping of tags to assign to the resource"
  default     = {}
}

variable "action_type" {
  type        = string
  description = "(Required) Type of routing action. Valid values are forward, redirect, fixed-response, authenticate-cognito and authenticate-oidc."
  default     = "forward"
}

variable "target_group_arn" {
  type        = string
  description = "(Optional) The ARN of the Target Group to which to route traffic. Specify only if type is forward and you want to route to a single target group. To route to one or more target groups, use a forward block instead."
  default     = null
}
