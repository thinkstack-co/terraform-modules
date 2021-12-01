variable "bucket_prefix" {
  description = "(Optional, Forces new resource) Creates a unique bucket name beginning with the specified prefix. Conflicts with bucket."
}

variable "acl" {
  description = "(Optional) The canned ACL to apply. Defaults to 'private'."
  default     = "private"
}

variable "enabled" {
  description = "(Optional) Enable versioning. Once you version-enable a bucket, it can never return to an unversioned state. You can, however, suspend versioning on that bucket."
  default     = true
}

variable "kms_master_key_id" {
  type        = string
  description = "(optional) The AWS KMS master key ID used for the SSE-KMS encryption. This can only be used when you set the value of sse_algorithm as aws:kms. The default aws/s3 AWS KMS master key is used if this element is absent while the sse_algorithm is aws:kms."
  default     = ""
}

variable "sse_algorithm" {
  type        = string
  description = "(required) The server-side encryption algorithm to use. Valid values are AES256 and aws:kms"
  default     = "aws:kms"
}

variable "mfa_delete" {
  description = "(Optional) Enable MFA delete for either Change the versioning state of your bucket or Permanently delete an object version. Default is false."
  default     = true
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
