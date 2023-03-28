############################################################
# AWS Organization
############################################################

variable "aws_service_access_principals" {
  description = "(Optional) List of AWS service principal names for which you want to enable integration with your organization. This is typically in the form of a URL, such as service-abbreviation.amazonaws.com. Organization must have feature_set set to ALL. For additional information, see the AWS Organizations User Guide."
  type        = list(string)
  default = [
    "account.amazonaws.com",
    "aws-artifact-account-sync.amazonaws.com",
    "backup.amazonaws.com",
    "cloudtrail.amazonaws.com",
    "health.amazonaws.com",
    "sso.amazonaws.com",
  ]
}

variable "enabled_policy_types" {
  description = "(Optional) List of Organizations policy types to enable in the Organization Root. Organization must have feature_set set to ALL. For additional information about valid policy types (e.g., AISERVICES_OPT_OUT_POLICY, BACKUP_POLICY, SERVICE_CONTROL_POLICY, and TAG_POLICY), see the AWS Organizations API Reference."
  type        = list(string)
  default     = null
}

variable "feature_set" {
  description = "(Optional) Specify 'ALL' (default) or 'CONSOLIDATED_BILLING'."
  type        = string
  default     = "ALL"
  validation {
    condition     = can(regex("ALL|CONSOLIDATED_BILLING", var.feature_set))
    error_message = "Value must be ALL or CONSOLIDATED_BILLING."
  }
}
