variable "resource_group_name" {
  description = "Name of the resource group to deploy into."
  type        = string
}

variable "location" {
  description = "Azure Government region."
  type        = string
}

variable "customer_name" {
  description = "Short customer name used in resource naming."
  type        = string
}

variable "storage_account_name" {
  description = "Globally unique storage account name (max 24 chars, lowercase alphanumeric)."
  type        = string

  validation {
    condition     = can(regex("^[a-z0-9]{3,24}$", var.storage_account_name))
    error_message = "Storage account name must be 3-24 lowercase alphanumeric characters."
  }
}

variable "allowed_subnet_ids" {
  description = "List of subnet resource IDs allowed to access the storage account (service endpoints)."
  type        = list(string)
}

variable "fslogix_share_size_gb" {
  description = "Quota for the FSLogix profiles file share in GiB."
  type        = number
  default     = 512

  validation {
    condition     = var.fslogix_share_size_gb >= 100 && var.fslogix_share_size_gb <= 102400
    error_message = "File share quota must be between 100 and 102400 GiB."
  }
}

variable "backup_daily_retention_days" {
  description = "Number of daily backup recovery points to retain."
  type        = number
  default     = 14
}

variable "share_soft_delete_retention_days" {
  description = "Number of days deleted file shares remain recoverable before permanent deletion. Range 1-365."
  type        = number
  default     = 7

  validation {
    condition     = var.share_soft_delete_retention_days >= 1 && var.share_soft_delete_retention_days <= 365
    error_message = "Share soft-delete retention must be between 1 and 365 days."
  }
}

variable "backup_weekly_retention_weeks" {
  description = "Number of weekly backup recovery points to retain."
  type        = number
  default     = 4
}

variable "backup_monthly_retention_months" {
  description = "Number of monthly backup recovery points to retain."
  type        = number
  default     = 6
}

variable "tags" {
  description = "Tags applied to all resources."
  type        = map(string)
  default     = {}
}
