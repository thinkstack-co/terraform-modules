variable "role_name" {
  type        = string
  description = "Name of the IAM role"
}

variable "role_description" {
  type        = string
  description = "Description of the IAM role"
}

variable "trust_policy" {
  type        = string
  description = "Trust policy JSON"
}

variable "policy_arn" {
  type        = string
  description = "ARN of the policy to attach"
}

# No unused variable warnings found in this file, no changes needed.
