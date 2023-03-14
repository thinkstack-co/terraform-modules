variable "display_name" {
  type        = string
  description = "(Required) The friendly name for this Conditional Access Policy."
}

variable "state" {
  type        = string
  description = "(Required) Specifies the state of the policy object. Possible values are: enabled, disabled and enabledForReportingButNotEnforced"
  validation {
    condition     = contains(["enabled", "disabled", "enabledForReportingButNotEnforced"])
    error_message = "The state value must be a string and one of the following possible vlaues: 'enabled', 'disabled', 'enabledForReportingButNotEnforced'"
  }
}

################
# Conditions
################

variable "client_app_types" {
  type        = list(string)
  description = "(Required) A list of client application types included in the policy. Possible values are: all, browser, mobileAppsAndDesktopClients, exchangeActiveSync, easSupported and other."
  validation {
    condition     = contains(["all", "browser", "mobileAppsAndDesktopClients", "exchangeActiveSync", "easSupported", "other"])
    error_message = "The client_app_types value must be a list of strings and one or more of the following possibile values: 'all', 'browser', 'mobileAppsAndDesktopClients', 'exchangeActiveSync', 'easSupported', 'other'"
  }
}

variable "sign_in_risk_levels" {
  type        = list(string)
  description = "(Optional) A list of sign-in risk levels included in the policy. Possible values are: low, medium, high, hidden, none, unknownFutureValue."
  default     = null
  validation {
    condition     = contains(["low", "medium", "high", "hidden", "none", "unknownFutureValue"])
    error_message = "The sign_in_risk_levels value must be a list of strings and one or more of the following possible values: 'low', 'medium', 'high', 'hidden', 'none', 'unknownFutureValue'"
  }
}

variable "user_risk_levels" {
  type        = list(string)
  description = "(Optional) A list of user risk levels included in the policy. Possible values are: low, medium, high, hidden, none, unknownFutureValue."
  validation {
    condition     = contains(["low", "medium", "high", "hidden", "none", "unknownFutureValue"])
    error_message = "The user_risk_levels value must be a list of strings and one or more of the following possible values: 'low', 'medium', 'high', 'hidden', 'none', 'unknownFutureValue'"
  }
}

################
# Conditions - Applications
################

variable "excluded_applications" {
  type        = list(string)
  description = "(Optional) A list of application IDs explicitly excluded from the policy. Can also be set to Office365."
  default     = null
}

variable "included_applications" {
  type        = list(string)
  description = "(Optional) A list of application IDs the policy applies to, unless explicitly excluded (in excluded_applications). Can also be set to All, None or Office365. Cannot be specified with included_user_actions. One of included_applications or included_user_actions must be specified."
  default     = null
}

variable "included_user_actions" {
  type        = list(string)
  description = "(Optional) A list of user actions to include. Supported values are urn:user:registerdevice and urn:user:registersecurityinfo. Cannot be specified with included_applications. One of included_applications or included_user_actions must be specified."
  default     = null
}

################
# Conditions - Devices
################

variable "device_filter_mode" {
  type        = string
  description = "(Optional) Whether to include in, or exclude from, matching devices from the policy. Supported values are include or exclude."
  default     = null
  validation {
    condition     = contains(["include", "exclude"])
    error_message = "The device_filter_mode value must be a string and one of the following possible values: 'include' or 'exclude'"
  }
}

variable "device_filter_rule" {
  type        = string
  description = "(Required) Condition filter to match devices. For more information, see official documentation."
  default     = null
}

################
# Conditions - Locations
################

variable "excluded_locations" {
  type        = list(string)
  description = "(Optional) A list of location IDs excluded from scope of policy. Can also be set to AllTrusted."
  default     = null
}

variable "included_locations" {
  type        = list(string)
  description = "(Required) A list of location IDs in scope of policy unless explicitly excluded. Can also be set to All, or AllTrusted."
  default     = null
}

################
# Conditions - Platforms
################

variable "excluded_platforms" {
  type        = list(string)
  description = "(Optional) A list of platforms explicitly excluded from the policy. Possible values are: all, android, iOS, linux, macOS, windows, windowsPhone or unknownFutureValue."
  validation {
    condition     = contains(["all", "android", "iOS", "linux", "macOS", "windows", "windowsPhone", "unknownFutureValue"])
    error_message = "The excluded_platforms value must be a list of strings and one or more from the following possible values: 'all', 'android', 'iOS', 'linux', 'macOS', 'windows', 'windowsPhone', 'unknownFutureValue'"
  }
}

