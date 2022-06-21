variable "name" {
  description = "(Required) Display name for the OAuth Client. Defaults to the service_provider if not supplied."
  type = string
}

variable "organization" {
  description = "(Required) Name of the Terraform organization."
  type = string
}

variable "api_url" {
  description = "(Required) The base URL of your VCS provider's API (e.g. https://api.github.com or https://ghe.example.com/api/v3)."
  type = string
}

variable "http_url" {
  description = "(Required) The homepage of your VCS provider (e.g. https://github.com or https://ghe.example.com)."
  type = string
}

variable "oauth_token" {
  description = "(Required) The token string you were given by your VCS provider, e.g. ghp_xxxxxxxxxxxxxxx for a GitHub personal access token. For more information on how to generate this token string for your VCS provider, see the Create an OAuth Client documentation."
  type = string
}
