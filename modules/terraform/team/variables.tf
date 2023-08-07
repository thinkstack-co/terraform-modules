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

variable "manage_run_tasks" {
  description = "(Optional) Allow members to create, edit, and delete the organization's run tasks."
  type        = bool
  default     = false
}

variable "manage_projects" {
  description = "(Optional) Allow members to create and administrate all projects within the organization. Requires manage_workspaces to be set to true."
  type        = bool
  default     = true
}

variable "manage_membership" {
  description = "(Optional) Allow members to add/remove users from the organization, and to add/remove users from visible teams."
  type        = bool
  default     = true
}

variable "read_workspaces" {
  description = "(Optional) Allow members to view all workspaces in this organization."
  type        = bool
  default     = true
}

variable "read_projects" {
  description = "(Optional) Allow members to view all workspaces in this organization."
  type        = bool
  default     = true
}
