###########################
# KMS Encryption Key
###########################

variable "key_customer_master_key_spec" {
    description = "(Optional) Specifies whether the key contains a symmetric key or an asymmetric key pair and the encryption algorithms or signing algorithms that the key supports. Valid values: SYMMETRIC_DEFAULT, RSA_2048, RSA_3072, RSA_4096, ECC_NIST_P256, ECC_NIST_P384, ECC_NIST_P521, or ECC_SECG_P256K1. Defaults to SYMMETRIC_DEFAULT. For help with choosing a key spec, see the AWS KMS Developer Guide."
    default     = "SYMMETRIC_DEFAULT"
    type        = string
}

variable "key_description" {
    description = "(Optional) The description of the key as viewed in AWS console."
    default     = "Cloudtrail kms key used to encrypt audit logs"
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

variable "key_name_prefix" {
  description = "(Optional) Creates an unique alias beginning with the specified prefix. The name must start with the word alias followed by a forward slash (alias/)."
  default     = "alias/cloudtrail_key_"
  type        = string
}

###########################
# S3 Bucket
###########################

variable "s3_bucket_prefix" {
  description = "(Optional, Forces new resource) Creates a unique bucket name beginning with the specified prefix. Conflicts with bucket."
  default     = "cloudtrail-"
  type        = string
}

variable "s3_versioning_enabled" {
  description = "(Optional) Enable versioning. Once you version-enable a bucket, it can never return to an unversioned state. You can, however, suspend versioning on that bucket."
  default     = false
}

variable "s3_mfa_delete" {
  description = "(Optional) Enable MFA delete for either Change the versioning state of your bucket or Permanently delete an object version. Default is false."
  default     = true
}

###########################
# Cloudtrail
###########################

variable "cloudtrail_enable_log_file_validation" {
  description = "(Optional) Whether log file integrity validation is enabled. Defaults to false."
  default     = true
  type        = bool
}

variable "cloudtrail_include_global_service_events" {
  description = "(Optional) Whether the trail is publishing events from global services such as IAM to the log files. Defaults to true."
  default     = true
  type        = bool
}

variable "cloudtrail_is_multi_region_trail" {
  description = "(Optional) Whether the trail is created in the current region or in all regions. Defaults to false."
  default     = true
  type        = bool
}

variable "cloudtrail_name" {
  description = "(Required) Name of the trail."
  default     = "cloudtrail"
  type        = string
}

variable "cloudtrail_s3_key_prefix" {
  description = "(Optional) S3 key prefix that follows the name of the bucket you have designated for log file delivery."
  default     = null
  type        = string
}

variable "cloudtrail_insight_type" {
  type        = list(string)
  description = "(Optional) Type of insights to log on a trail. The valid value is ApiCallRateInsight"
  default     = ["ApiCallRateInsight", "ApiErrorRateInsight"]
}

###########################
# General Use Variables
###########################

variable "tags" {
  description = "(Optional) A mapping of tags to assign to the object."
  default     = {
    terraform   = "true"
    created_by  = "ThinkStack"
    environment = "prod"
    priority    = "high"
  }
}