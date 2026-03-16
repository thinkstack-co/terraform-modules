# ---------------------------------------------------------------------------
# Public IPs for Firewall
# ---------------------------------------------------------------------------

resource "azurerm_public_ip" "firewall" {
  count               = 2
  name                = "${local.name_prefix}-afw-pip-${count.index + 1}"
  location            = var.location
  resource_group_name = var.resource_group_name
  allocation_method   = "Static"
  sku                 = "Standard"
  tags                = var.tags
}

# ---------------------------------------------------------------------------
# Firewall Policy
# ---------------------------------------------------------------------------

resource "azurerm_firewall_policy" "mgmt" {
  name                = "${local.name_prefix}-afwp-1"
  location            = var.location
  resource_group_name = var.resource_group_name
  sku                 = "Premium"
  tags                = var.tags

  dns {
    proxy_enabled = true
  }

  intrusion_detection {
    mode = "Alert"
  }
}

# ---------------------------------------------------------------------------
# Firewall Policy Rule Collection Group — FQDN-based rules
# NOTE: Web category filtering is not reliably supported in Azure Government.
# Rules use explicit FQDN tags instead.
# ---------------------------------------------------------------------------

resource "azurerm_firewall_policy_rule_collection_group" "web_categories" {
  name               = "${local.name_prefix}-afwp-app-rcg"
  firewall_policy_id = azurerm_firewall_policy.mgmt.id
  priority           = 200

  application_rule_collection {
    name     = "AllowMicrosoftServices"
    priority = 100
    action   = "Allow"

    rule {
      name = "AllowWindowsUpdate"
      protocols {
        type = "Https"
        port = 443
      }
      protocols {
        type = "Http"
        port = 80
      }
      source_addresses      = ["*"]
      destination_fqdn_tags = ["WindowsUpdate", "WindowsDiagnostics", "MicrosoftActiveProtectionService"]
    }
  }
}

# ---------------------------------------------------------------------------
# Azure Firewall
# ---------------------------------------------------------------------------

resource "azurerm_firewall" "mgmt" {
  name                = "${local.name_prefix}-afw-1"
  location            = var.location
  resource_group_name = var.resource_group_name
  sku_name            = "AZFW_VNet"
  sku_tier            = "Premium"
  firewall_policy_id  = azurerm_firewall_policy.mgmt.id
  tags                = var.tags

  ip_configuration {
    name                 = "fw-ipconfig-1"
    subnet_id            = azurerm_subnet.firewall.id
    public_ip_address_id = azurerm_public_ip.firewall[0].id
  }

  ip_configuration {
    name                 = "fw-ipconfig-2"
    public_ip_address_id = azurerm_public_ip.firewall[1].id
  }
}

resource "azurerm_monitor_diagnostic_setting" "firewall" {
  name                       = "${local.name_prefix}-afw-diag"
  target_resource_id         = azurerm_firewall.mgmt.id
  log_analytics_workspace_id = azurerm_log_analytics_workspace.firewall.id

  enabled_log { category = "AzureFirewallApplicationRule" }
  enabled_log { category = "AzureFirewallNetworkRule" }
  enabled_log { category = "AzureFirewallDnsProxy" }
  enabled_metric { category = "AllMetrics" }
}
