variable "delay_seconds" {
  type        = string
  description = "(Optional) The time in seconds that the delivery of all messages in the queue will be delayed. An integer from 0 to 900 (15 minutes). The default for this attribute is 0 seconds."
  default     = 0
}

variable "fifo_queue" {
  description = "(Optional) Boolean designating a FIFO queue. If not set, it defaults to false making it standard."
  default     = false
}

variable "message_retention_seconds" {
  description = "(Optional) The number of seconds Amazon SQS retains a message. Integer representing seconds, from 60 (1 minute) to 1209600 (14 days). The default for this attribute is 345600 (4 days)."
  default     = 345600
}

variable "name" {
  type        = string
  description = "(Optional) This is the human-readable name of the queue. If omitted, Terraform will assign a random name."
}

variable "tags" {
  description = "(Optional) A mapping of tags to assign to the queue."
  default     = {}
}

variable "visibility_timeout_seconds" {
  type        = string
  description = "(Optional) The visibility timeout for the queue. An integer from 0 to 43200 (12 hours). The default for this attribute is 30. For more information about visibility timeout, see AWS docs."
  default     = 30
}
