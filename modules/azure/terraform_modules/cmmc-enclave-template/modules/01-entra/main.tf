terraform {
  required_providers {
    azuread = {
      source  = "hashicorp/azuread"
      version = "~> 2.53"
    }
    azurerm = {
      source  = "hashicorp/azurerm"
      version = "~> 4.0"
    }
  }
}

# ---------------------------------------------------------------------------
# PIM-eligible security groups
# ---------------------------------------------------------------------------

locals {
  pim_groups = {
    service_desk        = "Service Desk"
    compliance          = "Compliance"
    security_operations = "Security Operations"
    security_engineering = "Security Engineering"
    escalation_engineers = "Escalation Engineers"
    global_admin        = "Global Admin"
  }

  rbac_groups = {
    owner           = "Owner"
    contributor     = "Contributor"
    billing_reader  = "Billing Reader"
  }
}

resource "azuread_group" "pim_eligible" {
  for_each             = local.pim_groups
  display_name         = "${var.customer_name} - ${each.value}"
  security_enabled     = true
  mail_enabled         = false
  assignable_to_role   = true
}

resource "azuread_group" "rbac" {
  for_each             = local.rbac_groups
  display_name         = "${var.customer_name} - ${each.value}"
  security_enabled     = true
  mail_enabled         = false
  assignable_to_role   = true
}

# ---------------------------------------------------------------------------
# PIM eligibility schedules (requires Entra ID P2)
# ---------------------------------------------------------------------------

locals {
  # Map PIM group keys to Entra directory role display names
  pim_role_assignments = {
    service_desk = [
      "User Administrator",
      "Intune Administrator",
      "Exchange Administrator",
      "SharePoint Administrator",
      "Groups Administrator",
      "Global Reader",
    ]
    compliance = [
      "User Administrator",
      "Authentication Administrator",
      "Cloud App Security Administrator",
      "Security Administrator",
      "Groups Administrator",
      "Global Reader",
    ]
    security_operations = [
      "Security Operator",
      "User Administrator",
      "Authentication Administrator",
      "Intune Administrator",
      "Exchange Administrator",
      "Global Reader",
    ]
    security_engineering = [
      "Cloud Application Administrator",
      "Cloud App Security Administrator",
      "Security Administrator",
      "Global Reader",
    ]
    escalation_engineers = [
      "Security Administrator",
      "Intune Administrator",
      "Authentication Administrator",
      "Global Reader",
    ]
    global_admin = [
      "Global Administrator",
    ]
  }
}

data "azuread_directory_roles" "all" {}

locals {
  # Build a flat map: "group_key|role_name" → { group_id, role_template_id }
  role_assignments_flat = merge([
    for group_key, roles in local.pim_role_assignments : {
      for role_name in roles :
      "${group_key}|${role_name}" => {
        group_id         = azuread_group.pim_eligible[group_key].object_id
        role_display_name = role_name
      }
    }
  ]...)
}

data "azuread_directory_role_templates" "all" {}

locals {
  role_template_map = {
    for t in data.azuread_directory_role_templates.all.role_templates :
    t.display_name => t.object_id
  }
}

resource "azuread_directory_role_assignment" "pim" {
  for_each            = local.role_assignments_flat
  role_id             = local.role_template_map[each.value.role_display_name]
  principal_object_id = each.value.group_id
}

# ---------------------------------------------------------------------------
# Subscription-level RBAC groups
# ---------------------------------------------------------------------------

resource "azurerm_role_assignment" "owner" {
  scope                = "/subscriptions/${var.subscription_id}"
  role_definition_name = "Owner"
  principal_id         = azuread_group.rbac["owner"].object_id
}

resource "azurerm_role_assignment" "contributor" {
  scope                = "/subscriptions/${var.subscription_id}"
  role_definition_name = "Contributor"
  principal_id         = azuread_group.rbac["contributor"].object_id
}

resource "azurerm_role_assignment" "billing_reader" {
  scope                = "/subscriptions/${var.subscription_id}"
  role_definition_name = "Billing Reader"
  principal_id         = azuread_group.rbac["billing_reader"].object_id
}

# ---------------------------------------------------------------------------
# Named location — United States
# ---------------------------------------------------------------------------

resource "azuread_named_location" "us_only" {
  display_name = "${var.customer_name} - United States"
  country {
    countries_and_regions                 = ["US"]
    include_unknown_countries_and_regions = false
  }
}

