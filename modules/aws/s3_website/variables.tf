variable "bucket_prefix" {
  description = "(Required, Forces new resource) Creates a unique bucket name beginning with the specified prefix. Conflicts with bucket."
}

variable "policy" {
  description = "(Optional) The text of the policy. Although this is a bucket policy rather than an IAM policy, the aws_iam_policy_document data source may be used, so long as it specifies a principal. For more information about building AWS IAM policy documents with Terraform, see the AWS IAM Policy Document Guide. Note: Bucket policies are limited to 20 KB in size."
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