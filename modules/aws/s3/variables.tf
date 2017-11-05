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
    default     = false
}
