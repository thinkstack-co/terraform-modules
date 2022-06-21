##############################
# Terraform Team
##############################
variable "name" {
  description = "(Required) Name of the team."
  type        = string
}

variable "organization" {
  description = "(Required) Name of the organization."
  type        = string
}

variable "visibility" {
  description = "(Optional) The visibility of the team ('secret' or 'organization'). Defaults to 'secret'."
  type        = string
  default     = "secret"
}

variable "sso_team_id" {
  description = "(Optional) Unique Identifier to control team membership via SAML. Defaults to null"
  type        = string
  default     = null
}

variable "manage_policies" {
  description = "(Optional) Allows members to create, edit, and delete the organization's Sentinel policies."
  type        = bool
  default     = false
}

variable "manage_policy_overrides" {
  description = "(Optional) Allows members to override soft-mandatory policy checks."
  type        = bool
  default     = false
}

variable "manage_workspaces" {
  description = "(Optional) Allows members to create and administrate all workspaces within the organization."
  type        = bool
  default     = false
}

variable "manage_vcs_settings" {
  description = "(Optional) Allows members to manage the organization's VCS Providers and SSH keys."
  type        = bool
  default     = false
}

variable "manage_providers" {
  description = "(Optional) Allow members to publish and delete providers in the organization's private registry."
  type        = bool
  default     = false
}

variable "manage_modules" {
  description = "(Optional) Allow members to publish and delete modules in the organization's private registry."
  type        = bool
  default     = false
}
