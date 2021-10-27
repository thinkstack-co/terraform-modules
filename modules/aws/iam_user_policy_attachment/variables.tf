variable "policy_arn" {
  type        = string
  description = "(Required) - The ARN of the policy you want to apply"
}

variable "user" {
  type        = string
  description = "(Required) - The user the policy should be applied to"
}
