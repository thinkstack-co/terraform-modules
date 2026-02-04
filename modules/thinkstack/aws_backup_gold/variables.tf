# Input variables for the experimental aws_backup_gold module
#
# These are intentionally minimal to start. We will add more inputs
# as we design the Gold single-plan strategy.

variable "tags" {
  description = "Common tags to apply to all backup resources created by this module"
  type        = map(string)
  default     = {}
}

variable "plan_name" {
  description = "Name of the experimental Gold backup plan"
  type        = string
  default     = "gold-backup-plan"
}

variable "backup_role_arn" {
  description = "ARN of the IAM role that AWS Backup uses for this plan's selection"
  type        = string
}

variable "primary_vault_name" {
  description = "Name of the existing AWS Backup vault in the primary region that will store all backups"
  type        = string
}

variable "selection_tag_key" {
  description = "Tag key used to select resources for this plan (for example, BackupPlan or PlanName)"
  type        = string
  default     = "BackupPlan"
}

variable "selection_tag_value" {
  description = "Tag value used to select resources for this plan (for example, true or PlanA)"
  type        = string
  default     = "true"
}

variable "start_window" {
  description = "Amount of time in minutes before beginning a backup"
  type        = number
  default     = 60
}

variable "completion_window" {
  description = "Amount of time in minutes AWS Backup will attempt a backup before failing"
  type        = number
  default     = 1440
}

variable "dr_vault_arn" {
  description = "ARN of the DR backup vault to receive copied backups (required when any *_copy_to_dr flag is true)"
  type        = string
  default     = ""
}

# Hourly rule configuration
variable "enable_hourly_rule" {
  description = "Whether to enable the hourly backup rule in the Gold plan"
  type        = bool
  default     = true
}

variable "hourly_schedule" {
  description = "CRON expression for hourly backups in the single plan"
  type        = string
  default     = "cron(0 * * * ? *)"
}

variable "hourly_retention_days" {
  description = "Retention in days for hourly backups in the primary vault"
  type        = number
  default     = 1
}

variable "hourly_copy_to_dr" {
  description = "Whether to copy hourly backups to the DR vault"
  type        = bool
  default     = false
}

variable "hourly_dr_retention_days" {
  description = "Retention in days for hourly backups in the DR vault (only used when hourly_copy_to_dr is true)"
  type        = number
  default     = 7
}

# Daily rule configuration
variable "enable_daily_rule" {
  description = "Whether to enable the daily backup rule in the Gold plan"
  type        = bool
  default     = true
}

variable "daily_schedule" {
  description = "CRON expression for daily backups in the single plan"
  type        = string
  default     = "cron(20 7 * * ? *)"
}

variable "daily_retention_days" {
  description = "Retention in days for daily backups in the primary vault"
  type        = number
  default     = 30
}

variable "daily_copy_to_dr" {
  description = "Whether to copy daily backups to the DR vault"
  type        = bool
  default     = false
}

variable "daily_dr_retention_days" {
  description = "Retention in days for daily backups in the DR vault (only used when daily_copy_to_dr is true)"
  type        = number
  default     = 90
}

# Weekly rule configuration
variable "enable_weekly_rule" {
  description = "Whether to enable the weekly backup rule in the Gold plan"
  type        = bool
  default     = false
}

variable "weekly_schedule" {
  description = "CRON expression for weekly backups in the single plan"
  type        = string
  default     = "cron(20 7 ? * SUN *)"
}

variable "weekly_retention_days" {
  description = "Retention in days for weekly backups in the primary vault"
  type        = number
  default     = 30
}

variable "weekly_copy_to_dr" {
  description = "Whether to copy weekly backups to the DR vault"
  type        = bool
  default     = false
}

variable "weekly_dr_retention_days" {
  description = "Retention in days for weekly backups in the DR vault (only used when weekly_copy_to_dr is true)"
  type        = number
  default     = 90
}

# Monthly rule configuration
variable "enable_monthly_rule" {
  description = "Whether to enable the monthly backup rule in the Gold plan"
  type        = bool
  default     = true
}

variable "monthly_schedule" {
  description = "CRON expression for monthly backups in the single plan"
  type        = string
  default     = "cron(20 7 1 * ? *)"
}

variable "monthly_retention_days" {
  description = "Retention in days for monthly backups in the primary vault"
  type        = number
  default     = 365
}

variable "monthly_copy_to_dr" {
  description = "Whether to copy monthly backups to the DR vault"
  type        = bool
  default     = false
}

variable "monthly_dr_retention_days" {
  description = "Retention in days for monthly backups in the DR vault (only used when monthly_copy_to_dr is true)"
  type        = number
  default     = 365
}

# Yearly rule configuration
variable "enable_yearly_rule" {
  description = "Whether to enable the yearly backup rule in the Gold plan"
  type        = bool
  default     = false
}

variable "yearly_schedule" {
  description = "CRON expression for yearly backups in the single plan"
  type        = string
  default     = "cron(20 7 1 1 ? *)"
}

variable "yearly_retention_days" {
  description = "Retention in days for yearly backups in the primary vault"
  type        = number
  default     = 2555
}

variable "yearly_copy_to_dr" {
  description = "Whether to copy yearly backups to the DR vault"
  type        = bool
  default     = false
}

variable "yearly_dr_retention_days" {
  description = "Retention in days for yearly backups in the DR vault (only used when yearly_copy_to_dr is true)"
  type        = number
  default     = 2555
}
