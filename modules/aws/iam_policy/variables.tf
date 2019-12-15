variable "description" {
  type        = string
  description = "(Optional, Forces new resource) Description of the IAM policy."
}

variable "name" {
  type        = string
  description = "(Optional, Forces new resource) The name of the policy. If omitted, Terraform will assign a random, unique name."
}

variable "path" {
  type        = string
  description = "(Optional, default '/') Path in which to create the policy. See IAM Identifiers for more information."
  default     = "/"
}

variable "policy" {
  type        = string
  description = "(Required) The policy document. This is a JSON formatted string. The heredoc syntax, file function, or the aws_iam_policy_document data source are all helpful here."
}
