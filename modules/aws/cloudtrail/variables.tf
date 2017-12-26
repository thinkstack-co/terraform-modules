variable "s3_bucket_prefix" {
    description = "Prefix of the S3 bucket used to store terraform state files"
}

variable "s3_bucket_region" {
    description = "Region that the S3 bucket is located"
}

variable "s3_bucket_acl" {
    description = "Bucket ACL"
    default     = "private"
}

variable "s3_versioning" {
    description = "S3 bucket versioning"
    default     = true
}

variable "s3_mfa_delete" {
    description = "Require MFA to delete objects"
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
