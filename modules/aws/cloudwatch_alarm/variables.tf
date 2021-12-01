variable "actions_enabled" {
  type        = string
  description = "(Optional) Indicates whether or not actions should be executed during any changes to the alarm's state. Defaults to true."
  default     = true
}

variable "alarm_actions" {
  type        = string
  description = "(Optional) The list of actions to execute when this alarm transitions into an ALARM state from any other state. Each action is specified as an Amazon Resource Number (ARN)."
}

variable "alarm_description" {
  type        = string
  description = "(Optional) The description for the alarm."
}

variable "alarm_name" {
  type        = string
  description = "(Required) The descriptive name for the alarm. This name must be unique within the user's AWS account"
}

variable "comparison_operator" {
  type        = string
  description = "(Required) The arithmetic operation to use when comparing the specified Statistic and Threshold. The specified Statistic value is used as the first operand. Either of the following is supported: GreaterThanOrEqualToThreshold, GreaterThanThreshold, LessThanThreshold, LessThanOrEqualToThreshold."
}

variable "datapoints_to_alarm" {
  type        = string
  description = "(Optional) The number of datapoints that must be breaching to trigger the alarm."
}

variable "dimensions" {
  type        = map
  description = "(Optional) The dimensions for the alarm's associated metric. For the list of available dimensions see the AWS documentation"
}

variable "evaluation_periods" {
  type        = string
  description = "(Required) The number of periods over which data is compared to the specified threshold."
}

variable "insufficient_data_actions" {
  type        = string
  description = "(Optional) The list of actions to execute when this alarm transitions into an INSUFFICIENT_DATA state from any other state. Each action is specified as an Amazon Resource Number (ARN)."
}

variable "metric_name" {
  type        = string
  description = "(Required) The name for the alarm's associated metric. See docs for supported metrics."
}

variable "namespace" {
  type        = string
  description = "(Required) The namespace for the alarm's associated metric. See docs for the list of namespaces. See docs for supported metrics."
}

variable "ok_actions" {
  type        = string
  description = "(Optional) The list of actions to execute when this alarm transitions into an OK state from any other state. Each action is specified as an Amazon Resource Number (ARN)."
}

variable "period" {
  type        = string
  description = "(Required) The period in seconds over which the specified statistic is applied."
}

variable "statistic" {
  type        = string
  description = "(Optional) The statistic to apply to the alarm's associated metric. Either of the following is supported: SampleCount, Average, Sum, Minimum, Maximum"
}

variable "threshold" {
  type        = string
  description = "(Required) The value against which the specified statistic is compared."
  default     = 1.0
}

variable "treat_missing_data" {
  type        = string
  description = "(Optional) Sets how this alarm is to handle missing data points. The following values are supported: missing, ignore, breaching and notBreaching. Defaults to missing."
}

variable "unit" {
  type        = string
  description = "(Optional) The unit for the alarm's associated metric."
}
