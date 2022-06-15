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

variable "lifecycle_rule_id" {
  type        = string
  description = "(Required) Unique identifier for the rule. The value cannot be longer than 255 characters."
  default     = null
}

variable "lifecycle_rule_enabled" {
  type        = string
  description = "(Required) Whether the rule is currently being applied. Valid values: Enabled or Disabled."
  default     = "disabled"
}

variable "lifecycle_rule_prefix" {
  type        = string
  description = "(Optional) Prefix identifying one or more objects to which the rule applies. Defaults to an empty string if not specified."
  default     = ""
}

variable "lifecycle_expiration_days" {
  type        = number
  description = "(Optional, Conflicts with date) The number of days after creation when objects are transitioned to the specified storage class. The value must be a positive integer. If both days and date are not specified, defaults to 0. Valid values depend on storage_class, see Transition objects using Amazon S3 Lifecycle for more details."
  default     = null
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
