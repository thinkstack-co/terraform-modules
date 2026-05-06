variable "tenant_id" {
  description = "Entra ID tenant ID."
  type        = string
}

variable "subscription_id" {
  description = "Azure subscription ID for RBAC assignments."
  type        = string
}

variable "customer_name" {
  description = "Short customer name used in group display names (e.g., 'acme')."
  type        = string
}

variable "admin_upns" {
  description = "List of UPNs to add as initial members of the Global Admin PIM group."
  type        = list(string)
  default     = []
}

variable "mfa_exempt_group_ids" {
  description = "Object IDs of groups excluded from the Require MFA conditional access policy (e.g., break-glass accounts)."
  type        = list(string)
  default     = []
}

variable "license_name" {
  description = "License name(s) used in the Licensed Users group display name (e.g., [\"Microsoft 365 Business Premium\"])."
  type        = list(string)
}

variable "msp_company_name" {
  description = "MSP company name included in the SSPR dynamic group rule."
  type        = string
  default     = "Network Coverage"
}

variable "secure_enclave_ips" {
  description = "IPv4 addresses for the Secure Enclave trusted named location."
  type        = list(string)
}

variable "excluded_user_ids" {
  description = "User object IDs excluded from secure access CA policies (e.g., break-glass accounts)."
  type        = list(string)
  default     = []
}

variable "tags" {
  description = "Tags applied to all resources."
  type        = map(string)
  default     = {}
}
