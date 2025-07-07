variable "name" {
  description = "The display name of a backup plan"
  type        = string
}

variable "plan_prefix" {
  description = "Prefix to prepend to all backup plan names for identification (e.g., 'plan-a', 'plan-b')"
  type        = string
  default     = ""
}

variable "server_selection_tag" {
  description = "Tag key to use for selecting servers/resources for this backup plan (e.g., 'Plan_A', 'BackupPlan', 'PlanA')"
  type        = string
  default     = null
}

variable "server_selection_value" {
  description = "Tag value to match for selecting servers/resources (e.g., 'true', 'True', 'yes', 'Yes', 'enabled')"
  type        = string
  default     = "true"
}

variable "use_individual_plans" {
  description = "Whether to create individual backup plans for each schedule type or a single combined plan"
  type        = bool
  default     = false
}

# Hourly backup plan variables
variable "enable_hourly_plan" {
  description = "Enable hourly backup plan"
  type        = bool
  default     = false
}

variable "hourly_schedule" {
  description = "Cron expression for hourly backups (defaults to every hour)"
  type        = string
  default     = null
}

variable "hourly_retention_days" {
  description = "Number of days to retain hourly backups"
  type        = number
  default     = 7
}

variable "hourly_vault_name" {
  description = "Name of the backup vault for hourly backups"
  type        = string
  default     = "hourly"
}

variable "hourly_enable_continuous_backup" {
  description = "Enable continuous backup for hourly plan"
  type        = bool
  default     = false
}

variable "hourly_start_window" {
  description = "Start window in minutes for hourly backups"
  type        = number
  default     = 60
}

variable "hourly_completion_window" {
  description = "Completion window in minutes for hourly backups"
  type        = number
  default     = 120
}

variable "hourly_cold_storage_after" {
  description = "Days after which to move hourly backups to cold storage"
  type        = number
  default     = null
}

variable "enable_hourly_dr_copy" {
  description = "Enable copying hourly backups to DR region"
  type        = bool
  default     = false
}

variable "hourly_dr_vault_arn" {
  description = "ARN of the DR vault for hourly backups"
  type        = string
  default     = null
}

variable "hourly_dr_vault_name" {
  description = "Name of the DR vault for hourly backups (alternative to hourly_dr_vault_arn)"
  type        = string
  default     = null
}

variable "hourly_dr_retention_days" {
  description = "Number of days to retain hourly backups in DR region"
  type        = number
  default     = null
}

variable "hourly_dr_cold_storage_after" {
  description = "Days after which to move hourly DR backups to cold storage"
  type        = number
  default     = null
}

# Daily backup plan variables
variable "enable_daily_plan" {
  description = "Enable daily backup plan"
  type        = bool
  default     = false
}

variable "daily_schedule" {
  description = "Cron expression for daily backups (defaults to 5 AM daily)"
  type        = string
  default     = null
}

variable "daily_retention_days" {
  description = "Number of days to retain daily backups"
  type        = number
  default     = 30
}

variable "daily_vault_name" {
  description = "Name of the backup vault for daily backups"
  type        = string
  default     = "daily"
}

variable "daily_enable_continuous_backup" {
  description = "Enable continuous backup for daily plan"
  type        = bool
  default     = false
}

variable "daily_start_window" {
  description = "Start window in minutes for daily backups"
  type        = number
  default     = 60
}

variable "daily_completion_window" {
  description = "Completion window in minutes for daily backups"
  type        = number
  default     = 180
}

variable "daily_cold_storage_after" {
  description = "Days after which to move daily backups to cold storage"
  type        = number
  default     = null
}

variable "enable_daily_dr_copy" {
  description = "Enable copying daily backups to DR region"
  type        = bool
  default     = false
}

variable "daily_dr_vault_arn" {
  description = "ARN of the DR vault for daily backups"
  type        = string
  default     = null
}

variable "daily_dr_vault_name" {
  description = "Name of the DR vault for daily backups (alternative to daily_dr_vault_arn)"
  type        = string
  default     = null
}

variable "daily_dr_retention_days" {
  description = "Number of days to retain daily backups in DR region"
  type        = number
  default     = null
}

variable "daily_dr_cold_storage_after" {
  description = "Days after which to move daily DR backups to cold storage"
  type        = number
  default     = null
}

