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

variable "tags" {
  description = "Tags applied to all resources."
  type        = map(string)
  default     = {}
}