# ---------------------------------------------------------------------------
# Conditional Access: Require MFA for all users
# ---------------------------------------------------------------------------

resource "azuread_conditional_access_policy" "require_mfa" {
  display_name = "${var.customer_name} - Require MFA for All Users"
  state        = "enabled"
  depends_on   = [azuread_group.mfa_exempt]

  conditions {
    users {
      included_users  = ["All"]
      excluded_groups = concat([azuread_group.mfa_exempt.object_id], var.mfa_exempt_group_ids)
    }
    applications {
      included_applications = ["All"]
    }
    client_app_types = ["all"]
    locations {
      included_locations = [azuread_named_location.us_only.id]
      excluded_locations = []
    }
  }

  grant_controls {
    operator          = "OR"
    built_in_controls = ["mfa"]
  }
}

# ---------------------------------------------------------------------------
# Conditional Access: Block sign-ins outside the United States
# ---------------------------------------------------------------------------

resource "azuread_conditional_access_policy" "block_non_us" {
  display_name = "${var.customer_name} - Block Sign-ins Outside United States"
  state        = "enabled"

  conditions {
    users {
      included_users = ["All"]
    }
    applications {
      included_applications = ["All"]
    }
    locations {
      included_locations = ["All"]
      excluded_locations = [azuread_named_location.us_only.id]
    }
    client_app_types = ["all"]
  }

  grant_controls {
    operator          = "OR"
    built_in_controls = ["block"]
  }
}

# ---------------------------------------------------------------------------
# Conditional Access: Block legacy authentication
# ---------------------------------------------------------------------------

resource "azuread_conditional_access_policy" "block_legacy_auth" {
  display_name = "${var.customer_name} - Block Legacy Authentication"
  state        = "enabled"

  conditions {
    users {
      included_users = ["All"]
    }
    applications {
      included_applications = ["All"]
    }
    client_app_types = ["exchangeActiveSync", "other"]
  }

  grant_controls {
    operator          = "OR"
    built_in_controls = ["block"]
  }
}

# ---------------------------------------------------------------------------
# Named location — Secure Enclave
# ---------------------------------------------------------------------------

resource "azuread_named_location" "secure_enclave" {
  display_name = "${var.customer_name} - Secure Enclave"
  ip {
    ip_ranges = [for ip in var.secure_enclave_ips : "${ip}/32"]
    trusted   = true
  }
}

# ---------------------------------------------------------------------------
# Conditional Access: Block access outside Zero Trust Network
# ---------------------------------------------------------------------------

resource "azuread_conditional_access_policy" "block_outside_ztna" {
  display_name = "${var.customer_name} - Block access outside Zero Trust Network"
  state        = "enabledForReportingButNotEnforced"

  conditions {
    users {
      included_users = ["All"]
      excluded_users = var.excluded_user_ids
    }
    applications {
      included_applications = ["All"]
      excluded_applications = [var.appgate_oidc_application_id]
    }
    client_app_types = ["all"]
    locations {
      included_locations = ["All"]
      excluded_locations = [azuread_named_location.secure_enclave.id]
    }
  }

  grant_controls {
    operator          = "OR"
    built_in_controls = ["block"]
  }
}

# ---------------------------------------------------------------------------
# Conditional Access: Block non-AVD cloud apps on ZTNA unless using AVD
# ---------------------------------------------------------------------------

resource "azuread_conditional_access_policy" "block_non_avd_outside_ztna" {
  display_name = "${var.customer_name} - Block non-AVD cloud apps on ZTNA unless using AVD"
  state        = "enabledForReportingButNotEnforced"
  depends_on   = [azuread_group.mfa_exempt]

  conditions {
    users {
      included_users  = ["All"]
      excluded_users  = var.excluded_user_ids
      excluded_groups = [azuread_group.mfa_exempt.object_id]
    }
    applications {
      included_applications = ["All"]
      excluded_applications = [
        "a4a365df-50f1-4397-bc59-1a1564b8bb9c", # Microsoft Remote Desktop
        "270efc09-cd0d-444b-a71f-39af4910ec45", # Windows Cloud Login
        "9cdead84-a844-4324-93f2-b2e6bb768d07", # Azure Virtual Desktop
        "a85cf173-4192-42f8-81fa-777a763e6e2c", # Azure Virtual Desktop Client
        var.appgate_oidc_application_id,
      ]
    }
    client_app_types = ["all"]
    devices {
      filter {
        mode = "exclude"
        rule = "device.displayName -startsWith \"avd\" -and device.manufacturer -eq \"Microsoft Corporation\" -and device.model -eq \"Virtual Machine\""
      }
    }
  }

  grant_controls {
    operator          = "OR"
    built_in_controls = ["block"]
  }
}

