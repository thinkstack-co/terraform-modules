variable "name" {
  description = "Name of the cloudwatch event"
}

variable "description" {
  description = "Description of the cloudwatch event"
}

variable "schedule_expression" {
  description = "cron expression of time or rate expression of time"
}

variable "is_enabled" {
  description = "Whether or not the event rule is enabled"
  default     = "true"
}

variable "event_target_arn" {
  description = "arn of the target to invoke with this event"
}
