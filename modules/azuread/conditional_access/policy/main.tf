resource "azuread_conditional_access_policy" "example" {
  display_name = "example policy"
  state        = "disabled"

  conditions {
    client_app_types    = var.client_app_types
    sign_in_risk_levels = var.sign_in_risk_levels
    user_risk_levels    = var.user_risk_levels

    applications {
      included_applications = var.included_applications
      excluded_applications = var.excluded_applications
    }

    devices {
      filter {
        mode = "exclude"
        rule = "device.operatingSystem eq \"Doors\""
      }
    }

    locations {
      included_locations = var.included_locations
      excluded_locations = var.excluded_locations
    }

    platforms {
      included_platforms = var.included_platforms
      excluded_platforms = var.excluded_platforms
    }

    users {
      included_users = var.included_users
      excluded_users = var.excluded_users
    }
  }

  grant_controls {
    operator          = var.operator
    built_in_controls = var.built_in_controls
  }

  session_controls {
    application_enforced_restrictions_enabled = var.application_enforced_restrictions_enabled
    sign_in_frequency                         = var.sign_in_frequency
    sign_in_frequency_period                  = var.sign_in_frequency_period
    cloud_app_security_policy                 = var.cloud_app_security_policy
  }
}