# Variables for AWS Config Module

variable "config_recorder_name" {
  description = "Name of the AWS Config recorder"
  type        = string
  default     = "aws_config_recorder"
}

variable "config_bucket_prefix" {
  description = "Name of the S3 bucket for AWS Config recordings"
  type        = string
  default = "aws-config-recordings-"
}

variable "config_iam_role_name" {
  description = "Name of the IAM role for AWS Config"
  type        = string
  default     = "aws-config-role"
}

variable "include_global_resource_types" {
  description = "Specifies whether AWS Config includes all supported types of global resources with the resources that it records"
  type        = bool
  default     = true
}

variable "tags" {
  description = "A map of tags to add to all resources"
  type        = map(string)
  default     = {}
}

# Password Policy Variables
variable "password_min_length" {
  description = "Minimum length for IAM user passwords"
  type        = number
  default     = 16
}

variable "password_reuse_prevention" {
  description = "Number of previous passwords that users are prevented from reusing"
  type        = number
  default     = 24
}

variable "password_max_age" {
  description = "Maximum age in days before password must be changed"
  type        = number
  default     = 45
}

variable "enable_config_rules" {
  description = "Enable or disable AWS Config Rules"
  type        = bool
  default     = true
}

variable "recording_frequency" {
  description = "The frequency with which AWS Config records information"
  type        = string
  default     = "DAILY"
}

variable "s3_key_prefix" {
  description = "The prefix for the S3 bucket where AWS Config delivers configuration snapshots and history files"
  type        = string
  default     = "config"
}

variable "sns_topic_arn" {
  description = "The ARN of the SNS topic that AWS Config delivers notifications to"
  type        = string
  default     = null
}

variable "snapshot_delivery_frequency" {
  description = "The frequency with which AWS Config delivers configuration snapshots (One_Hour, Three_Hours, Six_Hours, Twelve_Hours, TwentyFour_Hours)"
  type        = string
  default     = "TwentyFour_Hours"
}

variable "notification_email" {
  description = "Email address to receive compliance notifications"
  type        = string
  default     = "support@thinkstack.co"
}

variable "create_compliance_report" {
  description = "Whether to create a compliance report sent via email based on the report_frequency setting"
  type        = bool
  default     = true
}

variable "customer_name" {
  description = "Name of the customer whose AWS account this is being deployed in, used to identify the source of compliance reports"
  type        = string
  default     = ""
}

# Report Delivery Configuration
variable "report_delivery_schedule" {
  description = "Cron expression for when to deliver the config report (default is 8:00 AM on the 1st day of every month)"
  type        = string
  default     = "cron(0 8 1 * ? *)"
}

variable "report_frequency" {
  description = "Frequency of config report generation (daily, weekly, or monthly)"
  type        = string
  default     = "monthly"
  validation {
    condition     = contains(["daily", "weekly", "monthly"], var.report_frequency)
    error_message = "The report_frequency must be one of: daily, weekly, or monthly."
  }
}

# S3 Lifecycle Configuration
variable "enable_s3_lifecycle_rules" {
  description = "Whether to enable S3 lifecycle rules for config reports"
  type        = bool
  default     = false
}

variable "report_retention_days" {
  description = "Number of days to retain config reports in S3 before deletion (set to 0 to disable deletion)"
  type        = number
  default     = 365
}

variable "enable_glacier_transition" {
  description = "Whether to transition config reports to Glacier storage class"
  type        = bool
  default     = false
}

variable "glacier_transition_days" {
  description = "Number of days after which to transition config reports to Glacier storage class"
  type        = number
  default     = 90
}

variable "glacier_retention_days" {
  description = "Number of days to retain config reports in Glacier before deletion (set to 0 to disable deletion from Glacier)"
  type        = number
  default     = 730
}

variable "enable_config_processor" {
  description = "Enable the Lambda function that processes Config snapshots into readable formats"
  type        = bool
  default     = false
}

variable "config_processor_generate_summary" {
  description = "Whether the Config processor Lambda should generate summary files in addition to formatted files"
  type        = bool
  default     = true
}
