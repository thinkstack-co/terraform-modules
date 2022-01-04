variable "acl" {
  description = "(Optional) The canned ACL to apply. Defaults to private."
  default     = "private"
}

variable "bucket_prefix" {
  description = "(Optional, Forces new resource) Creates a unique bucket name beginning with the specified prefix. Conflicts with bucket."
}

variable "kms_master_key_id" {
  type        = string
  description = "(optional) The AWS KMS master key ID used for the SSE-KMS encryption. This can only be used when you set the value of sse_algorithm as aws:kms. The default aws/s3 AWS KMS master key is used if this element is absent while the sse_algorithm is aws:kms."
  default     = ""
}

variable "policy" {
  description = "(Optional) A valid bucket policy JSON document. Note that if the policy document is not specific enough (but still valid), Terraform may view the policy as constantly changing in a terraform plan. In this case, please make sure you use the verbose/specific version of the policy."
  default     = ""
}

variable "sse_algorithm" {
  type        = string
  description = "(required) The server-side encryption algorithm to use. Valid values are AES256 and aws:kms"
  default     = "aws:kms"
}

variable "tags" {
  type        = map
  description = "(Optional) A mapping of tags to assign to the bucket."
  default = {
    created_by  = "Zachary Hill"
    environment = "prod"
    terraform   = "true"
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

variable "lifecycle_infrequent_storage_transition_enabled" {
  type        = bool
  default     = true
  description = "Specifies infrequent storage transition lifecycle rule status."
}

variable "lifecycle_infrequent_storage_object_prefix" {
  type        = string
  default     = ""
  description = "Object key prefix identifying one or more objects to which the lifecycle rule applies."
  #sensitive   = true
}

variable "lifecycle_days_to_infrequent_storage_transition" {
  type        = number
  default     = 30
  description = "Specifies the number of days after object creation when it will be moved to standard infrequent access storage."
}

variable "lifecycle_glacier_transition_enabled" {
  type        = bool
  default     = true
  description = "Specifies Glacier transition lifecycle rule status."
}

variable "lifecycle_glacier_object_prefix" {
  type        = string
  default     = ""
  description = "Object key prefix identifying one or more objects to which the lifecycle rule applies."
  #sensitive   = true
}

variable "lifecycle_days_to_glacier_transition" {
  type        = number
  default     = 90
  description = "Specifies the number of days after object creation when it will be moved to Glacier storage."
}

variable "lifecycle_deep_archive_transition_enabled" {
  type        = bool
  default     = true
  description = "Specifies Deep Archive transition lifecycle rule status."
}

variable "lifecycle_deep_archive_object_prefix" {
  type        = string
  default     = ""
  description = "Object key prefix identifying one or more objects to which the lifecycle rule applies."
  #sensitive   = true
}

variable "lifecycle_days_to_deep_archive_transition" {
  type        = number
  default     = 120
  description = "Specifies the number of days after object creation when it will be moved to Glacier storage."
}