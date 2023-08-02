###############
# KMS variables
###############

variable "key_description" {
  description = "The description of the key as viewed in AWS console."
  type        = string
  default     = "KMS key for cloudtrail"
}

variable "key_enable_key_rotation" {
  description = "Specifies whether key rotation is enabled."
  type        = bool
  default     = true
}

variable "key_customer_master_key_spec" {
  description = "Specifies whether the key contains a symmetric key or not."
  type        = string
  default     = "SYMMETRIC_DEFAULT"
}

variable "key_deletion_window_in_days" {
  description = "Duration in days after which the key is deleted after destruction of the resource, must be between 7 and 30 days."
  type        = number
  default     = 30
}

variable "key_policy" {
  description = "The key policy of the KMS key."
  type        = string
  default     = data.aws_iam_policy_document.key_policy.json
}

variable "key_usage" {
  description = "Specifies the intended use of the key."
  type        = string
  default     = "ENCRYPT_DECRYPT"
}

variable "key_is_enabled" {
  description = "Specifies whether the key is enabled."
  type        = bool
  default     = true
}

variable "key_tags" {
  description = "The tags attached to the KMS key."
  type        = map(string)
  default     = {}
}

variable "key_alias_name_prefix" {
  description = "The display name of the alias. The name must start with the word 'alias'."
  type        = string
  default     = "alias/cloudtrail/"
}

# CloudWatch Log Group variables
variable "log_group_name" {
  description = "The name of the log group in CloudWatch."
  type        = string
  default     = "cloudtrail"
}

variable "log_group_retention_in_days" {
  description = "Specifies the number of days you want to retain log events."
  type        = number
  default     = 30
}

######################
# IAM Policy variables
######################
variable "iam_policy_description" {
  description = "Description of the IAM policy."
  type        = string
  default     = "Policy for cloudtrail"
}

variable "iam_policy_name" {
  description = "Name of the IAM policy."
  type        = string
  default     = "cloudtrail_policy"
}

variable "iam_policy_path" {
  description = "Path in which to create the policy."
  type        = string
  default     = "/"
}

variable "iam_policy_json" {
  description = "The policy document in JSON format."
  type        = string
  default     = data.aws_iam_policy_document.cloudtrail.json
}

####################
# IAM Role variables
####################

variable "iam_role_assume_role_policy" {
  description = "The policy that grants an entity permission to assume the role."
  type        = string
  default     = data.aws_iam_policy_document.cloudtrail_assume.json 
}

variable "iam_role_description" {
  description = "The description of the role."
  type        = string
  default     = "Role for cloudtrail"
}

variable "iam_role_max_session_duration" {
  description = "The maximum session duration (in seconds) that you want to set for the specified role."
  type        = number
  default     = 3600
}

variable "iam_role_name" {
  description = "The name of the role."
  type        = string
  default     = "cloudtrail_role"
}

variable "iam_role_permissions_boundary" {
  description = "The ARN of the policy that is used to set the permissions boundary for the role."
  type        = string
  default     = null
}

variable "iam_role_force_detach_policies" {
  description = "Specifies to force detaching any policies the role has before destroying it."
  type        = bool
  default     = false
}

######################
# CloudTrail variables
######################

variable "cloudtrail_name" {
  description = "The name of the trail."
  type        = string
  default     = "cloudtrail"
}

variable "cloudtrail_s3_key_prefix" {
  description = "Specifies the S3 key prefix that comes after the name of the bucket you have designated for log file delivery."
  type        = string
  default     = "AWSLogs"
}

variable "cloudtrail_include_global_service_events" {
  description = "Specifies whether the trail is publishing events from global services."
  type        = bool
  default     = true
}

variable "cloudtrail_is_multi_region_trail" {
  description = "Specifies whether the trail is created in all regions."
  type        = bool
  default     = true
}

variable "cloudtrail_enable_log_file_validation" {
  description = "Specifies whether log file integrity validation is enabled."
  type        = bool
  default     = true
}

variable "encrypt_logs" {
  description = "Enable encryption for CloudTrail logs"
  type        = bool
  default     = true
}


#####################
# S3 bucket variables
#####################

variable "s3_bucket_prefix" {
  description = "Prefix for the S3 bucket where CloudTrail logs will be stored"
  default     = "cloudtrail-logs"
  type        = string
}

variable "s3_force_destroy" {
  description = "Whether all objects (including any locked objects) should be deleted from the bucket so that the bucket can be destroyed without error (e.g., when using object versioning)"
  default     = false
  type        = bool
}

variable "versioning_enabled" {
  description = "Enables versioning for the S3 bucket that stores CloudTrail logs. It's recommended to enable this to keep all versions of an object (including all writes and deletes) in the bucket."
  type        = bool
  default     = false
}

variable "mfa_delete_enabled" {
  description = "Enables MFA Delete for the S3 bucket that stores CloudTrail logs. It's recommended to enable this for additional layer of security. With this enabled, MFA will be required to permanently delete an object version or suspend versioning on the bucket."
  type        = bool
  default     = false
}

variable "lifecycle_rule_enabled" {
  description = "Enable or disable bucket transitions. If enabled, objects in the bucket will be transitioned to different storage classes (like STANDARD_IA or GLACIER) after the specified number of days."
  type        = bool
  default     = false
}

variable "transition_days_standard_ia" {
  description = "Number of days after which to move the data to the STANDARD_IA (Infrequent Access) storage tier"
  default     = 30
  type        = number
}

variable "transition_days_glacier" {
  description = "Number of days after which to move the data to the GLACIER storage tier"
  default     = 60
  type        = number
}

variable "noncurrent_version_transition_days_standard_ia" {
  description = "Number of days after which to move noncurrent versions of data to the STANDARD_IA storage tier"
  default     = 30
  type        = number
}

variable "noncurrent_version_transition_days_glacier" {
  description = "Number of days after which to move noncurrent versions of data to the GLACIER storage tier"
  default     = 60
  type        = number
}

variable "expiration_days" {
  description = "Number of days after which to expire the data"
  default     = 365
  type        = number
}

variable "noncurrent_version_expiration_days" {
  description = "Number of days after which to expire noncurrent versions of the data"
  default     = 365
  type        = number
}

