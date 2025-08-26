variable "destination_policy_access_policy" {
  type        = string
  description = "The access policy for the destination policy"
}

variable "iam_policy_description" {
  type        = string
  description = "The description for the IAM policy"
}

variable "iam_policy_name_prefix" {
  type        = string
  description = "The name prefix for the IAM policy"
}

variable "iam_policy_path" {
  type        = string
  description = "The path for the IAM policy"
}

variable "tags" {
  type        = map(string)
  description = "The tags for the IAM policy"
}

variable "iam_role_assume_role_policy" {
  type        = string
  description = "The assume role policy for the IAM role"
}

variable "iam_role_description" {
  type        = string
  description = "The description for the IAM role"
}

variable "iam_role_force_detach_policies" {
  type        = bool
  description = "The force detach policies for the IAM role"
}

variable "iam_role_max_session_duration" {
  type        = number
  description = "The maximum session duration for the IAM role"
}

variable "iam_role_name_prefix" {
  type        = string
  description = "The name prefix for the IAM role"
}

variable "iam_role_permissions_boundary" {
  type        = string
  description = "The permissions boundary for the IAM role"
}

variable "destination_name" {
  type        = string
  description = "The name for the destination"
}

variable "destination_target_arn" {
  type        = string
  description = "The target ARN for the destination"
}

variable "iam_for_cloudwatch" {
  type        = string
  description = "The IAM role for CloudWatch"
}
