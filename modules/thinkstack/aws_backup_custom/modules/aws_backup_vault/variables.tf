# Single vault variables (original functionality)
variable "create_single_vault" {
  description = "Whether to create a single custom vault (set to false when using scheduled vaults)"
  type        = bool
  default     = true
}

variable "name" {
  description = "The name of the backup vault (used when create_single_vault is true)"
  type        = string
  default     = ""
}

variable "create_kms_key" {
  description = "Whether to create a new KMS key for the backup vault"
  type        = bool
  default     = false
}

variable "kms_key_arn" {
  description = "The server-side encryption key that is used to protect your backups (ignored if create_kms_key is true)"
  type        = string
  default     = null
}

variable "kms_key_description" {
  description = "Description for the KMS key if creating one"
  type        = string
  default     = "KMS key for AWS Backup vault encryption"
}

variable "kms_key_deletion_window" {
  description = "KMS key deletion window in days"
  type        = number
  default     = 30
}

variable "kms_key_enable_rotation" {
  description = "Whether to enable automatic rotation for the KMS key"
  type        = bool
  default     = true
}

variable "force_destroy" {
  description = "A boolean that indicates whether all recovery points stored in the vault should be deleted so that the vault can be destroyed without error"
  type        = bool
  default     = false
}

# Scheduled vault variables
variable "vault_name_prefix" {
  description = "Prefix for scheduled vault names (e.g., 'prod' results in 'prod-daily', 'prod-weekly', etc.)"
  type        = string
  default     = ""
}

variable "enable_hourly_vault" {
  description = "Whether to create an hourly backup vault"
  type        = bool
  default     = false
}

variable "enable_daily_vault" {
  description = "Whether to create a daily backup vault"
  type        = bool
  default     = false
}

variable "enable_weekly_vault" {
  description = "Whether to create a weekly backup vault"
  type        = bool
  default     = false
}

variable "enable_monthly_vault" {
  description = "Whether to create a monthly backup vault"
  type        = bool
  default     = false
}

variable "enable_yearly_vault" {
  description = "Whether to create a yearly backup vault"
  type        = bool
  default     = false
}

# Vault lock variables
variable "enable_vault_lock" {
  description = "Whether to enable vault lock"
  type        = bool
  default     = false
}

variable "vault_lock_changeable_for_days" {
  description = "The number of days before the lock date"
  type        = number
  default     = 3
}

variable "vault_lock_max_retention_days" {
  description = "The maximum retention period that the vault retains its recovery points"
  type        = number
  default     = 1200
}

variable "vault_lock_min_retention_days" {
  description = "The minimum retention period that the vault retains its recovery points (for single vault only)"
  type        = number
  default     = 7
}

# Schedule-specific minimum retention
variable "hourly_min_retention_days" {
  description = "Minimum retention days for hourly vault"
  type        = number
  default     = 1
}

variable "daily_min_retention_days" {
  description = "Minimum retention days for daily vault"
  type        = number
  default     = 7
}

variable "weekly_min_retention_days" {
  description = "Minimum retention days for weekly vault"
  type        = number
  default     = 30
}

variable "monthly_min_retention_days" {
  description = "Minimum retention days for monthly vault"
  type        = number
  default     = 365
}

variable "yearly_min_retention_days" {
  description = "Minimum retention days for yearly vault"
  type        = number
  default     = 2555 # 7 years
}

# DR variables
variable "enable_dr" {
  description = "Whether to create DR vaults in another region"
  type        = bool
  default     = false
}

# Individual DR enable flags for each vault type
variable "enable_hourly_dr_vault" {
  description = "Whether to create a DR vault for hourly backups"
  type        = bool
  default     = true
}

variable "enable_daily_dr_vault" {
  description = "Whether to create a DR vault for daily backups"
  type        = bool
  default     = true
}

variable "enable_weekly_dr_vault" {
  description = "Whether to create a DR vault for weekly backups"
  type        = bool
  default     = true
}

variable "enable_monthly_dr_vault" {
  description = "Whether to create a DR vault for monthly backups"
  type        = bool
  default     = true
}

variable "enable_yearly_dr_vault" {
  description = "Whether to create a DR vault for yearly backups"
  type        = bool
  default     = true
}

variable "dr_vault_name" {
  description = "Name for the single DR vault (used when create_single_vault is true)"
  type        = string
  default     = ""
}

variable "dr_vault_name_prefix" {
  description = "Prefix for DR vault names (e.g., 'prod-dr' results in 'prod-dr-daily', etc.)"
  type        = string
  default     = ""
}

variable "create_dr_kms_key" {
  description = "Whether to create a new KMS key for the DR backup vault"
  type        = bool
  default     = false
}

variable "dr_kms_key_arn" {
  description = "The KMS key ARN for the DR region (ignored if create_dr_kms_key is true)"
  type        = string
  default     = null
}

variable "dr_kms_key_description" {
  description = "Description for the DR KMS key if creating one"
  type        = string
  default     = "KMS key for AWS Backup DR vault encryption"
}

variable "dr_tags" {
  description = "Additional tags to apply to DR resources"
  type        = map(string)
  default     = {}
}

# Common variables
variable "tags" {
  description = "A mapping of tags to assign to the resource"
  type        = map(string)
  default     = {}
}