# Weekly backup plan variables
variable "enable_weekly_plan" {
  description = "Enable weekly backup plan"
  type        = bool
  default     = false
}

variable "weekly_schedule" {
  description = "Cron expression for weekly backups (defaults to Monday 5 AM)"
  type        = string
  default     = null
}

variable "weekly_retention_days" {
  description = "Number of days to retain weekly backups"
  type        = number
  default     = 90
}

variable "weekly_vault_name" {
  description = "Name of the backup vault for weekly backups"
  type        = string
  default     = "weekly"
}

variable "weekly_enable_continuous_backup" {
  description = "Enable continuous backup for weekly plan"
  type        = bool
  default     = false
}

variable "weekly_start_window" {
  description = "Start window in minutes for weekly backups"
  type        = number
  default     = 60
}

variable "weekly_completion_window" {
  description = "Completion window in minutes for weekly backups"
  type        = number
  default     = 360
}

variable "weekly_cold_storage_after" {
  description = "Days after which to move weekly backups to cold storage"
  type        = number
  default     = null
}

variable "enable_weekly_dr_copy" {
  description = "Enable copying weekly backups to DR region"
  type        = bool
  default     = false
}

variable "weekly_dr_vault_arn" {
  description = "ARN of the DR vault for weekly backups"
  type        = string
  default     = null
}

variable "weekly_dr_vault_name" {
  description = "Name of the DR vault for weekly backups (alternative to weekly_dr_vault_arn)"
  type        = string
  default     = null
}

variable "weekly_dr_retention_days" {
  description = "Number of days to retain weekly backups in DR region"
  type        = number
  default     = null
}

variable "weekly_dr_cold_storage_after" {
  description = "Days after which to move weekly DR backups to cold storage"
  type        = number
  default     = null
}

# Monthly backup plan variables
variable "enable_monthly_plan" {
  description = "Enable monthly backup plan"
  type        = bool
  default     = false
}

variable "monthly_schedule" {
  description = "Cron expression for monthly backups (defaults to 1st of month at 5 AM)"
  type        = string
  default     = null
}

variable "monthly_retention_days" {
  description = "Number of days to retain monthly backups"
  type        = number
  default     = 365
}

variable "monthly_vault_name" {
  description = "Name of the backup vault for monthly backups"
  type        = string
  default     = "monthly"
}

variable "monthly_enable_continuous_backup" {
  description = "Enable continuous backup for monthly plan"
  type        = bool
  default     = false
}

variable "monthly_start_window" {
  description = "Start window in minutes for monthly backups"
  type        = number
  default     = 60
}

variable "monthly_completion_window" {
  description = "Completion window in minutes for monthly backups"
  type        = number
  default     = 720
}

variable "monthly_cold_storage_after" {
  description = "Days after which to move monthly backups to cold storage"
  type        = number
  default     = null
}

variable "enable_monthly_dr_copy" {
  description = "Enable copying monthly backups to DR region"
  type        = bool
  default     = false
}

variable "monthly_dr_vault_arn" {
  description = "ARN of the DR vault for monthly backups"
  type        = string
  default     = null
}

variable "monthly_dr_vault_name" {
  description = "Name of the DR vault for monthly backups (alternative to monthly_dr_vault_arn)"
  type        = string
  default     = null
}

variable "monthly_dr_retention_days" {
  description = "Number of days to retain monthly backups in DR region"
  type        = number
  default     = null
}

variable "monthly_dr_cold_storage_after" {
  description = "Days after which to move monthly DR backups to cold storage"
  type        = number
  default     = null
}

# Yearly backup plan variables
variable "enable_yearly_plan" {
  description = "Enable yearly backup plan"
  type        = bool
  default     = false
}

variable "yearly_schedule" {
  description = "Cron expression for yearly backups (defaults to January 1st at 5 AM)"
  type        = string
  default     = null
}

variable "yearly_retention_days" {
  description = "Number of days to retain yearly backups"
  type        = number
  default     = 2555  # 7 years
}

variable "yearly_vault_name" {
  description = "Name of the backup vault for yearly backups"
  type        = string
  default     = "yearly"
}

variable "yearly_enable_continuous_backup" {
  description = "Enable continuous backup for yearly plan"
  type        = bool
  default     = false
}

variable "yearly_start_window" {
  description = "Start window in minutes for yearly backups"
  type        = number
  default     = 60
}

