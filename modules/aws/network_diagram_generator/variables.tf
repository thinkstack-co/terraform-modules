variable "name" {
  description = "Base name for resources."
  type        = string
  default     = "network-diagram-generator"
}



variable "schedule" {
  description = "EventBridge cron schedule for Lambda (default: weekly on Sunday at 2am UTC)."
  type        = string
  default     = "cron(0 2 ? * SUN *)"
}

# Optional: If provided (and s3_bucket_name is null), the S3 bucket will be created as
# "<s3_key_prefix>-<random_suffix>". If not provided, falls back to
# "${var.name}-network-diagrams-<random_suffix>".
variable "s3_key_prefix" {
  description = "Prefix to use when auto-creating the S3 bucket name."
  type        = string
  default     = null
}

# Standard tags to apply to supported resources in this module.
variable "tags" {
  description = "Map of tags to apply to resources."
  type        = map(string)
  default     = {}
}
