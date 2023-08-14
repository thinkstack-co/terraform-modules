#################
# BUCKET
#################

variable "bucket_name_prefix" {
  description = "The bucket name prefix for the S3 bucket."
  type        = string
}

variable "bucket_acl" {
  description = "The canned ACL for the S3 bucket."
  type        = string
  default     = "private"
}

variable "destroy_objects_with_bucket" {
  description = "Determines if objects should be destroyed when bucket is destroyed."
  type        = bool
  default     = false
}

########################
# BLOCK PUBLIC ACCESS
########################

variable "enable_public_access_block" {
  description = "Flag to enable or disable public access block."
  type        = bool
  default     = true
}

variable "block_public_acls" {
  description = "Whether Amazon S3 should block public ACLs for the bucket."
  type        = bool
  default     = true
}

variable "block_public_policy" {
  description = "Whether Amazon S3 should block public bucket policies for the bucket."
  type        = bool
  default     = true
}

variable "ignore_public_acls" {
  description = "Whether Amazon S3 should ignore public ACLs for the bucket."
  type        = bool
  default     = true
}

variable "restrict_public_buckets" {
  description = "Whether Amazon S3 should restrict public bucket policies for the bucket."
  type        = bool
  default     = true
}

#######################
# VERSIONING
#######################

variable "enable_versioning" {
  description = "Flag to enable or disable versioning for the S3 bucket."
  type        = bool
  default     = false
}

variable "mfa_delete" {
  description = "Flag to enable or disable MFA delete."
  type        = bool
  default     = false
}

#####################
# ACCELERATION
#####################

variable "enable_acceleration" {
  description = "Flag to enable or disable acceleration for the S3 bucket."
  type        = bool
  default     = false
}

variable "accelerate_status" {
  description = "The accelerate status of the bucket, 'Enabled' or 'Suspended'."
  type        = string
  default     = "Suspended"
}

######################
# INTELLIGENT TIERING
######################

variable "enable_intelligent_tiering" {
  description = "Flag to enable or disable intelligent tiering for the S3 bucket."
  type        = bool
  default     = false
}

variable "tiering_config_id" {
  description = "The unique ID for the intelligent tiering configuration."
  type        = string
}

variable "filter_prefix" {
  description = "Only objects with this prefix will be considered for intelligent tiering."
  type        = string
}

# Variables to allow users to enable or disable the optional archive tiers
variable "enable_intelligent_tiering_archive_access" {
  description = "Enable the Archive Access tier in Intelligent Tiering"
  type        = bool
  default     = false  # By default, set to false. Users can change this to true to enable the tier.
}

variable "enable_intelligent_tiering_deep_archive_access" {
  description = "Enable the Deep Archive Access tier in Intelligent Tiering"
  type        = bool
  default     = false  # By default, set to false. Users can change this to true to enable the tier.
}

############################
# LIFECYCLE CONFIGURATION
############################

variable "enable_lifecycle_configuration" {
  description = "Flag to enable or disable lifecycle configuration."
  type        = bool
  default     = false
}

variable "lifecycle_rule_id" {
  description = "The ID for the lifecycle rule."
  type        = string
}

# Variables for enabling each storage class tier

variable "enable_standard_ia" {
  description = "Enable transition to STANDARD_IA storage class"
  type        = bool
  default     = true
}

variable "enable_onezone_ia" {
  description = "Enable transition to ONEZONE_IA storage class"
  type        = bool
  default     = false
}

variable "enable_glacier_instant" {
  description = "Enable transition to GLACIER_INSTANT_RETRIEVAL storage class"
  type        = bool
  default     = false
}

variable "enable_glacier_flexible" {
  description = "Enable transition to GLACIER_FLEXIBLE_RETRIEVAL storage class"
  type        = bool
  default     = true
}

variable "enable_deep_archive" {
  description = "Enable transition to DEEP_ARCHIVE storage class"
  type        = bool
  default     = true
}

variable "days_to_standard_ia" {
  description = "Number of days to transition to STANDARD_IA storage class"
  default     = 30
  
  # Validation to ensure days are >= 30
  validation {
    condition     = var.days_to_standard_ia >= 30
    error_message = "Days to transition to STANDARD_IA must be at least 30."
  }
}

variable "days_to_onezone_ia" {
  description = "Number of days to transition to ONEZONE_IA storage class"
  default     = 30

  # Validation to ensure days are >= 30
  validation {
    condition     = var.days_to_onezone_ia >= 30
    error_message = "Days to transition to ONEZONE_IA must be at least 30."
  }
}

variable "days_to_glacier_instant" {
  description = "Number of days to transition to GLACIER_INSTANT_RETRIEVAL storage class"
  default     = 90

  # Validation to ensure days are >= 90
  validation {
    condition     = var.days_to_glacier_instant >= 90
    error_message = "Days to transition to GLACIER_INSTANT_RETRIEVAL must be at least 90."
  }
}

variable "days_to_glacier_flexible" {
  description = "Number of days to transition to GLACIER_FLEXIBLE_RETRIEVAL storage class"
  default     = 90

  # Validation to ensure days are >= 90
  validation {
    condition     = var.days_to_glacier_flexible >= 90
    error_message = "Days to transition to GLACIER_FLEXIBLE_RETRIEVAL must be at least 90."
  }
}

variable "days_to_deep_archive" {
  description = "Number of days to transition to DEEP_ARCHIVE storage class"
  default     = 180

  # Validation to ensure days are >= 180
  validation {
    condition     = var.days_to_deep_archive >= 180
    error_message = "Days to transition to DEEP_ARCHIVE must be at least 180."
  }
}

##############
# SSE
##############

variable "create_kms_key" {
  description = "Determines if a new KMS key should be created for server-side encryption."
  type        = bool
  default     = false
}

variable "sse_algorithm" {
  description = "Server side encryption algorithm to use on the S3 bucket. Valid values are 'AES256' for SSE-S3 or 'aws:kms' for SSE-KMS."
  type        = string
  default     = "AES256"
}

variable "kms_master_key_id" {
  description = "AWS KMS master key ID used for the SSE-KMS encryption. Only used when 'sse_algorithm' is set to 'aws:kms'. Defaults to the S3 service master key if not provided."
  type        = string
  default     = null  # Default AWS S3 KMS master key
}

variable "bucket_key_enabled" {
  description = "Whether or not to use Amazon S3 Bucket Keys for SSE-KMS."
  type        = bool
  default     = false
}

variable "create_kms_key" {
  description = "Flag to determine if a KMS key should be created for SSE."
  type        = bool
  default     = false
}

##################
# REPLICATION
##################

variable "enable_replication" {
  description = "Flag to enable or disable replication."
  type        = bool
  default     = false
}

variable "replication_rule_id" {
  description = "The ID for the replication rule."
  type        = string
}

variable "replication_rule_status" {
  description = "The status for the replication rule."
  type        = string
}

variable "create_destination_bucket" {
  description = "Flag to create a destination bucket for replication."
  type        = bool
  default     = false
}

variable "target_bucket_arn" {
  description = "The ARN for the target bucket for replication."
  type        = string
}

variable "replication_storage_class" {
  description = "The storage class for replication."
  type        = string
}

variable "destination_bucket_name" {
  description = "The name for the destination bucket."
  type        = string
}

variable "destination_bucket_acl" {
  description = "The ACL for the destination bucket."
  type        = string
}

variable "destination_bucket_mfa_delete" {
  description = "Flag to enable or disable MFA delete for the destination bucket."
  type        = bool
  default     = false
}