variable "yearly_completion_window" {
  description = "Completion window in minutes for yearly backups"
  type        = number
  default     = 1440
}

variable "yearly_cold_storage_after" {
  description = "Days after which to move yearly backups to cold storage"
  type        = number
  default     = null
}

variable "enable_yearly_dr_copy" {
  description = "Enable copying yearly backups to DR region"
  type        = bool
  default     = false
}

variable "yearly_dr_vault_arn" {
  description = "ARN of the DR vault for yearly backups"
  type        = string
  default     = null
}

variable "yearly_dr_vault_name" {
  description = "Name of the DR vault for yearly backups (alternative to yearly_dr_vault_arn)"
  type        = string
  default     = null
}

variable "yearly_dr_retention_days" {
  description = "Number of days to retain yearly backups in DR region"
  type        = number
  default     = null
}

variable "yearly_dr_cold_storage_after" {
  description = "Days after which to move yearly DR backups to cold storage"
  type        = number
  default     = null
}

# Legacy custom rules support
variable "rules" {
  description = "A list of backup rules for the plan (for backward compatibility)"
  type = list(object({
    rule_name                = string
    target_vault_name        = string
    schedule                 = string
    enable_continuous_backup = optional(bool)
    start_window             = optional(number)
    completion_window        = optional(number)
    lifecycle = optional(object({
      cold_storage_after = optional(number)
      delete_after       = optional(number)
    }))
    copy_actions = optional(list(object({
      destination_vault_arn = string
      lifecycle = optional(object({
        cold_storage_after = optional(number)
        delete_after       = optional(number)
      }))
    })))
  }))
  default = []
}

variable "advanced_backup_settings" {
  description = "List of advanced backup settings"
  type = list(object({
    backup_options = map(string)
    resource_type  = string
  }))
  default = []
}

variable "tags" {
  description = "A mapping of tags to assign to the resource"
  type        = map(string)
  default     = {}
}

# Backup Selection Variables
variable "create_backup_selection" {
  description = "Whether to create backup selection resources"
  type        = bool
  default     = false
}

variable "enable_s3_backup" {
  description = "Whether to enable S3 backup capabilities"
  type        = bool
  default     = false
}

variable "backup_selection_tags" {
  description = "List of tags to select resources for backup"
  type = list(object({
    type  = string
    key   = string
    value = string
  }))
  default = []
}

variable "backup_selection_resources" {
  description = "List of resource ARNs to include in the backup selection"
  type        = list(string)
  default     = []
}

variable "backup_selection_not_resources" {
  description = "List of resource ARNs to exclude from the backup selection"
  type        = list(string)
  default     = []
}

variable "backup_selection_conditions" {
  description = "List of conditions for the backup selection"
  type = list(object({
    string_equals = optional(list(object({
      key   = string
      value = string
    })))
    string_not_equals = optional(list(object({
      key   = string
      value = string
    })))
    string_like = optional(list(object({
      key   = string
      value = string
    })))
    string_not_like = optional(list(object({
      key   = string
      value = string
    })))
  }))
  default = []
}

# Per-schedule selection tags
variable "hourly_selection_tag_key" {
  description = "Tag key for hourly backup selection"
  type        = string
  default     = null
}

variable "hourly_selection_tag_value" {
  description = "Tag value for hourly backup selection"
  type        = string
  default     = "true"
}

variable "daily_selection_tag_key" {
  description = "Tag key for daily backup selection"
  type        = string
  default     = null
}

variable "daily_selection_tag_value" {
  description = "Tag value for daily backup selection"
  type        = string
  default     = "true"
}

variable "weekly_selection_tag_key" {
  description = "Tag key for weekly backup selection"
  type        = string
  default     = null
}

variable "weekly_selection_tag_value" {
  description = "Tag value for weekly backup selection"
  type        = string
  default     = "true"
}

variable "monthly_selection_tag_key" {
  description = "Tag key for monthly backup selection"
  type        = string
  default     = null
}

variable "monthly_selection_tag_value" {
  description = "Tag value for monthly backup selection"
  type        = string
  default     = "true"
}

variable "yearly_selection_tag_key" {
  description = "Tag key for yearly backup selection"
  type        = string
  default     = null
}

variable "yearly_selection_tag_value" {
  description = "Tag value for yearly backup selection"
  type        = string
  default     = "true"
}