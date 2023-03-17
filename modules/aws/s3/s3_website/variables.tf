variable "bucket" {
  description = "(Required, Forces new resource) The name of the bucket. If omitted, Terraform will assign a random, unique name. Must be lowercase and less than or equal to 63 characters in length. A full list of bucket naming rules may be found here."
  type        = string
  validation {
    condition     = can(regex("^[a-z0-9][a-z0-9.\\-]{1,61}[a-z0-9]$", var.bucket))
    error_message = "The bucket name must be lowercase and less than or equal to 63 characters in length. A full list of bucket naming rules may be found in the AWS documentation."
  }
}

variable "policy" {
  type        = string
  description = "(Optional) The text of the policy. Although this is a bucket policy rather than an IAM policy, the aws_iam_policy_document data source may be used, so long as it specifies a principal. For more information about building AWS IAM policy documents with Terraform, see the AWS IAM Policy Document Guide. Note: Bucket policies are limited to 20 KB in size."
  default     = null
}

variable "tags" {
  type        = map(any)
  description = "(Optional) A mapping of tags to assign to the bucket."
  default = {
    created_by  = "Jake Jones"
    environment = "prod"
    terraform   = "true"
  }
}

variable "index_document" {
  description = "(Required, unless using redirect_all_requests_to) Amazon S3 returns this index document when requests are made to the root domain or any of the subfolders."
  type        = string
  default     = "index.html"
}

variable "error_document" {
  description = "(Optional) An absolute path to the document to return in case of a 4XX error."
  type        = string
  default     = "error.html"
}