variable "included_platforms" {
  type        = list(string)
  description = "(Required) A list of platforms the policy applies to, unless explicitly excluded. Possible values are: all, android, iOS, linux, macOS, windows, windowsPhone or unknownFutureValue."
  validation {
    condition     = contains(["all", "android", "iOS", "linux", "macOS", "windows", "windowsPhone", "unknownFutureValue"])
    error_message = "The included_platforms value must be a list of strings and one or more from the following possible values: 'all', 'android', 'iOS', 'linux', 'macOS', 'windows', 'windowsPhone', 'unknownFutureValue'"
  }
}

################
# Conditions - Users
################

variable "excluded_groups" {
  type        = list(string)
  description = "(Optional) A list of group IDs excluded from scope of policy."
  default     = null
}

variable "excluded_roles" {
  type        = list(string)
  description = "(Optional) A list of role IDs excluded from scope of policy."
  default     = null
}

variable "excluded_users" {
  type        = list(string)
  description = "(Optional) A list of user IDs excluded from scope of policy and/or GuestsOrExternalUsers."
  default     = null
}

variable "included_groups" {
  type        = list(string)
  description = "(Optional) A list of group IDs in scope of policy unless explicitly excluded."
  default     = null
}

variable "included_roles" {
  type        = list(string)
  description = "(Optional) A list of role IDs in scope of policy unless explicitly excluded."
  default     = null
}

variable "included_users" {
  type        = list(string)
  description = "(Optional) A list of user IDs in scope of policy unless explicitly excluded, or None or All or GuestsOrExternalUsers."
  default     = null
}

################
# Grant Controls
################

variable "built_in_controls" {
  type        = list(string)
  description = "(Required) List of built-in controls required by the policy. Possible values are: block, mfa, approvedApplication, compliantApplication, compliantDevice, domainJoinedDevice, passwordChange or unknownFutureValue."
  default     = null
  validation {
    condition     = contains(["block", "mfa", "approvedApplication", "compliantApplication", "compliantDevice", "domainJoinedDevice", "passwordChange", "unknownFutureValue"])
    error_message = "The built_in_controls value must be a list of strings and one or more from the following possible values: 'block', 'mfa', 'approvedApplication', 'compliantApplication', 'compliantDevice', 'domainJoinedDevice', 'passwordChange', 'unknownFutureValue'"
  }
}

variable "custom_authentication_factors" {
  type        = list(string)
  description = "(Optional) List of custom controls IDs required by the policy."
  default     = null
}

variable "operator" {
  type        = string
  description = "(Required) Defines the relationship of the grant controls. Possible values are: AND, OR."
}

variable "terms_of_use" {
  type        = list(string)
  description = "(Optional) List of terms of use IDs required by the policy."
  default     = null
}

################
# Session Controls
################

variable "application_enforced_restrictions_enabled" {
  type        = bool
  description = "(Optional) Whether or not application enforced restrictions are enabled. Defaults to false."
  default     = false
  validation {
    condition     = var.application_enforced_restrictions_enabled == true || var.application_enforced_restrictions_enabled == false
    error_message = "The application_enforced_restrictions_enabled value must be a boolean true or false."
  }
}

variable "cloud_app_security_policy" {
  type        = string
  description = "(Optional) Enables cloud app security and specifies the cloud app security policy to use. Possible values are: blockDownloads, mcasConfigured, monitorOnly or unknownFutureValue."
  default     = null
  validation {
    condition     = contains(["blockDownloads", "mcasConfigured", "monitorOnly", "unknownFutureValue"]) || var.cloud_app_security_policy == null
    error_message = "The cloud_app_security_policy value must be a string from one of the following possible values: 'blockDownloads', 'mcasConfigured', 'monitorOnly', 'unknownFutureValue'"
  }
}

variable "persistent_browser_mode" {
  type        = string
  description = "(Optional) Session control to define whether to persist cookies or not. Possible values are: always or never."
  default     = null
  validation {
    condition     = contains(["always", "never"]) || var.persistent_browser_mode == null
    error_message = "The persistent_browser_mode value must be a string from one of the following possible values: 'always' or 'never'"
  }
}

variable "sign_in_frequency" {
  type        = number
  description = "(Optional) Number of days or hours to enforce sign-in frequency. Required when sign_in_frequency_period is specified. Due to an API issue, removing this property forces a new resource to be created."
  default     = null
  validation {
    condition     = var.sign_in_frequency > 0 || var.sign_in_frequency == null
    error_message = "The sign_in_frequency value must be a number greater than 0 or null."
  }
}

variable "sign_in_frequency_period" {
  type        = string
  description = "(Optional) The time period to enforce sign-in frequency. Possible values are: hours or days. Required when sign_in_frequency_period is specified. Due to an API issue, removing this property forces a new resource to be created."
  default     = null
  validation {
    condition     = contains(["hours", "days"]) || var.sign_in_frequency_period == null
    error_message = "The sign_in_frequency_period value must be a string from one of the following possible values: 'hours' or 'days'"
  }
}
