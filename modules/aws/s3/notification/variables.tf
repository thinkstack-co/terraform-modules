variable "enable_s3_bucket_notification" {
  description = "Whether to enable S3 bucket notification"
  type        = bool
  default     = true
}

variable "lambda_function_arn" {
  description = "ARN of the Lambda function to trigger on S3 events"
  type        = string
}

variable "lambda_function_events" {
  description = "List of S3 events that trigger the Lambda function"
  type        = list(string)
  default     = ["s3:ObjectCreated:*"]
}

variable "s3_bucket_id" {
  description = "ID (name) of the target S3 bucket to configure notifications on"
  type        = string
}

variable "s3_bucket_arn" {
  description = "ARN of the target S3 bucket used in Lambda permission source_arn"
  type        = string
}

variable "lambda_function_filter_prefix" {
  description = "Object key prefix that triggers the Lambda function"
  type        = string
  default     = null
}

variable "lambda_function_filter_suffix" {
  description = "Object key suffix that triggers the Lambda function"
  type        = string
  default     = null
}

variable "lambda_permission_statement_id" {
  description = "Statement ID to use for the Lambda permission allowing S3 invocation"
  type        = string
  default     = "AllowExecutionFromS3"
}
