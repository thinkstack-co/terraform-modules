terraform {
  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = "~> 4.0"
    }
    azuread = {
      source  = "hashicorp/azuread"
      version = "~> 2.53"
    }
  }
}

locals {
  name_prefix = "${var.customer_name}-${var.location}"
  mgmt_prefix = "mgmt-${var.location}"

  rdp_properties = join(";", [
    "enablerdsaadauth:i:1",
    "videoplaybackmode:i:1",
    "audiocapturemode:i:1",
    "redirectclipboard:i:0",
    "camerastoredirect:s:*",
    "use multimon:i:1",
    "dynamic resolution:i:1",
    "drivestoredirect:s:",
  ])
}

# ---------------------------------------------------------------------------
# Management Host Pool
# ---------------------------------------------------------------------------

resource "azurerm_virtual_desktop_host_pool" "mgmt" {
  name                = "${local.mgmt_prefix}-vdpool-1"
  location            = var.location
  resource_group_name = var.resource_group_name

  type                     = "Pooled"
  load_balancer_type       = "DepthFirst"
  maximum_sessions_allowed = 2
  start_vm_on_connect      = true
  custom_rdp_properties    = local.rdp_properties

  tags = var.tags
}

resource "azurerm_virtual_desktop_host_pool_registration_info" "mgmt" {
  hostpool_id     = azurerm_virtual_desktop_host_pool.mgmt.id
  expiration_date = timeadd(timestamp(), "2h")

  lifecycle {
    ignore_changes = [expiration_date]
  }
}

resource "azurerm_virtual_desktop_application_group" "mgmt" {
  name                = "${local.mgmt_prefix}-vdag-1"
  location            = var.location
  resource_group_name = var.resource_group_name
  type                = "Desktop"
  host_pool_id        = azurerm_virtual_desktop_host_pool.mgmt.id
  tags                = var.tags
}

resource "azurerm_virtual_desktop_workspace" "mgmt" {
  name                = "${local.mgmt_prefix}-vdws-1"
  location            = var.location
  resource_group_name = var.resource_group_name
  tags                = var.tags
}

resource "azurerm_virtual_desktop_workspace_application_group_association" "mgmt" {
  workspace_id         = azurerm_virtual_desktop_workspace.mgmt.id
  application_group_id = azurerm_virtual_desktop_application_group.mgmt.id
}

# ---------------------------------------------------------------------------
# Customer Host Pool
# ---------------------------------------------------------------------------

resource "azurerm_virtual_desktop_host_pool" "customer" {
  name                = "${local.name_prefix}-vdpool-1"
  location            = var.location
  resource_group_name = var.resource_group_name

  type                     = var.customer_host_pool_type
  load_balancer_type       = var.customer_load_balancer_type
  maximum_sessions_allowed = var.customer_max_sessions
  start_vm_on_connect      = true
  custom_rdp_properties    = local.rdp_properties

  tags = var.tags
}

resource "azurerm_virtual_desktop_host_pool_registration_info" "customer" {
  hostpool_id     = azurerm_virtual_desktop_host_pool.customer.id
  expiration_date = timeadd(timestamp(), "2h")

  lifecycle {
    ignore_changes = [expiration_date]
  }
}

resource "azurerm_virtual_desktop_application_group" "customer" {
  name                = "${local.name_prefix}-vdag-1"
  location            = var.location
  resource_group_name = var.resource_group_name
  type                = "Desktop"
  host_pool_id        = azurerm_virtual_desktop_host_pool.customer.id
  tags                = var.tags
}

resource "azurerm_virtual_desktop_workspace" "customer" {
  name                = "${local.name_prefix}-vdws-1"
  location            = var.location
  resource_group_name = var.resource_group_name
  tags                = var.tags
}

resource "azurerm_virtual_desktop_workspace_application_group_association" "customer" {
  workspace_id         = azurerm_virtual_desktop_workspace.customer.id
  application_group_id = azurerm_virtual_desktop_application_group.customer.id
}

# ---------------------------------------------------------------------------
# RBAC — Desktop Virtualization User on customer app group
# ---------------------------------------------------------------------------

resource "azurerm_role_assignment" "avd_user" {
  scope                = azurerm_virtual_desktop_application_group.customer.id
  role_definition_name = "Desktop Virtualization User"
  principal_id         = var.avd_users_group_id
}