# ---------------------------------------------------------------------------
# Conditional Access: Enforce periodic reauthentication for AVD cloud apps
# ---------------------------------------------------------------------------

resource "azuread_conditional_access_policy" "avd_reauthentication" {
  display_name = "${var.customer_name} - Enforce periodic reauthentication for AVD cloud apps"
  state        = "enabledForReportingButNotEnforced"

  conditions {
    users {
      included_users = ["All"]
      excluded_users = var.excluded_user_ids
    }
    applications {
      included_applications = [
        "9cdead84-a844-4324-93f2-b2e6bb768d07", # Azure Virtual Desktop
        "a4a365df-50f1-4397-bc59-1a1564b8bb9c", # Microsoft Remote Desktop
        "270efc09-cd0d-444b-a71f-39af4910ec45", # Windows Cloud Login
      ]
    }
    client_app_types = ["all"]
  }

  grant_controls {
    operator          = "OR"
    built_in_controls = ["mfa"]
  }

  session_controls {
    sign_in_frequency                        = 1
    sign_in_frequency_period                 = "hours"
    sign_in_frequency_authentication_type    = "primaryAndSecondaryAuthentication"
    sign_in_frequency_interval               = "timeBased"
  }
}

# ---------------------------------------------------------------------------
# Dynamic group for SSPR
# ---------------------------------------------------------------------------

resource "azuread_group" "sspr" {
  display_name     = "${var.customer_name} - SSPR Users"
  security_enabled = true
  mail_enabled     = false

  dynamic_membership {
    enabled = true
    rule    = "((user.companyName -eq \"${var.customer_name}\") or (user.companyName -eq \"${var.msp_company_name}\")) and (user.accountEnabled -eq true)"
  }
}

# ---------------------------------------------------------------------------
# MFA exempt group
# ---------------------------------------------------------------------------

resource "azuread_group" "mfa_exempt" {
  display_name     = "${var.customer_name} - Multifactor Authentication Exempt"
  security_enabled = true
  mail_enabled     = false
}

# ---------------------------------------------------------------------------
# Additional dynamic groups
# ---------------------------------------------------------------------------

resource "azuread_group" "all_users" {
  display_name     = "${var.customer_name} - All Users"
  security_enabled = true
  mail_enabled     = false

  dynamic_membership {
    enabled = true
    rule    = "(user.accountEnabled -eq true)"
  }
}

resource "azuread_group" "licensed_users" {
  display_name     = "${join(" | ", var.license_name)} Licensed Users"
  security_enabled = true
  mail_enabled     = false

  dynamic_membership {
    enabled = true
    rule    = "(user.companyName -eq \"${var.customer_name}\") and (user.accountEnabled -eq true)"
  }
}

resource "azuread_group" "all_windows_devices" {
  display_name     = "${var.customer_name} - All Windows 10 and Later Devices"
  security_enabled = true
  mail_enabled     = false

  dynamic_membership {
    enabled = true
    rule    = "(device.accountEnabled -eq True) and (device.deviceOSType -eq \"Windows\") and ((device.deviceOSVersion -startsWith \"10.0.1\") or (device.deviceOSVersion -startsWith \"10.0.2\"))"
  }
}

resource "azuread_group" "avd_hosts" {
  display_name     = "${var.customer_name} - All Azure Virtual Desktop Hosts"
  security_enabled = true
  mail_enabled     = false

  dynamic_membership {
    enabled = true
    rule    = "(device.accountEnabled -eq True) and ((device.displayName -startsWith \"avd\") or (device.displayName -startsWith \"cad-avd\") or (device.displayName -startsWith \"mgmt-avd\"))"
  }
}

resource "azuread_group" "gpu_vms" {
  display_name     = "${var.customer_name} - GPU-optimized Azure VMs"
  security_enabled = true
  mail_enabled     = false

  dynamic_membership {
    enabled = true
    rule    = "(device.accountEnabled -eq True) and (device.displayName -startsWith \"cad-avd\")"
  }
}
