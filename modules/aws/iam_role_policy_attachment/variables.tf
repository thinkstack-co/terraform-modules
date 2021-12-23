variable "policy_arn" {
  type        = string
  description = "(Required) - The ARN of the policy you want to apply"
}

variable "role" {
  type        = string
  description = "(Required) - The role the policy should be applied to"
}
