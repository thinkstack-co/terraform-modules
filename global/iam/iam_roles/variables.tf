variable "role_name" {
  description = "Name of the role"
}

variable "role_description" {
  description = "Description of the role"
}

variable "trust_policy" {
  description = "Role trust policy"
}

variable "policy_arn" {
  description = "arn of the policy document to attach to the role"
}
