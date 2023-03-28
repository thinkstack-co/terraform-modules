terraform {
  required_version = ">= 1.0.0"
  required_providers {
    azuread = {
      source  = "hashicorp/azuread"
      version = ">= 2.36.0"
    }
  }
}

resource "azuread_conditional_access_policy" "example" {
  display_name = var.display_name
  state        = var.state

  conditions {
    client_app_types    = var.client_app_types
    sign_in_risk_levels = var.sign_in_risk_levels
    user_risk_levels    = var.user_risk_levels

    applications {
      excluded_applications = var.excluded_applications
      included_applications = var.included_applications
      included_user_actions = var.included_user_actions
    }

    devices {
      filter {
        mode = var.device_filter_mode
        rule = var.device_filter_rule
      }
    }

    locations {
      excluded_locations = var.excluded_locations
      included_locations = var.included_locations
    }

    platforms {
      excluded_platforms = var.excluded_platforms
      included_platforms = var.included_platforms
    }

    users {
      excluded_groups = var.excluded_groups
      excluded_roles  = var.excluded_roles
      excluded_users  = var.excluded_users
      included_groups = var.included_groups
      included_roles  = var.included_roles
      included_users  = var.included_users
    }
  }

  grant_controls {
    built_in_controls             = var.built_in_controls
    custom_authentication_factors = var.custom_authentication_factors
    operator                      = var.operator
    terms_of_use                  = var.terms_of_use
  }

  session_controls {
    application_enforced_restrictions_enabled = var.application_enforced_restrictions_enabled
    cloud_app_security_policy                 = var.cloud_app_security_policy
    persistent_browser_mode                   = var.persistent_browser_mode
    sign_in_frequency                         = var.sign_in_frequency
    sign_in_frequency_period                  = var.sign_in_frequency_period
  }
}
