variable "display_name" {
    type = string
    description = "(Required) The friendly name for this Conditional Access Policy."
}

variable "state" {
  type = string
  description = "(Required) Specifies the state of the policy object. Possible values are: enabled, disabled and enabledForReportingButNotEnforced"
  validation {
    condition = contains(["enabled", "disabled", "enabledForReportingButNotEnforced"])
    error_message = "The state value must be a string and one of the following possible vlaues: 'enabled', 'disabled', 'enabledForReportingButNotEnforced'"
  }
}

################
# Conditions
################

variable "client_app_types" {
    type = list(string)
    description = "(Required) A list of client application types included in the policy. Possible values are: all, browser, mobileAppsAndDesktopClients, exchangeActiveSync, easSupported and other."
    validation {
      condition = contains(["all", "browser", "mobileAppsAndDesktopClients", "exchangeActiveSync", "easSupported", "other"])
      error_message = "The client_app_types value must be a list of strings and one or more of the following possibile values: 'all', 'browser', 'mobileAppsAndDesktopClients', 'exchangeActiveSync', 'easSupported', 'other'"
    }
}

variable "sign_in_risk_levels" {
    type = list(string)
    description = "(Optional) A list of sign-in risk levels included in the policy. Possible values are: low, medium, high, hidden, none, unknownFutureValue."
    default = ""
    validation {
      condition = contains(["low", "medium", "high", "hidden", "none", "unknownFutureValue"])
      error_message = "The sign_in_risk_levels value must be a list of strings and one or more of the following possible values: 'low', 'medium', 'high', 'hidden', 'none', 'unknownFutureValue'"
    }
}

variable "user_risk_levels" {
    type = list(string)
    description = "(Optional) A list of user risk levels included in the policy. Possible values are: low, medium, high, hidden, none, unknownFutureValue."
    validation {
      condition = contains(["low", "medium", "high", "hidden", "none", "unknownFutureValue"])
      error_message = "The user_risk_levels value must be a list of strings and one or more of the following possible values: 'low', 'medium', 'high', 'hidden', 'none', 'unknownFutureValue'"
    }
}
