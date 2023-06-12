variable "target_group_name" {
  type        = string
  description = "Name of the target group. If omitted, Terraform will assign a random, unique name. Forces new resource."
}

variable "target_type" {
  type        = string
  description = "Type of target that you must specify when registering targets with this target group. The possible values are `instance` (targets are specified by instance ID) or `ip` (targets are specified by IP address) or `lambda` (targets are specified by lambda arn). Note that you can't specify targets for a target group using both instance IDs and IP addresses. If the target type is `ip`, specify IP addresses from the subnets of the virtual private cloud (VPC) for the target group. You can't specify publicly routable IP addresses."
  default     = "instance"
}

variable "port" {
  type        = number
  description = "Port on which targets receive traffic, unless overridden when registering a specific target. Required when `target_type` is `instance` or `ip`. Does not apply when `target_type` is `lambda`."
}

variable "protocol" {
  type        = string
  description = "Protocol to use for routing traffic to the targets. Should be one of `GENEVE`, `HTTP`, `HTTPS`, `TCP`, `TCP_UDP`, `TLS`, or `UDP`. Required when `target_type` is instance, `ip` or `alb`. Does not apply when `target_type` is `lambda`"
}

variable "tags" {
  type        = map(string)
  description = "A mapping of tags to assign to the resource"
  default     = {}
}

variable "vpc_id" {
  type        = string
  description = "The identifier of the virtual private cloud (VPC) that the target group belongs to."
}

variable "target_group_arn" {
  type        = string
  description = "The ARN of the target group with which to register targets."
}

variable "target_id" {
  type        = string
  description = "The ID of the target. This is the Instance ID for an instance, or the container ID for an ECS container. If the target type is ip, specify an IP address"
}

variable "health_check_protocol" {
  type        = string
  description = "The protocol the load balancer uses when performing health checks on targets. The possible protocols are HTTP and HTTPS. The default is the HTTP protocol."
  default     = "HTTP"
}

variable "health_check_port" {
  type        = string
  description = "The port the load balancer uses when performing health checks on targets. The default is to use the port on which each target receives traffic from the load balancer."
  default     = "traffic-port"
}

variable "health_check_path" {
  type        = string
  description = "The destination for health checks on the targets. If the protocol version is HTTP/1.1 or HTTP/2, specify a valid URI (/path?query). The default is /. If the protocol version is gRPC, specify the path of a custom health check method with the format /package.service/method. The default is /AWS.ALB/healthcheck."
  default     = "/"
}

variable "health_check_timeout_seconds" {
  type        = number
  description = "The amount of time, in seconds, during which no response from a target means a failed health check. The range is 2–120 seconds. The default is 5 seconds if the target type is instance or ip and 30 seconds if the target type is lambda."
  default     = 5
}

variable "health_check_interval_seconds" {
  type        = number
  description = "The approximate amount of time, in seconds, between health checks of an individual target. The range is 5–300 seconds. The default is 30 seconds if the target type is instance or ip and 35 seconds if the target type is lambda."
  default     = 30
}

variable "healthy_threshold_count" {
  type        = number
  description = "The number of consecutive successful health checks required before considering an unhealthy target healthy. The range is 2–10. The default is 5."
  default     = 5
}

variable "unhealthy_threshold_count" {
  type        = number
  description = "The number of consecutive failed health checks required before considering a target unhealthy. The range is 2–10. The default is 2."
  default     = 2
}

variable "matcher" {
  type        = string
  description = "The codes to use when checking for a successful response from a target. If the protocol version is HTTP/1.1 or HTTP/2, the possible values are from 200 to 499. You can specify multiple values or a range of values. The default value is 200. If the protocol version is gRPC, the possible values are from 0 to 99. You can specify multiple values or a range of values. The default value is 12."
  default     = "200"
}

