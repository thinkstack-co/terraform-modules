variable "bucket_prefix" {
  description = "(Required, Forces new resource) Creates a unique bucket name beginning with the specified prefix. Conflicts with bucket."
}

variable "policy" {
  description = "(Optional) A valid bucket policy JSON document. Note that if the policy document is not specific enough (but still valid), Terraform may view the policy as constantly changing in a terraform plan. In this case, please make sure you use the verbose/specific version of the policy."
  default     = null
}

variable "tags" {
  type        = map
  description = "(Optional) A mapping of tags to assign to the bucket."
  default     = {
    created_by  = "Jake Jones"
    environment = "prod"
    terraform   = "true"
  }
}

variable "index_document" {
  description = "(Required, unless using redirect_all_requests_to) Amazon S3 returns this index document when requests are made to the root domain or any of the subfolders."
  default     = "index.html"
}

variable "error_document" {
  description = "(Optional) An absolute path to the document to return in case of a 4XX error."
  default     = "error.html"
}