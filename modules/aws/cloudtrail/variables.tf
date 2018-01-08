variable "bucket_prefix" {
    description = "(Optional, Forces new resource) Creates a unique bucket name beginning with the specified prefix. Conflicts with bucket."
}

variable "region" {
    description = "(Optional) If specified, the AWS region this bucket should reside in. Otherwise, the region used by the callee."
}

variable "acl" {
    description = "(Optional) The canned ACL to apply. Defaults to 'private'."
    default     = "private"
}

variable "enabled" {
    description = "(Optional) Enable versioning. Once you version-enable a bucket, it can never return to an unversioned state. You can, however, suspend versioning on that bucket."
    default     = true
}

variable "mfa_delete" {
    description = "(Optional) Enable MFA delete for either Change the versioning state of your bucket or Permanently delete an object version. Default is false."
    default     = true
}

variable "name" {
    description = "Name of the trail"
    default     = "cloudtrail"
}

variable "prevent_destroy" {
    description = "(bool) - This flag provides extra protection against the destruction of a given resource. When this is set to true, any plan that includes a destroy of this resource will return an error message."
    default     = false
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
