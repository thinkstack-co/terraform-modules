###############################################################
# KMS Key Variables
###############################################################
variable "create_kms_key" {
  description = "(Optional) Whether to create a new KMS key for backups. If false, you must provide kms_key_arn for each vault."
  default     = false
  type        = bool
}

variable "kms_alias_name" {
  description = "(Optional) The alias name for the KMS key."
  default     = "backup-custom-key"
  type        = string
}

variable "key_bypass_policy_lockout_safety_check" {
  description = "(Optional) Specifies whether to disable the policy lockout check performed when creating or updating the key's policy. Setting this value to true increases the risk that the CMK becomes unmanageable."
  default     = false
  type        = bool
}

variable "key_customer_master_key_spec" {
  description = "(Optional) Specifies whether the key contains a symmetric key or an asymmetric key pair and the encryption algorithms or signing algorithms that the key supports."
  default     = "SYMMETRIC_DEFAULT"
  type        = string
}

variable "key_description" {
  description = "(Optional) The description of the key as viewed in AWS console."
  default     = "AWS custom backups KMS key used to encrypt backups"
  type        = string
}

variable "key_deletion_window_in_days" {
  description = "(Optional) Duration in days after which the key is deleted after destruction of the resource, must be between 7 and 30 days."
  default     = 30
  type        = number
}

variable "key_enable_key_rotation" {
  description = "(Optional) Specifies whether key rotation is enabled."
  default     = true
  type        = bool
}

variable "key_usage" {
  description = "(Optional) Specifies the intended use of the key. Valid values: ENCRYPT_DECRYPT or SIGN_VERIFY."
  default     = "ENCRYPT_DECRYPT"
  type        = string
}

variable "key_is_enabled" {
  description = "(Optional) Specifies whether the key is enabled."
  default     = true
  type        = bool
}

variable "key_policy" {
  description = "(Optional) A valid policy JSON document."
  default     = null
  type        = string
}

###############################################################
# IAM Role Variables
###############################################################
variable "backup_role_name" {
  description = "(Optional) The name of the IAM role that AWS Backup uses to authenticate when backing up the target resource."
  default     = "aws-backup-custom-role"
  type        = string
}

###############################################################
# Backup Plan Variables
###############################################################
variable "backup_start_window" {
  description = "(Optional) The amount of time in minutes before beginning a backup. Default is 60 minutes."
  default     = 60
  type        = number
}

variable "backup_completion_window" {
  description = "(Optional) The amount of time in minutes AWS Backup attempts a backup before canceling the job and returning an error. Default is 1440 minutes (24 hours)."
  default     = 1440
  type        = number
}

variable "standard_backup_tag_key" {
  description = "(Optional) The tag key to use for standard backup plans (daily, weekly, monthly, yearly). This is the tag key that will be used to identify resources to include in these backup plans."
  default     = "backup_schedule"
  type        = string
}

# Daily Backup Plan
variable "create_daily_plan" {
  description = "(Optional) Whether to create a daily backup plan."
  default     = false
  type        = bool
}

variable "daily_plan_name" {
  description = "(Optional) The name of the daily backup plan."
  default     = "daily-backup-plan"
  type        = string
}

variable "daily_schedule" {
  description = "(Optional) A CRON expression specifying when AWS Backup initiates a backup job for the daily plan."
  default     = "cron(0 1 * * ? *)" # Daily at 1:00 AM UTC
  type        = string
}

variable "daily_enable_continuous_backup" {
  description = "(Optional) Enable continuous backups for the daily plan."
  default     = false
  type        = bool
}

variable "daily_retention_days" {
  description = "(Optional) Number of days to retain daily backups."
  default     = 3
  type        = number
}

# Weekly Backup Plan
variable "create_weekly_plan" {
  description = "(Optional) Whether to create a weekly backup plan."
  default     = false
  type        = bool
}

variable "weekly_plan_name" {
  description = "(Optional) The name of the weekly backup plan."
  default     = "weekly-backup-plan"
  type        = string
}

variable "weekly_schedule" {
  description = "(Optional) A CRON expression specifying when AWS Backup initiates a backup job for the weekly plan."
  default     = "cron(0 1 ? * SUN *)" # Weekly on Sunday at 1:00 AM UTC
  type        = string
}

variable "weekly_enable_continuous_backup" {
  description = "(Optional) Enable continuous backups for the weekly plan."
  default     = false
  type        = bool
}

variable "weekly_retention_days" {
  description = "(Optional) Number of days to retain weekly backups."
  default     = 30
  type        = number
}

# Monthly Backup Plan
variable "create_monthly_plan" {
  description = "(Optional) Whether to create a monthly backup plan."
  default     = false
  type        = bool
}

variable "monthly_plan_name" {
  description = "(Optional) The name of the monthly backup plan."
  default     = "monthly-backup-plan"
  type        = string
}

variable "monthly_schedule" {
  description = "(Optional) A CRON expression specifying when AWS Backup initiates a backup job for the monthly plan."
  default     = "cron(0 1 1 * ? *)" # Monthly on the 1st at 1:00 AM UTC
  type        = string
}

variable "monthly_enable_continuous_backup" {
  description = "(Optional) Enable continuous backups for the monthly plan."
  default     = false
  type        = bool
}

variable "monthly_retention_days" {
  description = "(Optional) Number of days to retain monthly backups."
  default     = 365
  type        = number
}

# Yearly Backup Plan
variable "create_yearly_plan" {
  description = "(Optional) Whether to create a yearly backup plan."
  default     = false
  type        = bool
}

variable "yearly_plan_name" {
  description = "(Optional) The name of the yearly backup plan."
  default     = "yearly-backup-plan"
  type        = string
}

variable "yearly_schedule" {
  description = "(Optional) A CRON expression specifying when AWS Backup initiates a backup job for the yearly plan."
  default     = "cron(0 1 1 1 ? *)" # Yearly on January 1st at 1:00 AM UTC
  type        = string
}

variable "yearly_enable_continuous_backup" {
  description = "(Optional) Enable continuous backups for the yearly plan."
  default     = false
  type        = bool
}

variable "yearly_retention_days" {
  description = "(Optional) Number of days to retain yearly backups."
  default     = 365
  type        = number
}

###############################################################
# Custom Backup Plans
###############################################################
variable "custom_backup_plans" {
  description = "Map of custom backup plans. Each key is the plan name, and the value is an object with schedule, retention, and tag details."
  type = map(object({
    vault_name               = string
    schedule                 = string
    enable_continuous_backup = bool
    retention_days           = number
    resource_type            = string
    tag_key                  = string
    tag_value                = string
    tags                     = map(string)
  }))
  default = {}
}

variable "default_custom_backup_tag_key" {
  description = "(Optional) The default tag key to use for custom backup plans if not specified in the custom_backup_plans map. This provides a consistent approach with standard backup plans."
  default     = "backup_custom"
  type        = string
}

###############################################################
# General Use Variables
###############################################################
variable "tags" {
  type        = map(any)
  description = "(Optional) A mapping of tags to assign to all resources."
  default = {
    terraform   = "true"
    created_by  = "ThinkStack"
    environment = "prod"
    priority    = "critical"
    aws_backup  = "true"
  }
}
