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

variable "lambda_function_filter_prefix" {
  description = "Object key prefix that triggers the Lambda function"
  type        = string
  default     = ""
}

variable "lambda_function_filter_suffix" {
  description = "Object key suffix that triggers the Lambda function"
  type        = string
  default     = ""
}
