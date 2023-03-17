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
  default     = "S3 kms key used to encrypt bucket objects logs"
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

variable "key_name_prefix" {
  description = "(Optional) Creates an unique alias beginning with the specified prefix. The name must start with the word alias followed by a forward slash (alias/)."
  default     = "alias/s3_key_"
  type        = string
}

######################
# S3 Variables
######################
variable "bucket_prefix" {
  type        = string
  description = "(Optional, Forces new resource) Creates a unique bucket name beginning with the specified prefix. Conflicts with bucket."
}

variable "bucket_force_destroy" {
  type        = bool
  description = "(Optional, Default:false) Boolean that indicates all objects (including any locked objects) should be deleted from the bucket when the bucket is destroyed so that the bucket can be destroyed without error. These objects are not recoverable. This only deletes objects when the bucket is destroyed, not when setting this parameter to true. Once this parameter is set to true, there must be a successful terraform apply run before a destroy is required to update this value in the resource state. Without a successful terraform apply after this parameter is set, this flag will have no effect. If setting this field in the same operation that would require replacing the bucket or destroying the bucket, this flag will not work. Additionally when importing a bucket, a successful terraform apply is required to set this value in state before it will take effect on a destroy operation."
  default     = false
  validation {
    condition     = can(regex("true|false", var.bucket_force_destroy))
    error_message = "The value must be true or false."
  }
}

variable "bucket_object_lock_enabled" {
  type        = bool
  description = "(Optional, Forces new resource) Indicates whether this bucket has an Object Lock configuration enabled. Valid values are true or false. This argument is not supported in all regions or partitions."
  default     = false
  validation {
    condition     = can(regex("true|false", var.bucket_object_lock_enabled))
    error_message = "The value must be true or false."
  }
}

######################
# S3 Lifecycle Variables
######################


######################
# S3 Public Block Variables
######################

variable "block_public_acls" {
  type        = bool
  description = "(Optional) Whether Amazon S3 should block public ACLs for this bucket. Defaults to false. Enabling this setting does not affect existing policies or ACLs. "
  default     = true
  validation {
    condition     = can(regex("true|false", var.block_public_acls))
    error_message = "The value must be true or false."
  }
}

variable "block_public_policy" {
  type        = bool
  description = "(Optional) Whether Amazon S3 should block public bucket policies for this bucket. Defaults to false. Enabling this setting does not affect the existing bucket policy."
  default     = true
  validation {
    condition     = can(regex("true|false", var.block_public_policy))
    error_message = "The value must be true or false."
  }
}

variable "ignore_public_acls" {
  type        = bool
  description = "(Optional) Whether Amazon S3 should ignore public ACLs for this bucket. Defaults to false. Enabling this setting does not affect the persistence of any existing ACLs and doesn't prevent new public ACLs from being set."
  default     = true
  validation {
    condition     = can(regex("true|false", var.ignore_public_acls))
    error_message = "The value must be true or false."
  }
}

variable "restrict_public_buckets" {
  type        = bool
  description = "(Optional) Whether Amazon S3 should restrict public bucket policies for this bucket. Defaults to false. Enabling this setting does not affect the previously stored bucket policy, except that public and cross-account access within the public bucket policy, including non-public delegation to specific accounts, is blocked."
  default     = true
  validation {
    condition     = can(regex("true|false", var.restrict_public_buckets))
    error_message = "The value must be true or false."
  }
}

######################
# S3 Encryption Variables
######################

variable "kms_master_key_id" {
  type        = string
  description = "(Optional) The AWS KMS master key ID used for the SSE-KMS encryption. This can only be used when you set the value of sse_algorithm as aws:kms. The default aws/s3 AWS KMS master key is used if this element is absent while the sse_algorithm is aws:kms."
  default     = null
}



variable "policy" {
  description = "(Optional) A valid bucket policy JSON document. Note that if the policy document is not specific enough (but still valid), Terraform may view the policy as constantly changing in a terraform plan. In this case, please make sure you use the verbose/specific version of the policy."
  default     = null
}

variable "sse_algorithm" {
  type        = string
  description = "(required) The server-side encryption algorithm to use. Valid values are AES256 and aws:kms"
  default     = "aws:kms"
  validation {
    condition     = can(regex("AES256|aws:kms", var.sse_algorithm))
    error_message = "The value must be AES256 or aws:kms."
  }
}

variable "target_bucket" {
  type        = string
  description = "(Required) The name of the bucket that will receive the log objects."
  default     = ""
}

variable "target_prefix" {
  type        = string
  description = "(Optional) To specify a key prefix for log objects."
  default     = "log/"
}

variable "versioning" {
  description = "(Optional) A state of versioning (documented below)"
  default     = true
}

variable "mfa_delete" {
  description = "(Optional) Enable MFA delete for either Change the versioning state of your bucket or Permanently delete an object version. Default is false."
  default     = false
}

variable "lifecycle_rule_id" {
  type        = string
  description = "(Required) Unique identifier for the rule. The value cannot be longer than 255 characters."
  default     = "lifecycle_rule"
}

variable "lifecycle_rule_enabled" {
  type        = string
  description = "(Required) Whether the rule is currently being applied. Valid values: Enabled or Disabled."
  default     = "Disabled"
  validation {
    condition     = can(regex("Enabled|Disabled", var.lifecycle_rule_enabled))
    error_message = "The value must be Enabled or Disabled."
  }
}

variable "lifecycle_rule_prefix" {
  type        = string
  description = "(Optional) Prefix identifying one or more objects to which the rule applies. Defaults to an empty string if not specified."
  default     = null
}

variable "lifecycle_expiration_days" {
  type        = number
  description = "(Optional, Conflicts with date) The number of days after creation when objects are transitioned to the specified storage class. The value must be a positive integer. If both days and date are not specified, defaults to 0. Valid values depend on storage_class, see Transition objects using Amazon S3 Lifecycle for more details."
  default     = null
  validation {
    condition     = can(regex("^[0-9]+$", var.lifecycle_expiration_days))
    error_message = "The value must be a positive integer."
  }
}

######################
# Global Variables
######################

variable "tags" {
  type        = map(any)
  description = "(Optional) A mapping of tags to assign to the bucket."
  default = {
    created_by  = "<YOUR NAME>"
    environment = "prod"
    terraform   = "true"
  }
}
