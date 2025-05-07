# Variables for AWS Cost Report Module

variable "bucket_prefix" {
  description = "Prefix for the S3 bucket to store PDF cost reports. A unique suffix will be appended."
  type        = string
  default     = "aws-cost-report-"
}

variable "customer_name" {
  description = "Optional: Customer name or label for tagging and Lambda environment. If empty, uses AWS Account ID."
  type        = string
  default     = ""
}

variable "enable_s3_lifecycle_rules" {
  description = "Whether to enable S3 lifecycle rules for cost report PDFs."
  type        = bool
  default     = false
}

variable "report_retention_days" {
  description = "Number of days to retain cost report PDFs in S3 before deletion (set to 0 to disable deletion)."
  type        = number
  default     = 365

  validation {
    condition     = var.report_retention_days >= 0
    error_message = "report_retention_days must be 0 (to disable) or a positive integer."
  }
}

variable "enable_glacier_transition" {
  description = "Whether to transition cost report PDFs to Glacier storage class."
  type        = bool
  default     = false
}

variable "glacier_transition_days" {
  description = "Number of days after which to transition cost report PDFs to Glacier storage class."
  type        = number
  default     = 90
}

variable "glacier_retention_days" {
  description = "Number of days to retain cost report PDFs in Glacier before deletion (set to 0 to disable deletion from Glacier)."
  type        = number
  default     = 730
}


variable "report_tag_key" {
  description = "Cost allocation tag key to group resources by."
  type        = string
  default     = "Name"
}

variable "schedule_expression" {
  description = "Cron expression for running the cost report Lambda. Default: Monthly on the 1st at 6 AM UTC."
  type        = string
  default     = "cron(0 6 1 * ? *)"
}

variable "lambda_memory_size" {
  description = "Memory size (MB) for the Lambda function."
  type        = number
  default     = 256
}

variable "lambda_timeout" {
  description = "Timeout (seconds) for the Lambda function."
  type        = number
  default     = 180
}

variable "tags" {
  description = "A map of tags to apply to all resources."
  type        = map(string)
  default     = {}
}
