variable "name" {
  type        = string
  description = "Name of the CloudWatch event rule"
}

variable "description" {
  type        = string
  description = "Description of the CloudWatch event rule"
}

variable "schedule_expression" {
  type        = string
  description = "Schedule expression for the event rule"
}

variable "is_enabled" {
  type        = bool
  description = "Whether the event rule is enabled"
  default     = true
}

variable "event_target_arn" {
  type        = string
  description = "ARN of the event target"
}
