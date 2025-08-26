# Module variables for AWS Network Diagram Generator
# - name: base prefix for named resources (role, function, etc.)
# - s3_bucket_name: reuse existing bucket; if null, module creates one
# - schedule: EventBridge cron for periodic diagram generation

variable "name" {
  description = "Base name for resources."
  type        = string
  default     = "network-diagram-generator" # Prefix for resource names
}

variable "s3_bucket_name" {
  description = "S3 bucket to store diagrams. If not set, one will be created."
  type        = string
  default     = null # If null, create a dedicated bucket with random suffix
}

variable "schedule" {
  description = "EventBridge cron schedule for Lambda (default: weekly on Sunday at 2am UTC)."
  type        = string
  default     = "cron(0 2 ? * SUN *)" # Weekly on Sunday at 02:00 UTC
}
