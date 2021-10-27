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

variable "starting_position" {
  description = "Optional) The position in the stream where AWS Lambda should start reading. Must be one of AT_TIMESTAMP (Kinesis only), LATEST or TRIM_HORIZON if getting events from Kinesis or DynamoDB. Must not be provided if getting events from SQS. More information about these positions can be found in the AWS DynamoDB Streams API Reference and AWS Kinesis API Reference."
  default     = ""
}

variable "starting_position_timestamp" {
  description = "(Optional) A timestamp in RFC3339 format of the data record which to start reading when using starting_position set to AT_TIMESTAMP. If a record with this exact timestamp does not exist, the next later record is chosen. If the timestamp is older than the current trim horizon, the oldest available record is chosen."
  default     = ""
}
