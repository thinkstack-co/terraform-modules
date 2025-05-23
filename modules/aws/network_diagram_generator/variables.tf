variable "name" {
  description = "Base name for resources"
  type        = string
  default     = "network-diagram-generator"
}

variable "s3_bucket_prefix" {
  description = "Prefix for the S3 bucket name to store diagrams. A unique suffix will be appended."
  type        = string
  default     = "network-diagrams"
}

variable "schedule" {
  description = "EventBridge cron schedule for Lambda execution"
  type        = string
  default     = "cron(0 2 ? * SUN *)"  # Weekly on Sunday at 2 AM
}

variable "tags" {
  description = "Tags to apply to all resources"
  type        = map(string)
  default     = {}
}

variable "s3_bucket_name" {
  description = "Optional existing S3 bucket name to use instead of creating a new one"
  type        = string
  default     = null
}
