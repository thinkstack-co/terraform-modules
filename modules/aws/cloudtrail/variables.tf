###########################
# KMS Encryption Key
###########################

variable "cloudtrail_key_customer_master_key_spec" {
    description = "(Optional) Specifies whether the key contains a symmetric key or an asymmetric key pair and the encryption algorithms or signing algorithms that the key supports. Valid values: SYMMETRIC_DEFAULT, RSA_2048, RSA_3072, RSA_4096, ECC_NIST_P256, ECC_NIST_P384, ECC_NIST_P521, or ECC_SECG_P256K1. Defaults to SYMMETRIC_DEFAULT. For help with choosing a key spec, see the AWS KMS Developer Guide."
    default     = "SYMMETRIC_DEFAULT"
    type        = string
}

variable "cloudtrail_key_description" {
    description = "(Optional) The description of the key as viewed in AWS console."
    default     = "Cloudtrail kms key used to encrypt logs"
    type        = string
}

variable "cloudtrail_key_deletion_window_in_days" {
    description = "(Optional) Duration in days after which the key is deleted after destruction of the resource, must be between 7 and 30 days. Defaults to 30 days."
    default     = 30
    type        = number
}

variable "cloudtrail_key_enable_key_rotation" {
  description = "(Optional) Specifies whether key rotation is enabled. Defaults to false."
  default     = true
  type        = bool
}

variable "cloudtrail_key_usage" {
  description = "(Optional) Specifies the intended use of the key. Defaults to ENCRYPT_DECRYPT, and only symmetric encryption and decryption are supported."
  default     = "ENCRYPT_DECRYPT"
  type        = string
}

variable "cloudtrail_key_is_enabled" {
  description = "(Optional) Specifies whether the key is enabled. Defaults to true."
  default     = true
  type        = string
}

variable "cloudtrail_key_name_prefix" {
  description = "(Optional) Creates an unique alias beginning with the specified prefix. The name must start with the word alias followed by a forward slash (alias/)."
  default     = "alias/cloudtrail_logs_key_"
  type        = string
}


######################
# S3 Variables
######################

variable "bucket_prefix" {
  description = "(Optional, Forces new resource) Creates a unique bucket name beginning with the specified prefix. Conflicts with bucket."
}

variable "acl" {
  description = "(Optional) The canned ACL to apply. Defaults to 'private'."
  default     = "private"
}

variable "bucket_lifecycle_rule_id" {
  type        = string
  description = "(Required) Unique identifier for the rule. The value cannot be longer than 255 characters."
  default     = "365_day_delete"
}

variable "bucket_lifecycle_expiration_days" {
  type        = number
  description = "(Optional) The lifetime, in days, of the objects that are subject to the rule. The value must be a non-zero positive integer."
  default     = 365
}

variable "versioning_status" {
  type        = string
  description = "(Required) The versioning state of the bucket. Valid values: Enabled, Suspended, or Disabled. Disabled should only be used when creating or importing resources that correspond to unversioned S3 buckets."
  default     = "Enabled"
}

variable "bucket_key_enabled" {
  type        = bool
  description = "(Optional) Whether or not to use Amazon S3 Bucket Keys for SSE-KMS."
  default     = true
}

variable "kms_master_key_id" {
  type        = string
  description = "(Optional) The AWS KMS master key ID used for the SSE-KMS encryption. This can only be used when you set the value of sse_algorithm as aws:kms. The default aws/s3 AWS KMS master key is used if this element is absent while the sse_algorithm is aws:kms."
  default     = ""
}

variable "sse_algorithm" {
  type        = string
  description = "(Required) The server-side encryption algorithm to use. Valid values are AES256 and aws:kms"
  default     = "aws:kms"
}

variable "mfa_delete" {
  type        = string
  description = "(Optional) Specifies whether MFA delete is enabled in the bucket versioning configuration. Valid values: Enabled or Disabled."
  default     = "Disabled"
}

variable "name" {
  description = "Name of the trail"
  default     = "cloudtrail"
}

variable "s3_key_prefix" {
  description = "S3 key prefix to be applied to all logs"
  default     = "cloudtrail-logs"
}

variable "include_global_service_events" {
  description = "Specifies whether the trail is publishing events from global services such as IAM to the log files"
  default     = true
}

variable "is_multi_region_trail" {
  description = "Determines whether or not the cloudtrail is created for all regions"
  default     = true
}

variable "kms_key_id" {
  description = "KMS key used to encrypt the cloudtrail logs"
  default     = ""
}

variable "enable_log_file_validation" {
  description = "Enabled log file validation to all logs sent to S3"
  default     = true
}

######################
# Global Variables
######################

variable "tags" {
  type        = map
  description = "(Optional) A mapping of tags to assign to the resource."
  default     = null
}
