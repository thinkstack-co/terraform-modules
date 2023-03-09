############################################################
# AWS Organization Account
############################################################

variable "name" {
  description = "(Required) A friendly name for the member account."
  type        = string
}

variable "email" {
  description = "(Required) The email address of the owner to assign to the new member account. This email address must not already be associated with another AWS account."
  type        = string
}

variable "iam_user_access_to_billing" {
  description = "(Optional) If set to ALLOW, the new account enables IAM users to access account billing information if they have the required permissions. If set to DENY, then only the root user of the new account can access account billing information."
  type        = string
  default     = "ALLOW"
}

variable "parent_id" {
  description = "(Optional) Parent Organizational Unit ID or Root ID for the account. Defaults to the Organization default Root ID. A configuration must be present for this argument to perform drift detection."
  type        = string
  default     = null
}

variable "role_name" {
  description = "(Optional) The name of an IAM role that Organizations automatically preconfigures in the new member account. This role trusts the master account, allowing users in the master account to assume the role, as permitted by the master account administrator. The role has administrator permissions in the new member account. The Organizations API provides no method for reading this information after account creation, so Terraform cannot perform drift detection on its value and will always show a difference for a configured value after import unless ignore_changes is used."
  type        = string
  default     = "ThinkStackOrganizationAccountAccessRole"
}

variable "close_on_deletion" {
  description = "(Optional) If true, a deletion event will close the account. Otherwise, it will only remove from the organization."
  type        = bool
  default     = false
}

variable "tags" {
  description = "(Optional) Key-value map of resource tags. If configured with a provider default_tags configuration block present, tags with matching keys will overwrite those defined at the provider-level."
  type        = map(any)
  default     = {}
}
