###########################
# KMS Variables
###########################

variable "key_customer_master_key_spec" {
  type        = string
  description = "(Optional) Specifies whether the key contains a symmetric key or an asymmetric key pair and the encryption algorithms or signing algorithms that the key supports. Valid values: SYMMETRIC_DEFAULT, RSA_2048, RSA_3072, RSA_4096, ECC_NIST_P256, ECC_NIST_P384, ECC_NIST_P521, or ECC_SECG_P256K1. Defaults to SYMMETRIC_DEFAULT. For help with choosing a key spec, see the AWS KMS Developer Guide."
  default     = "SYMMETRIC_DEFAULT"
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
  type        = bool
  description = "(Optional) Specifies whether key rotation is enabled. Defaults to false."
  default     = true
}

variable "key_usage" {
  type        = string
  description = "(Optional) Specifies the intended use of the key. Defaults to ENCRYPT_DECRYPT, and only symmetric encryption and decryption are supported."
  default     = "ENCRYPT_DECRYPT"
}

variable "key_is_enabled" {
  type        = string
  description = "(Optional) Specifies whether the key is enabled. Defaults to true."
  default     = true

}

variable "key_policy" {
  type        = string
  description = "(Optional) A valid policy JSON document. Although this is a key policy, not an IAM policy, an aws_iam_policy_document, in the form that designates a principal, can be used. For more information about building policy documents with Terraform, see the AWS IAM Policy Document Guide."
  default     = ""

}

variable "key_name_prefix" {
  type        = string
  description = "(Optional) Creates an unique alias beginning with the specified prefix. The name must start with the word alias followed by a forward slash (alias/)."
  default     = "alias/s3_key_"
}

######################
# S3 Bucket Variables
######################
variable "bucket_prefix" {
  type        = string
  description = "(Required, Forces new resource) Creates a unique bucket name beginning with the specified prefix. Conflicts with bucket."
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

variable "lifecycle_rules" {
  type = list(object({
    id     = string
    status = string
    rule   = object
  }))
  description = "(Optional) Configuration of object lifecycle management (LCM). Can have several rules."
  default     = null
}

######################
# S3 Logging Variables
######################

variable "logging_target_bucket" {
  type        = string
  description = "(Optional) The name of the bucket that will receive the logs. Required if logging of the S3 bucket is set to true."
  default     = null
  validation {
    condition     = can(regex("^[a-z0-9][a-z0-9\\-\\.]{1,61}[a-z0-9]$", var.logging_target_bucket)) || var.logging_target_bucket == null
    error_message = "The value must be a valid bucket name or null."
  }
}

variable "logging_target_prefix" {
  type        = string
  description = "(Optional) The prefix that is prepended to all log object keys. If not set, the logs are stored in the root of the bucket."
  default     = "log/"
}

######################
# S3 Policy Variables
######################

variable "bucket_policy" {
  type        = string
  description = "(Optional) Text of the policy. Although this is a bucket policy rather than an IAM policy, the aws_iam_policy_document data source may be used, so long as it specifies a principal. For more information about building AWS IAM policy documents with Terraform, see the AWS IAM Policy Document Guide. Note: Bucket policies are limited to 20 KB in size."
  default     = null
}

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

variable "bucket_key_enabled" {
  type        = bool
  description = "(Optional) Specifies whether Amazon S3 should use an S3 bucket key for object encryption with server-side encryption using AWS KMS (SSE-KMS). Setting this element to true causes the following behavior: When an object is uploaded, the S3 bucket key is used to encrypt the object. When an object is overwritten, the S3 bucket key is re-used to encrypt the object. When an object is copied, the S3 bucket key is re-used to encrypt the object. When an object is restored from Amazon Glacier, the S3 bucket key is re-used to encrypt the object. Defaults to true."
  default     = true
  validation {
    condition     = can(regex("true|false", var.bucket_key_enabled))
    error_message = "The value must be true or false."
  }
}

variable "sse_algorithm" {
  type        = string
  description = "(Optional) The server-side encryption algorithm to use. Valid values are AES256 and aws:kms"
  default     = "aws:kms"
  validation {
    condition     = can(regex("AES256|aws:kms", var.sse_algorithm))
    error_message = "The value must be AES256 or aws:kms."
  }
}

######################
# S3 Versioning Variables
######################

variable "versioning_status" {
  type        = string
  description = "(Optional) Versioning state of the bucket. Valid values: Enabled, Suspended, or Disabled. Disabled should only be used when creating or importing resources that correspond to unversioned S3 buckets."
  default     = "Disabled"
  validation {
    condition     = can(regex("Enabled|Suspended|Disabled", var.versioning_status))
    error_message = "The value must be Enabled, Disabled, or Suspended."
  }
}

variable "mfa_delete" {
  type        = string
  description = "(Optional) Specifies whether MFA delete is enabled in the bucket versioning configuration. Valid values: Enabled or Disabled."
  default     = "Disabled"
  validation {
    condition     = can(regex("Enabled|Disabled", var.mfa_delete))
    error_message = "The value must be Enabled or Disabled."
  }
}

######################
# Global Variables
######################

variable "enable_s3_bucket_logging" {
  type        = bool
  description = "(Optional) Enable logging on the cloudtrail S3 bucket. If true, the 'target_bucket' is required. Defaults to false."
  default     = false
  validation {
    condition     = can(regex("true|false", var.enable_s3_bucket_logging))
    error_message = "The value must be true or false."
  }
}

variable "expected_bucket_owner" {
  type        = string
  description = "(Optional) Account ID of the expected bucket owner. If the bucket is owned by a different account, the request will fail with an HTTP 403 (Access Denied) error."
  default     = null
}

variable "tags" {
  type        = map(any)
  description = "(Optional) A mapping of tags to assign to the bucket."
  default = {
    created_by  = "<YOUR NAME>"
    environment = "prod"
    terraform   = "true"
  }
}
