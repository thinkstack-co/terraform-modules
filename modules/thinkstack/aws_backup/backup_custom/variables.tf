variable "backup_jobs" {
  description = "List of backup jobs with associated vault details."
  type = list(object({
    vault_name        = string # Name of the backup vault
    vault_kms_key_arn = string # ARN of the KMS key associated with the backup vault
    vault_tags        = string
    rule_name         = string
    schedule          = string
    retention_days    = number
  }))
  default = [] # Default is an empty list, meaning no backup jobs are defined by default
}

variable "key_tags" {
  type        = map(string)
  description = "A mapping of tags to assign to the resource"
  default     = {}
}

variable "vault_tags" {
  type        = map(string)
  description = "A mapping of tags to assign to the resource"
  default     = {}
}

variable "plan_tags" {
  type        = map(string)
  description = "A mapping of tags to assign to the resource"
  default     = {}
}
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
  default     = null
  type        = string
}