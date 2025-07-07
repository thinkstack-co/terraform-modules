variable "aws_region" {
  description = "AWS region to deploy resources"
  type        = string
  default     = "us-east-1"
}

variable "dr_region" {
  description = "DR region for cross-region backup copies"
  type        = string
  default     = "us-west-2"
}

variable "project_name" {
  description = "Name of the project, used for naming resources"
  type        = string
  default     = "example"
}

variable "enable_hourly_vault" {
  description = "Whether to create hourly backup vault and plan"
  type        = bool
  default     = false
}

variable "enable_daily_vault" {
  description = "Whether to create daily backup vault and plan"
  type        = bool
  default     = true
}

variable "enable_weekly_vault" {
  description = "Whether to create weekly backup vault and plan"
  type        = bool
  default     = true
}

variable "enable_monthly_vault" {
  description = "Whether to create monthly backup vault and plan"
  type        = bool
  default     = true
}

variable "enable_yearly_vault" {
  description = "Whether to create yearly backup vault and plan"
  type        = bool
  default     = false
}

variable "enable_dr" {
  description = "Whether to enable DR vaults and cross-region copies"
  type        = bool
  default     = false
}

variable "enable_vault_lock" {
  description = "Whether to enable vault lock on all vaults"
  type        = bool
  default     = false
}

variable "enable_windows_vss" {
  description = "Whether to enable Windows VSS for EC2 backups"
  type        = bool
  default     = false
}

variable "backup_tag_key" {
  description = "Tag key used to identify resources for backup"
  type        = string
  default     = "backup_schedule"
}

# Individual DR enable flags
variable "enable_hourly_dr" {
  description = "Whether to create DR vault for hourly backups"
  type        = bool
  default     = true
}

variable "enable_daily_dr" {
  description = "Whether to create DR vault for daily backups"
  type        = bool
  default     = true
}

variable "enable_weekly_dr" {
  description = "Whether to create DR vault for weekly backups"
  type        = bool
  default     = true
}

variable "enable_monthly_dr" {
  description = "Whether to create DR vault for monthly backups"
  type        = bool
  default     = true
}

variable "enable_yearly_dr" {
  description = "Whether to create DR vault for yearly backups"
  type        = bool
  default     = true
}

variable "tags" {
  description = "Tags to apply to all resources"
  type        = map(string)
  default = {
    Environment = "dev"
    Terraform   = "true"
    Module      = "aws-backup-scheduled-vaults"
  }
}