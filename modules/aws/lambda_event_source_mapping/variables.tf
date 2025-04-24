variable "batch_size" {
  type        = string
  description = "(Optional) The largest number of records that Lambda will retrieve from your event source at the time of invocation. Defaults to 100 for DynamoDB and Kinesis, 10 for SQS."
  default     = 10
}

variable "enabled" {
  type        = string
  description = "(Optional) Determines if the mapping will be enabled on creation. Defaults to true."
  default     = true
}

variable "event_source_arn" {
  type        = string
  description = "(Required) The event source ARN - can either be a Kinesis, DynamoDB stream, or SQS queue."
}

variable "function_name" {
  type        = string
  description = "(Required) The name or the ARN of the Lambda function that will be subscribing to events."
}
