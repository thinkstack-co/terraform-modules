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
      "Security Administrator",
      "Global Reader",
    ]
    escalation_engineers = [
      "Security Administrator",
      "User Administrator",
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

  conditions {
    users {
      included_users  = ["All"]
      excluded_groups = var.mfa_exempt_group_ids
    }
    applications {
      included_applications = ["All"]
    }
    client_app_types = ["all"]
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
# Dynamic group for SSPR
# ---------------------------------------------------------------------------

resource "azuread_group" "sspr" {
  display_name     = "${var.customer_name} - SSPR Users"
  security_enabled = true
  mail_enabled     = false

  dynamic_membership {
    enabled = true
    rule    = "(user.companyName -eq \"${var.customer_name}\") and (user.accountEnabled -eq true)"
  }
}
