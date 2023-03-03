###########################
# KMS Variables
###########################

variable "key_customer_master_key_spec" {
  description = "(Optional) Specifies whether the key contains a symmetric key or an asymmetric key pair and the encryption algorithms or signing algorithms that the key supports. Valid values: SYMMETRIC_DEFAULT, RSA_2048, RSA_3072, RSA_4096, ECC_NIST_P256, ECC_NIST_P384, ECC_NIST_P521, or ECC_SECG_P256K1. Defaults to SYMMETRIC_DEFAULT. For help with choosing a key spec, see the AWS KMS Developer Guide."
  default     = "SYMMETRIC_DEFAULT"
  type        = string
  validation {
    condition     = can(regex("^(SYMMETRIC_DEFAULT|RSA_2048|RSA_3072|RSA_4096|ECC_NIST_P256|ECC_NIST_P384|ECC_NIST_P521|ECC_SECG_P256K1)$", var.key_customer_master_key_spec))
    error_message = "The value must be one of SYMMETRIC_DEFAULT, RSA_2048, RSA_3072, RSA_4096, ECC_NIST_P256, ECC_NIST_P384, ECC_NIST_P521, or ECC_SECG_P256K1."
  }
}

variable "key_description" {
  description = "(Optional) The description of the key as viewed in AWS console."
  default     = "CloudTrail kms key used to encrypt audit logs"
  type        = string
}

variable "key_deletion_window_in_days" {
  description = "(Optional) Duration in days after which the key is deleted after destruction of the resource, must be between 7 and 30 days. Defaults to 30 days."
  default     = 30
  type        = number
  validation {
    condition     = can(regex("^[7-9]|[1-2][0-9]|30$", var.key_deletion_window_in_days))
    error_message = "The value must be between 7 and 30 days."
  }
}

variable "key_enable_key_rotation" {
  description = "(Optional) Specifies whether key rotation is enabled. Defaults to false."
  default     = true
  type        = bool
  validation {
    condition     = can(regex("^(true|false)$", var.key_enable_key_rotation))
    error_message = "The value must be either true or false."
  }
}

variable "key_usage" {
  description = "(Optional) Specifies the intended use of the key. Defaults to ENCRYPT_DECRYPT, and only symmetric encryption and decryption are supported."
  default     = "ENCRYPT_DECRYPT"
  type        = string
}

variable "key_is_enabled" {
  description = "(Optional) Specifies whether the key is enabled. Defaults to true."
  default     = true
  type        = bool
  validation {
    condition     = can(regex("^(true|false)$", var.key_is_enabled))
    error_message = "The value must be either true or false."
  }
}

variable "key_name_prefix" {
  description = "(Optional) Creates an unique alias beginning with the specified prefix. The name must start with the word alias followed by a forward slash (alias/)."
  default     = "alias/sqs_key_"
  type        = string
}

###########################
# SQS Queue Variables
###########################

variable "delay_seconds" {
  type        = string
  description = "(Optional) The time in seconds that the delivery of all messages in the queue will be delayed. An integer from 0 to 900 (15 minutes). The default for this attribute is 0 seconds."
  default     = 0
  validation {
    condition = can(regex("^[0-9]{1,3}|[1-8][0-9]{3}|900$", var.delay_seconds))
  }
}

variable "fifo_queue" {
  type        = bool
  description = "(Optional) Boolean designating a FIFO queue. If not set, it defaults to false making it standard."
  default     = false
  validation {
    condition     = can(regex("^(true|false)$", var.fifo_queue))
    error_message = "The value must be either true or false."
  }
}

variable "kms_data_key_reuse_period_seconds" {
  type        = number
  description = "(Optional) The length of time, in seconds, for which Amazon SQS can reuse a data key to encrypt or decrypt messages before calling AWS KMS again. An integer representing seconds, between 60 seconds (1 minute) and 86,400 seconds (24 hours). The default is 300 (5 minutes)."
  default     = 300
  validation {
    condition = can(regex("^[6-9][0-9]{1,4}|[1-7][0-9]{4}|8[0-5][0-9]{3}|86[0-3][0-9]{2}|86400$", var.kms_data_key_reuse_period_seconds))
  }
}

variable "message_retention_seconds" {
  description = "(Optional) The number of seconds Amazon SQS retains a message. Integer representing seconds, from 60 (1 minute) to 1209600 (14 days). The default for this attribute is 345600 (4 days)."
  default     = 345600
  validation {
    condition = can(regex("^[6-9][0-9]{1,4}|[1-7][0-9]{4}|8[0-5][0-9]{3}|86[0-3][0-9]{2}|1209600$", var.message_retention_seconds))
  }
}

variable "name" {
  type        = string
  description = "(Optional) This is the human-readable name of the queue. If omitted, Terraform will assign a random name."
}

variable "tags" {
  type        = map(any)
  description = "(Optional) A mapping of tags to assign to the queue."
  default     = {}
}

variable "visibility_timeout_seconds" {
  type        = string
  description = "(Optional) The visibility timeout for the queue. An integer from 0 to 43200 (12 hours). The default for this attribute is 30. For more information about visibility timeout, see AWS docs."
  default     = 30
  validation {
    condition = can(regex("^[0-9]{1,4}|1[0-9]{4}|2[0-9]{4}|3[0-1][0-9]{3}|32[0-7][0-9]{2}|328[0-8][0-9]|3289[0-6]$", var.visibility_timeout_seconds))
  }
}
