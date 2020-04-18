variable "sns_topic_name" {
  type = string
  description = "(Optional) The SNS topic to create for notifications for the Vault. Fields documented below."
}

variable "access_policy" {
  type = map
  description = "(Optional) The policy document. This is a JSON formatted string. The heredoc syntax or file function is helpful here. Use the Glacier Developer Guide for more information on Glacier Vault Policy"
}

variable "vault_name" {
  type = string
  description = "(Required) The name of the Vault. Names can be between 1 and 255 characters long and the valid characters are a-z, A-Z, 0-9, '_' (underscore), '-' (hyphen), and '.' (period)."
}

variable "tags" {
  type = map
  description = "(Optional) A mapping of tags to assign to the resource."
}
