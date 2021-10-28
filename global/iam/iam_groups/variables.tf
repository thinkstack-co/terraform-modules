variable "system_admins_description" {
  type        = string
  description = "(Optional, Forces new resource) Description of the IAM policy."
  default     = "System Admins Policy which allows for EC2 management, RDS management, snapshot management, and systems manager to name a few."
}

variable "system_admins_name" {
  type        = string
  description = "(Optional, Forces new resource) The name of the policy. If omitted, Terraform will assign a random, unique name."
  default     = "system_admins_policy"
}

variable "system_admins_path" {
  type        = string
  description = "(Optional, default '/') Path in which to create the policy. See IAM Identifiers for more information."
  default     = "/"
}

variable "powerusers_group_name" {
  description = "IAM group using the powerusers policy"
  default     = "power_users"
}

variable "billing_group_name" {
  description = "IAM group using the billing policy"
  default     = "billing_users"
}

variable "readonly_group_name" {
  description = "IAM group using the readonly policy"
  default     = "readonly_users"
}

variable "powerusers_policy_arn" {
  description = "IAM powerusers group arn"
  default     = "arn:aws:iam::aws:policy/PowerUserAccess"
}

variable "billing_policy_arn" {
  description = "IAM powerusers group arn"
  default     = "arn:aws:iam::aws:policy/job-function/Billing"
}

variable "readonly_policy_arn" {
  description = "IAM powerusers group arn"
  default     = "arn:aws:iam::aws:policy/ReadOnlyAccess"
}

variable "mfa_policy_arn" {
  description = "MFA json policy"
}

variable "sms_connector_group_name" {
  description = "Name of the SMS Connector group"
  default     = "sms_connectors"
}

variable "sms_connector_policy_arn" {
  description = "AWS Server Migration Service policy"
  default     = "arn:aws:iam::aws:policy/ServerMigrationConnector"
}

variable "system_admins_group_name" {
  description = "IAM group for System Admins which allows access to EC2, RDS, S3, VPC, and Systems Manager"
  default     = "system_admins"
}

variable "system_admins_policy_arn" {
  description = "IAM System Admins group arn"
  default     = "arn:aws:iam::aws:policy/PowerUserAccess"
}