# Power On Off Contributor — must be assigned to the AVD first-party service principal
data "azuread_service_principal" "avd" {
  application_id = "9cdead84-a844-4324-93f2-b2e6bb768d07" # Windows Virtual Desktop
}

resource "azurerm_role_assignment" "power_on_off" {
  scope                = "/subscriptions/${data.azurerm_subscription.current.subscription_id}/resourceGroups/${var.resource_group_name}"
  role_definition_name = "Desktop Virtualization Power On Off Contributor"
  principal_id         = data.azuread_service_principal.avd.object_id
}

data "azurerm_client_config" "current" {}
data "azurerm_subscription" "current" {}

# ---------------------------------------------------------------------------
# Scaling Plan
# ---------------------------------------------------------------------------

resource "azurerm_virtual_desktop_scaling_plan" "customer" {
  name                = "${local.name_prefix}-vdsp-1"
  location            = var.location
  resource_group_name = var.resource_group_name
  time_zone           = "Eastern Standard Time"
  tags                = var.tags

  schedule {
    name                                 = "Weekdays"
    days_of_week                         = ["Monday", "Tuesday", "Wednesday", "Thursday", "Friday"]
    ramp_up_start_time                   = "07:00"
    ramp_up_load_balancing_algorithm     = "BreadthFirst"
    ramp_up_minimum_hosts_percent        = 20
    ramp_up_capacity_threshold_percent   = 60
    peak_start_time                      = "09:00"
    peak_load_balancing_algorithm        = "BreadthFirst"
    ramp_down_start_time                 = "18:00"
    ramp_down_load_balancing_algorithm   = "DepthFirst"
    ramp_down_minimum_hosts_percent      = 10
    ramp_down_force_logoff_users         = false
    ramp_down_wait_time_minutes          = 45
    ramp_down_notification_message       = "Session will end in 45 minutes. Please save your work."
    ramp_down_capacity_threshold_percent = 90
    ramp_down_stop_hosts_when            = "ZeroSessions"
    off_peak_start_time                  = "20:00"
    off_peak_load_balancing_algorithm    = "DepthFirst"
  }

  host_pool {
    hostpool_id          = azurerm_virtual_desktop_host_pool.customer.id
    scaling_plan_enabled = true
  }

  depends_on = [azurerm_role_assignment.power_on_off]
}

# ---------------------------------------------------------------------------
# Diagnostics
# ---------------------------------------------------------------------------

resource "azurerm_monitor_diagnostic_setting" "mgmt_host_pool" {
  name                       = "${local.mgmt_prefix}-vdpool-diag"
  target_resource_id         = azurerm_virtual_desktop_host_pool.mgmt.id
  log_analytics_workspace_id = var.log_analytics_workspace_id

  enabled_log { category = "Checkpoint" }
  enabled_log { category = "Error" }
  enabled_log { category = "Management" }
  enabled_log { category = "Connection" }
  enabled_log { category = "HostRegistration" }
  enabled_log { category = "AgentHealthStatus" }
  enabled_log { category = "NetworkData" }
  enabled_log { category = "SessionHostManagement" }
}

resource "azurerm_monitor_diagnostic_setting" "customer_host_pool" {
  name                       = "${local.name_prefix}-vdpool-diag"
  target_resource_id         = azurerm_virtual_desktop_host_pool.customer.id
  log_analytics_workspace_id = var.log_analytics_workspace_id

  enabled_log { category = "Checkpoint" }
  enabled_log { category = "Error" }
  enabled_log { category = "Management" }
  enabled_log { category = "Connection" }
  enabled_log { category = "HostRegistration" }
  enabled_log { category = "AgentHealthStatus" }
  enabled_log { category = "NetworkData" }
  enabled_log { category = "SessionHostManagement" }
}

resource "azurerm_monitor_diagnostic_setting" "customer_workspace" {
  name                       = "${local.name_prefix}-vdws-diag"
  target_resource_id         = azurerm_virtual_desktop_workspace.customer.id
  log_analytics_workspace_id = var.log_analytics_workspace_id

  enabled_log { category = "Checkpoint" }
  enabled_log { category = "Error" }
  enabled_log { category = "Management" }
  enabled_log { category = "Feed" }
}
