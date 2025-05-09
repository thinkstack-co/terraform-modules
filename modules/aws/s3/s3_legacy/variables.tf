variable "acl" {
  type        = string
  description = "(Optional) The canned ACL to apply. Defaults to private."
  default     = "private"
}

variable "bucket" {
  type        = string
  description = "(Required) The ARN of the S3 bucket where you want Amazon S3 to store replicas of the object identified by the rule."
}

variable "kms_master_key_id" {
  type        = string
  description = "(optional) The AWS KMS master key ID used for the SSE-KMS encryption. This can only be used when you set the value of sse_algorithm as aws:kms. The default aws/s3 AWS KMS master key is used if this element is absent while the sse_algorithm is aws:kms."
  default     = ""
}

variable "policy" {
  type        = string
  description = "(Optional) A valid bucket policy JSON document. Note that if the policy document is not specific enough (but still valid), Terraform may view the policy as constantly changing in a terraform plan. In this case, please make sure you use the verbose/specific version of the policy."
  default     = null
}

variable "sse_algorithm" {
  type        = string
  description = "(required) The server-side encryption algorithm to use. Valid values are AES256 and aws:kms"
  default     = "aws:kms"
}

variable "tags" {
  type        = map(any)
  description = "(Optional) A mapping of tags to assign to the bucket."
  default = {
    created_by  = "Zachary Hill"
    environment = "prod"
    terraform   = "true"
  }
}

# Removed unused variables flagged by tflint

variable "versioning" {
  type        = string
  description = "(Optional) A state of versioning (documented below)"
  default     = null
}

variable "mfa_delete" {
  type        = bool
  description = "(Optional) Enable MFA delete for either Change the versioning state of your bucket or Permanently delete an object version. Default is false."
  default     = false
}
