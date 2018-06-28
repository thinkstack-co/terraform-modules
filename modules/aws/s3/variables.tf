variable "acl" {
    description = "(Optional) The canned ACL to apply. Defaults to private."
    default     = "private"
}

variable "bucket_prefix" {
    description = "(Optional, Forces new resource) Creates a unique bucket name beginning with the specified prefix. Conflicts with bucket."
}

variable "policy" {
  description = "(Optional) A valid bucket policy JSON document. Note that if the policy document is not specific enough (but still valid), Terraform may view the policy as constantly changing in a terraform plan. In this case, please make sure you use the verbose/specific version of the policy."
  default     = ""
}

variable "region" {
    description = "(Optional) If specified, the AWS region this bucket should reside in. Otherwise, the region used by the callee."
}

variable "versioning" {
    description = "(Optional) A state of versioning (documented below)"
    default     = true
}

variable "mfa_delete" {
    description = "(Optional) Enable MFA delete for either Change the versioning state of your bucket or Permanently delete an object version. Default is false."
    default     = false
}
