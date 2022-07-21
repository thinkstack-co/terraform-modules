variable "allow_auto_merge" {
  description = "(Optional) Set to true to allow auto-merging pull requests on the repository."
  type        = bool
  default     = false
}

variable "allow_merge_commit" {
  description = "(Optional) Set to false to disable merge commits on the repository."
  type        = bool
  default     = true
}

variable "allow_rebase_merge" {
  description = "(Optional) Set to false to disable rebase merges on the repository."
  type        = bool
  default     = true
}

variable "allow_squash_merge" {
  description = "(Optional) Set to false to disable squash merges on the repository."
  type        = bool
  default     = true
}

variable "archived" {
  description = "(Optional) Specifies if the repository should be archived. Defaults to false. NOTE Currently, the API does not support unarchiving."
  type        = bool
  default     = false
}

variable "archive_on_destroy" {
  description = "(Optional) Set to true to archive the repository instead of deleting on destroy."
  type        = bool
  default     = true
}

variable "auto_init" {
  description = "(Optional) Set to true to produce an initial commit in the repository."
  type        = bool
  default     = true
}

variable "delete_branch_on_merge" {
  description = "(Optional) Automatically delete head branch after a pull request is merged. Defaults to false."
  type        = bool
  default     = true
}

variable "description" {
  description = "(Optional) A description of the repository."
  type        = string
  default     = null
}

variable "gitignore_template" {
  description = "(Optional) Use the name of the template without the extension. For example, 'Haskell'."
  type        = string
  default     = null
}

variable "has_downloads" {
  description = "(Optional) Set to true to enable the (deprecated) downloads features on the repository."
  type        = bool
  default     = false
}

variable "has_issues" {
  description = "(Optional) Set to true to enable the GitHub Issues features on the repository."
  type        = bool
  default     = true
}

variable "has_projects" {
  description = "(Optional) Set to true to enable the GitHub Projects features on the repository. Per the GitHub documentation when in an organization that has disabled repository projects it will default to false and will otherwise default to true. If you specify true when it has been disabled it will return an error."
  type        = bool
  default     = true
}

variable "has_wiki" {
  description = "(Optional) Set to true to enable the GitHub Wiki features on the repository."
  type        = bool
  default     = false
}

variable "homepage_url" {
  description = "(Optional) URL of a page describing the project."
  type        = string
  default     = null
}

variable "license_template" {
  description = "(Optional) Use the name of the template without the extension. For example, 'mit' or 'mpl-2.0'."
  type        = string
  default     = null
}

variable "is_template" {
  description = "(Optional) Set to true to tell GitHub that this is a template repository."
  type        = bool
  default     = false
}

variable "name" {
  description = "(Required) The name of the repository."
  type        = string
}

variable "private" {
  description = "(Optional) Set to true to create a private repository. Repositories are created as public (e.g. open source) by default."
  type        = bool
  default     = true
}

variable "topics" {
  description = "(Optional) The list of topics of the repository."
  type        = list
  default     = null
}

variable "visibility" {
  description = "(Optional) Can be public or private. If your organization is associated with an enterprise account using GitHub Enterprise Cloud or GitHub Enterprise Server 2.20+, visibility can also be internal. The visibility parameter overrides the private parameter."
  type        = string
  default     = "private"
}

variable "vulnerability_alerts" {
  description = "(Optional) - Set to true to enable security alerts for vulnerable dependencies. Enabling requires alerts to be enabled on the owner level. (Note for importing: GitHub enables the alerts on public repos but disables them on private repos by default.) See GitHub Documentation for details. Note that vulnerability alerts have not been successfully tested on any GitHub Enterprise instance and may be unavailable in those settings."
  type        = bool
  default     = true
}

variable "template_owner" {
  description = "(Optional) The GitHub organization or user the template repository is owned by."
  type        = string
  default     = null
}

variable "template_repository" {
  description = "(Optional) The name of the template repository."
  type        = string
  default     = null
}
