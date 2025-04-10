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
  description = "The prefix for the S3 bucket where AWS Config delivers configuration snapshots and history files. AWS Config will append its standard structure under this prefix (AWSLogs/[account_id]/Config/[region]/YYYY/M/D)."
  type        = string
  default     = "config"
}

variable "snapshot_delivery_frequency" {
  description = "The frequency with which AWS Config delivers configuration snapshots (One_Hour, Three_Hours, Six_Hours, Twelve_Hours, TwentyFour_Hours)"
  type        = string
  default     = "TwentyFour_Hours"
}

variable "customer_name" {
  description = "Name of the customer whose AWS account this is being deployed in, used to identify the source of compliance reports"
  type        = string
  default     = ""
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

# Variable to control the Encrypted Volumes rule (was missing)
variable "enable_encrypted_volumes_rule" {
  description = "Enable the Encrypted Volumes managed rule."
  type        = bool
  default     = true
}

variable "enable_iam_password_policy_rule" {
  description = "Enable the IAM Password Policy managed rule."
  type        = bool
  default     = true
}

variable "enable_s3_public_access_rules" {
  description = "Enable S3_BUCKET_PUBLIC_READ_PROHIBITED and S3_BUCKET_PUBLIC_WRITE_PROHIBITED managed rules."
  type        = bool
  default     = true
}

variable "enable_iam_root_key_rule" {
  description = "Enable the ROOT_ACCOUNT_MFA_ENABLED managed rule (checks root user MFA)."
  type        = bool
  default     = true
}

variable "enable_mfa_for_iam_console_rule" {
  description = "Enable the MFA_ENABLED_FOR_IAM_CONSOLE_ACCESS managed rule."
  type        = bool
  default     = true
}

variable "enable_ec2_volume_inuse_rule" {
  description = "Enable the EC2_VOLUME_INUSE_CHECK managed rule."
  type        = bool
  default     = true
}

variable "enable_eip_attached_rule" {
  description = "Enable the EIP_ATTACHED managed rule."
  type        = bool
  default     = true
}

variable "enable_rds_storage_encrypted_rule" {
  description = "Enable the RDS_STORAGE_ENCRYPTED managed rule."
  type        = bool
  default     = true
}

# --- Compliance Reporter Variables (Optional) ---

variable "enable_compliance_reporter" {
  description = "Set to true to enable the scheduled Lambda function that generates PDF compliance reports."
  type        = bool
  default     = false
}

variable "reporter_schedule_expression" {
  description = "Cron expression for triggering the compliance report Lambda. Default: Monthly on the 1st at 6 AM UTC."
  type        = string
  default     = "cron(0 6 1 * ? *)"
}

variable "reporter_output_s3_prefix" {
  description = "S3 key prefix within the Config bucket where PDF compliance reports will be stored."
  type        = string
  default     = "compliance-reports/"

  validation {
    # Ensure it ends with a slash if not empty
    condition     = var.reporter_output_s3_prefix == "" || substr(var.reporter_output_s3_prefix, -1, 1) == "/"
    error_message = "The reporter_output_s3_prefix must end with a '/'."
  }
}

variable "reporter_lambda_memory_size" {
  description = "Memory size (MB) allocated to the compliance reporter Lambda function."
  type        = number
  default     = 256
}

variable "reporter_lambda_timeout" {
  description = "Timeout (seconds) for the compliance reporter Lambda function."
  type        = number
  default     = 120 # 2 minutes, PDF generation can take time
}
