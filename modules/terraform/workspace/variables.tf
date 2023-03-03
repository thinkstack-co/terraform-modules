##############################
# Terraform Workspace
##############################

variable "agent_pool_id" {
  description = "(Optional) The ID of an agent pool to assign to the workspace. Requires execution_mode to be set to agent. This value must not be provided if execution_mode is set to any other value or if operations is provided."
  type        = string
  default     = null
}

variable "allow_destroy_plan" {
  description = "(Optional) Whether destroy plans can be queued on the workspace."
  type        = bool
  default     = false
}

variable "auto_apply" {
  description = "(Optional) Whether to automatically apply changes when a Terraform plan is successful. Defaults to false."
  type        = bool
  default     = false
}

variable "assessments_enabled" {
  description = "(Optional) Whether to regularly run health assessments such as drift detection on the workspace. Defaults to true."
  type        = bool
  default     = true
}

variable "description" {
  description = "(Optional) A description for the workspace."
  type        = string
  default     = null
}

variable "execution_mode" {
  description = "(Optional) Which execution mode to use. Using Terraform Cloud, valid values are remote, local oragent. Defaults to remote. Using Terraform Enterprise, only remoteand local execution modes are valid. When set to local, the workspace will be used for state storage only. This value must not be provided if operations is provided."
  type        = string
  default     = "remote"
}

variable "file_triggers_enabled" {
  description = "(Optional) Whether to filter runs based on the changed files in a VCS push. Defaults to false. If enabled, the working directory and trigger prefixes describe a set of paths which must contain changes for a VCS push to trigger a run. If disabled, any push will trigger a run."
  type        = bool
  default     = false
}

variable "global_remote_state" {
  description = "(Optional) Whether the workspace allows all workspaces in the organization to access its state data during runs. If false, then only specifically approved workspaces can access its state (remote_state_consumer_ids)."
  type        = bool
  default     = false
}

variable "name" {
  description = "(Required) Name of the workspace."
  type        = string
}

variable "organization" {
  description = "(Required) Name of the organization."
  type        = string
}

variable "queue_all_runs" {
  description = "(Optional) Whether the workspace should start automatically performing runs immediately after its creation. Defaults to true. When set to false, runs triggered by a webhook (such as a commit in VCS) will not be queued until at least one run has been manually queued. Note: This default differs from the Terraform Cloud API default, which is false. The provider uses true as any workspace provisioned with false would need to then have a run manually queued out-of-band before accepting webhooks."
  type        = bool
  default     = true
}

variable "remote_state_consumer_ids" {
  description = "(Optional) The set of workspace IDs set as explicit remote state consumers for the given workspace."
  type        = list(string)
  default     = null
}

variable "speculative_enabled" {
  description = "(Optional) Whether this workspace allows speculative plans. Defaults to true. Setting this to false prevents Terraform Cloud or the Terraform Enterprise instance from running plans on pull requests, which can improve security if the VCS repository is public or includes untrusted contributors."
  type        = bool
  default     = true
}

variable "ssh_key_id" {
  description = "(Optional) The ID of an SSH key to assign to the workspace."
  type        = string
  default     = null
}

variable "structured_run_output_enabled" {
  description = "(Optional) Whether this workspace should show output from Terraform runs using the enhanced UI when available. Defaults to true. Setting this to false ensures that all runs in this workspace will display their output as text logs."
  type        = bool
  default     = true
}

variable "terraform_version" {
  description = "(Optional) The version of Terraform to use for this workspace. This can be either an exact version or a version constraint (like ~> 1.0.0); if you specify a constraint, the workspace will always use the newest release that meets that constraint. Defaults to the latest available version."
  type        = string
  default     = "~>1.3.0"
}

variable "trigger_prefixes" {
  description = "(Optional) List of repository-root-relative paths which describe all locations to be tracked for changes."
  type        = list(string)
  default     = null
}

variable "tag_names" {
  description = "(Optional) A list of tag names for this workspace. Note that tags must only contain letters, numbers or colons."
  type        = list(string)
  default     = null
}

variable "working_directory" {
  description = "(Optional) A relative path that Terraform will execute within. Defaults to the root of your repository."
  type        = string
  default     = null
}

variable "identifier" {
  description = "(Required) A reference to your VCS repository in the format <organization>/<repository> where <organization> and <repository> refer to the organization and repository in your VCS provider. The format for Azure DevOps is //_git/."
  type        = string
}

variable "branch" {
  description = "(Optional) The repository branch that Terraform will execute from. This defaults to the repository's default branch (e.g. main)."
  type        = string
  default     = null
}

variable "ingress_submodules" {
  description = "(Optional) Whether submodules should be fetched when cloning the VCS repository. Defaults to false."
  type        = bool
  default     = false
}

variable "oauth_token_id" {
  description = "(Required) The VCS Connection (OAuth Connection + Token) to use. This ID can be obtained from a tfe_oauth_client resource."
  type        = string
}

##############################
# Terraform Team Access/Permissions
##############################

variable "permission_map" {
  description = "(Required) The permissions map which maps the team_id to the permission access level. Exampe: 'terraform_all_admin = {id = team-fdsa5122q6rwYXP, access = admin}'"
  type        = map(any)
}
