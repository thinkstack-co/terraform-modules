###############################################################
# KMS Key Variables
###############################################################
variable "create_kms_key" {
  description = "(Optional) Whether to create a new KMS key for backups. If false, you must provide kms_key_arn for each vault."
  default     = false
  type        = bool
}

variable "kms_key_arn" {
  description = "(Optional) The ARN of an existing KMS key to use for encrypting backups. Only used if create_kms_key is false."
  default     = null
  type        = string
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
# Backup Vault Variables
###############################################################
variable "force_destroy" {
  description = "(Optional) A boolean that indicates whether all recovery points stored in the vault should be deleted so that the vault can be destroyed without error."
  default     = false
  type        = bool
}

variable "enable_vault_lock" {
  description = "(Optional) Whether to enable vault lock for all backup vaults created by this module. When enabled, vault lock prevents backup deletion or modifications to recovery points. This is a universal setting for all vaults."
  default     = false
  type        = bool
}

variable "vault_lock_changeable_for_days" {
  description = "(Optional) The number of days before the lock date. If this value is 0, you cannot change the vault lock after it's created. If this value is greater than 0, you can change the vault lock configuration for the specified number of days."
  default     = 3
  type        = number
}

variable "vault_lock_max_retention_days" {
  description = "(Optional) The maximum retention period that the vault retains its recovery points. If this parameter is not specified, Vault Lock does not enforce a maximum retention period (allowing indefinite retention)."
  default     = 1200
  type        = number
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
  description = "(Optional) The tag key to use for standard backup plans (daily, weekly, monthly, yearly). This is the tag key that will be used to identify resources to include in these backup plans. When tagging EC2 instances, the value can be a comma-separated string to include resources in multiple backup plans (e.g., \"daily,weekly,monthly\")."
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
  default     = 7
  type        = number
}

# Hourly Backup Plan
variable "create_hourly_plan" {
  description = "(Optional) Whether to create an hourly backup plan."
  default     = false
  type        = bool
}

variable "hourly_plan_name" {
  description = "(Optional) The name of the hourly backup plan."
  default     = "hourly-backup-plan"
  type        = string
}

variable "hourly_schedule" {
  description = "(Optional) CRON expression for hourly backups. Default is every hour at minute 0."
  default     = "cron(0 * * * ? *)"
  type        = string
}

variable "hourly_retention_days" {
  description = "(Optional) Number of days to retain hourly backups. Default is 1 day."
  default     = 1
  type        = number
}

variable "hourly_enable_continuous_backup" {
  description = "(Optional) Whether to enable continuous backups for hourly backup plan."
  default     = true
  type        = bool
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
# Windows VSS Support
###############################################################
variable "enable_windows_vss" {
  description = "(Optional) Whether to enable Windows VSS for all backup plans that support it. This is a global setting that can be overridden by plan-specific settings."
  default     = false
  type        = bool
}

variable "hourly_windows_vss" {
  description = "(Optional) Whether to enable Windows VSS for hourly backups. Only applies when enable_windows_vss is also true."
  default     = false
  type        = bool
}

variable "daily_windows_vss" {
  description = "(Optional) Whether to enable Windows VSS for daily backups. Only applies when enable_windows_vss is also true."
  default     = false
  type        = bool
}

variable "weekly_windows_vss" {
  description = "(Optional) Whether to enable Windows VSS for weekly backups. Only applies when enable_windows_vss is also true."
  default     = false
  type        = bool
}

variable "monthly_windows_vss" {
  description = "(Optional) Whether to enable Windows VSS for monthly backups. Only applies when enable_windows_vss is also true."
  default     = false
  type        = bool
}

variable "yearly_windows_vss" {
  description = "(Optional) Whether to enable Windows VSS for yearly backups. Only applies when enable_windows_vss is also true."
  default     = false
  type        = bool
}

###############################################################
# DR Copy Action Variables
###############################################################

variable "hourly_include_in_dr" {
  description = "(Optional) Whether to copy hourly backups to DR region."
  type        = bool
  default     = false
}

variable "hourly_dr_retention_days" {
  description = "(Optional) Retention period in days for hourly DR backup copies. If null, uses hourly_retention_days."
  type        = number
  default     = null
}

variable "daily_include_in_dr" {
  description = "(Optional) Whether to copy daily backups to DR region."
  type        = bool
  default     = false
}

variable "daily_dr_retention_days" {
  description = "(Optional) Retention period in days for daily DR backup copies. If null, uses daily_retention_days."
  type        = number
  default     = null
}

variable "weekly_include_in_dr" {
  description = "(Optional) Whether to copy weekly backups to DR region."
  type        = bool
  default     = false
}

variable "weekly_dr_retention_days" {
  description = "(Optional) Retention period in days for weekly DR backup copies. If null, uses weekly_retention_days."
  type        = number
  default     = null
}

variable "monthly_include_in_dr" {
  description = "(Optional) Whether to copy monthly backups to DR region."
  type        = bool
  default     = false
}

variable "monthly_dr_retention_days" {
  description = "(Optional) Retention period in days for monthly DR backup copies. If null, uses monthly_retention_days."
  type        = number
  default     = null
}

variable "yearly_include_in_dr" {
  description = "(Optional) Whether to copy yearly backups to DR region."
  type        = bool
  default     = false
}

variable "yearly_dr_retention_days" {
  description = "(Optional) Retention period in days for yearly DR backup copies. If null, uses yearly_retention_days."
  type        = number
  default     = null
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
    windows_vss              = bool
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

###############################################################
# Disaster Recovery (DR) Region Support
###############################################################
variable "enable_dr" {
  description = "(Optional) Whether to enable DR (Disaster Recovery) backup in a separate AWS region."
  type        = bool
  default     = false
}

variable "dr_region" {
  description = "(Required if enable_dr) The AWS region to use for DR backups."
  type        = string
  default     = null
}

variable "dr_vault_name" {
  description = "(Optional) The name of the backup vault to create in the DR region."
  type        = string
  default     = "dr-backup-vault"
}

variable "dr_tags" {
  description = "(Optional) Tags to apply to DR region resources."
  type        = map(any)
  default     = {}
}

variable "dr_backup_role_name" {
  description = "(Optional) Name of the IAM role for AWS Backup in DR region."
  type        = string
  default     = "aws-backup-dr-role"
}

  