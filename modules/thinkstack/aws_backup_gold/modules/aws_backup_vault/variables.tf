# Variables for the AWS Backup Vault module

###################################################
# Primary Vault Variables
###################################################

variable "vault_name" {
  description = "The name of the primary backup vault"
  type        = string
  default     = "gold-backup-vault"
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
  default     = "KMS key for AWS Backup Gold vault encryption"
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

###################################################
# Vault Lock Variables
###################################################

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
  description = "The minimum retention period that the vault retains its recovery points"
  type        = number
  default     = 1
}

###################################################
# DR Vault Variables
###################################################

variable "enable_dr" {
  description = "Whether to create a DR vault in another region"
  type        = bool
  default     = false
}

variable "dr_vault_name" {
  description = "The name of the DR backup vault"
  type        = string
  default     = "gold-backup-vault-dr"
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
  default     = "KMS key for AWS Backup Gold DR vault encryption"
}

variable "dr_tags" {
  description = "Additional tags to apply to DR resources"
  type        = map(string)
  default     = {}
}

###################################################
# Common Variables
###################################################

variable "tags" {
  description = "A mapping of tags to assign to the resource"
  type        = map(string)
  default     = {}
}
