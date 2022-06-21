###############################################################
# KMS Key Variables
###############################################################
variable "key_bypass_policy_lockout_safety_check" {
    description = "(Optional) Specifies whether to disable the policy lockout check performed when creating or updating the key's policy. Setting this value to true increases the risk that the CMK becomes unmanageable. For more information, refer to the scenario in the Default Key Policy section in the AWS Key Management Service Developer Guide. Defaults to false."
    default     = false
    type        = bool
}

variable "key_customer_master_key_spec" {
    description = "(Optional) Specifies whether the key contains a symmetric key or an asymmetric key pair and the encryption algorithms or signing algorithms that the key supports. Valid values: SYMMETRIC_DEFAULT, RSA_2048, RSA_3072, RSA_4096, ECC_NIST_P256, ECC_NIST_P384, ECC_NIST_P521, or ECC_SECG_P256K1. Defaults to SYMMETRIC_DEFAULT. For help with choosing a key spec, see the AWS KMS Developer Guide."
    default     = "SYMMETRIC_DEFAULT"
    type        = string
}

variable "key_description" {
    description = "(Optional) The description of the key as viewed in AWS console."
    default     = "AWS backups kms key used to encrypt backups"
    type        = string
}

variable "key_deletion_window_in_days" {
    description = "(Optional) Duration in days after which the key is deleted after destruction of the resource, must be between 7 and 30 days. Defaults to 30 days."
    default     = 30
    type        = number
}

variable "key_enable_key_rotation" {
  description = "(Optional) Specifies whether key rotation is enabled. Defaults to false."
  default     = true
  type        = bool
}

variable "key_usage" {
  description = "(Optional) Specifies the intended use of the key. Defaults to ENCRYPT_DECRYPT, and only symmetric encryption and decryption are supported."
  default     = "ENCRYPT_DECRYPT"
  type        = string
}

variable "key_is_enabled" {
  description = "(Optional) Specifies whether the key is enabled. Defaults to true."
  default     = true
  type        = string
}

variable "key_name" {
  description = "(Optional) The display name of the alias. The name must start with the word 'alias' followed by a forward slash"
  default     = "alias/aws_backup_key"
  type        = string
}

variable "key_policy" {
  description = "(Optional) A valid policy JSON document. Although this is a key policy, not an IAM policy, an aws_iam_policy_document, in the form that designates a principal, can be used. For more information about building policy documents with Terraform, see the AWS IAM Policy Document Guide."
  default     =  null
  type        = string
}

###############################################################
# Vault Variables
###############################################################

variable "vault_prod_hourly_name" {
    description = "value"
    default     = "vault_prod_hourly"
    type        = string
}

variable "vault_dr_hourly_name" {
    description = "value"
    default     = "vault_dr_hourly"
    type        = string
}

variable "vault_prod_daily_name" {
    description = "value"
    default     = "vault_prod_daily"
    type        = string
}

variable "vault_prod_monthly_name" {
    description = "value"
    default     = "vault_prod_monthly"
    type        = string
}

variable "vault_disaster_recovery_name" {
    description = "value"
    default     = "vault_disaster_recovery"
    type        = string
}

###############################################################
# Plan Variables
###############################################################

variable "backup_plan_name" {
  description = "(Required) The display name of a backup plan."
  default     = "prod_backups"
  type        = string
}

variable "ec2_backup_plan_name" {
  description = "(Required) The display name of a backup plan."
  default     = "ec2_prod_backups"
  type        = string
}

variable "hourly_backup_retention" {
  description = "(Required) The hourly backup plan retention in days. By default this is 3 days."
  default     = 3
  type        = number
}

variable "daily_backup_retention" {
  description = "(Required) The daily backup plan retention in days. By default this is 30 days"
  default     = 30
  type        = number
}

variable "monthly_backup_retention" {
  description = "(Required) The daily backup plan retention in days. By default this is 365 days."
  default     = 365
  type        = number
}

variable "dr_backup_retention" {
  description = "(Required) The dr backup plan retention in days. By default this is 7 days."
  default     = 7
  type        = number
}

variable "backup_plan_start_window" {
  description = "(Optional) The amount of time in minutes before beginning a backup."
  default = 60
  type = number
}

variable "backup_plan_completion_window" {
  description = "(Optional) The amount of time in minutes AWS Backup attempts a backup before canceling the job and returning an error. Default is set to 24 hours."
  default = 1440
  type = number
}

###############################################################
# General Use Variables
###############################################################

variable "tags" {
  description = "(Optional) A mapping of tags to assign to the object."
  default     = {
    terraform   = "true"
    created_by  = "ThinkStack"
    environment = "prod"
    priority    = "critical"
    aws_backup  = "true"
  }
}