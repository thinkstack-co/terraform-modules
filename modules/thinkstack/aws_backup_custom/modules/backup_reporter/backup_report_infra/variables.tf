# Variables for AWS Backup Status Reporter Module

# S3 Configuration
variable "s3_bucket_prefix" {
  description = "Prefix for the S3 bucket to store PDF backup reports. A unique suffix will be appended."
  type        = string
  default     = "backup-status-report-"

  validation {
    condition = (
      length(var.s3_bucket_prefix) >= 3 &&
      length(var.s3_bucket_prefix) <= 37 &&
      can(regex("^[a-z0-9][a-z0-9.-]*[a-z0-9]$", var.s3_bucket_prefix)) &&
      !can(regex("[A-Z_]", var.s3_bucket_prefix)) &&
      length(regexall("\\.\\.", var.s3_bucket_prefix)) == 0 &&
      !can(regex("^[0-9]+\\.[0-9]+\\.[0-9]+\\.[0-9]+$", var.s3_bucket_prefix))
    )
    error_message = "s3_bucket_prefix must be 3-37 characters, only lowercase letters, numbers, hyphens, and periods, start/end with letter or number, no underscores, no consecutive periods, and not in IP address format."
  }
}

variable "s3_key_prefix" {
  description = "Optional prefix for S3 object keys where backup reports will be stored. If not set, reports will be stored in the format 'year/month/customer-backup-status-report-yyyy-mm-dd.pdf'. If set, reports will be stored in the format 'prefix/year/month/customer-backup-status-report-yyyy-mm-dd.pdf'."
  type        = string
  default     = ""

  validation {
    condition = (
      var.s3_key_prefix == "" || 
      (
        length(var.s3_key_prefix) >= 1 &&
        length(var.s3_key_prefix) <= 100 &&
        can(regex("^[a-zA-Z0-9!_.*'()/-]+$", var.s3_key_prefix)) &&
        !can(regex("^/", var.s3_key_prefix)) &&
        !can(regex("/$", var.s3_key_prefix))
      )
    )
    error_message = "s3_key_prefix must be empty or 1-100 characters, containing only letters, numbers, and !_.*'()/- characters, and must not start or end with a slash."
  }
}

variable "customer_name" {
  description = "Optional: Customer name or label for tagging and report identification. If empty, uses AWS Account ID."
  type        = string
  default     = ""
}

# Vault Configuration
variable "vault_name_prefix" {
  description = "Prefix for vault names. The module will look for vaults named prefix-hourly, prefix-daily, etc."
  type        = string
  default     = ""
}

# Enable/Disable Vault Reporting
variable "enable_hourly_report" {
  description = "Enable reporting for hourly backup vault"
  type        = bool
  default     = true
}

variable "enable_daily_report" {
  description = "Enable reporting for daily backup vault"
  type        = bool
  default     = true
}

variable "enable_weekly_report" {
  description = "Enable reporting for weekly backup vault"
  type        = bool
  default     = true
}

variable "enable_monthly_report" {
  description = "Enable reporting for monthly backup vault"
  type        = bool
  default     = true
}

variable "enable_yearly_report" {
  description = "Enable reporting for yearly backup vault"
  type        = bool
  default     = true
}

# Vault Name Overrides
variable "hourly_vault_name" {
  description = "Override the hourly vault name. If not set, uses vault_name_prefix + 'hourly'"
  type        = string
  default     = ""
}

variable "daily_vault_name" {
  description = "Override the daily vault name. If not set, uses vault_name_prefix + 'daily'"
  type        = string
  default     = ""
}

variable "weekly_vault_name" {
  description = "Override the weekly vault name. If not set, uses vault_name_prefix + 'weekly'"
  type        = string
  default     = ""
}

variable "monthly_vault_name" {
  description = "Override the monthly vault name. If not set, uses vault_name_prefix + 'monthly'"
  type        = string
  default     = ""
}

variable "yearly_vault_name" {
  description = "Override the yearly vault name. If not set, uses vault_name_prefix + 'yearly'"
  type        = string
  default     = ""
}

# Lambda Configuration
variable "lambda_function_name" {
  description = "Name for the Lambda function. If not set, defaults to 'aws-backup-status-reporter'"
  type        = string
  default     = ""
}

variable "lambda_package_path" {
  description = "Path to the Lambda deployment package ZIP file. If not set, uses the default location"
  type        = string
  default     = ""
}

variable "lambda_memory_size" {
  description = "Memory size (MB) for the Lambda function"
  type        = number
  default     = 512

  validation {
    condition     = var.lambda_memory_size >= 128 && var.lambda_memory_size <= 10240
    error_message = "Lambda memory size must be between 128 MB and 10,240 MB"
  }
}

variable "lambda_timeout" {
  description = "Timeout (seconds) for the Lambda function"
  type        = number
  default     = 300

  validation {
    condition     = var.lambda_timeout >= 1 && var.lambda_timeout <= 900
    error_message = "Lambda timeout must be between 1 and 900 seconds"
  }
}

# Schedule Configuration
variable "schedule_expression" {
  description = "Cron expression for running the backup report Lambda. Default: Daily at 8 AM UTC."
  type        = string
  default     = "cron(0 8 * * ? *)"
}

# Report Configuration
variable "report_days" {
  description = "Number of days to include in the backup report (1-7)"
  type        = number
  default     = 1

  validation {
    condition     = var.report_days >= 1 && var.report_days <= 7
    error_message = "report_days must be between 1 and 7"
  }
}

variable "vault_sort_order" {
  description = "Comma-separated list of vault types in desired sort order (e.g., 'hourly,daily,weekly,monthly,yearly')"
  type        = string
  default     = "hourly,daily,weekly,monthly,yearly"
}

# S3 Lifecycle Configuration
variable "enable_s3_lifecycle_rules" {
  description = "Whether to enable S3 lifecycle rules for backup report PDFs"
  type        = bool
  default     = true
}

variable "report_retention_days" {
  description = "Number of days to retain backup report PDFs in S3 before deletion (set to 0 to disable deletion)"
  type        = number
  default     = 90

  validation {
    condition     = var.report_retention_days >= 0
    error_message = "report_retention_days must be 0 (to disable) or a positive integer"
  }
}

variable "enable_glacier_transition" {
  description = "Whether to transition backup report PDFs to Glacier storage class"
  type        = bool
  default     = true
}

variable "glacier_transition_days" {
  description = "Number of days after which to transition backup report PDFs to Glacier storage class"
  type        = number
  default     = 30

  validation {
    condition     = var.glacier_transition_days >= 1
    error_message = "glacier_transition_days must be at least 1"
  }
}

variable "glacier_retention_days" {
  description = "Number of days to retain backup report PDFs in Glacier before deletion (set to 0 to disable deletion from Glacier)"
  type        = number
  default     = 365
}

# CloudWatch Logs
variable "log_retention_days" {
  description = "Number of days to retain CloudWatch logs for the Lambda function"
  type        = number
  default     = 7

  validation {
    condition = contains([1, 3, 5, 7, 14, 30, 60, 90, 120, 150, 180, 365, 400, 545, 731, 1827, 3653], var.log_retention_days)
    error_message = "log_retention_days must be one of the allowed values: 1, 3, 5, 7, 14, 30, 60, 90, 120, 150, 180, 365, 400, 545, 731, 1827, or 3653"
  }
}

# Tags
variable "tags" {
  description = "A map of tags to apply to all resources"
  type        = map(string)
  default     = {}
}