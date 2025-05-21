/*
variable "name" {
  description = "Base name for resources."
  type        = string
  default     = "network-diagram-generator"
}

variable "s3_bucket_name" {
  description = "S3 bucket to store diagrams. If not set, one will be created."
  type        = string
  default     = null
}

variable "schedule" {
  description = "EventBridge cron schedule for Lambda (default: weekly on Sunday at 2am UTC)."
  type        = string
  default     = "cron(0 2 ? * SUN *)"
}
*/
