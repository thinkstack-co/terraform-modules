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
  domain_name_label   = count.index == 0 ? var.appgate_controller_dns_label : var.appgate_gateway_dns_label
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

  application_rule_collection {
    name     = "AllowEntraIDAndAVD"
    priority = 200
    action   = "Allow"

    rule {
      name = "AllowEntraIDJoin"
      protocols {
        type = "Https"
        port = 443
      }
      source_addresses = ["*"]
      destination_fqdns = [
        # Azure Government AAD endpoints
        "login.microsoftonline.us",
        "enterpriseregistration.microsoftonline.us",
        "device.login.microsoftonline.us",
        "graph.microsoft.us",
        "autologon.microsoft.us",
        "management.usgovcloudapi.net",
        "pas.windows.net",
        # Commercial endpoints required for initial tenant discovery/redirect
        "enterpriseregistration.windows.net",
        "login.microsoftonline.com",
        "login.windows.net",
      ]
    }

    rule {
      name = "AllowAVDServices"
      protocols {
        type = "Https"
        port = 443
      }
      source_addresses = ["*"]
      destination_fqdns = [
        "*.wvd.microsoft.us",
        "*.wvd.azure.us",
        # Explicit RD Gateway endpoints (Azure Front Door — DNS proxy may not
        # resolve these via the *.wvd.azure.us wildcard chain reliably)
        "afdfp-rdgateway-r0.wvd.azure.us",
        "afdfp-rdgateway-r1.wvd.azure.us",
        "kms.core.usgovcloudapi.net",
        "wvdportalstorageblob.blob.core.windows.net",
        "raw.githubusercontent.com",
        # AVD agent upgrade packages (Azure Government blob storage)
        "*.blob.core.usgovcloudapi.net",
        # Office / Teams on session hosts
        "fs.microsoft.com",
        "ecs.office.com",
        "clients.config.office.net",
        "mobile.events.data.microsoft.com",
        # Azure Monitor / Geneva monitoring (required for MonitoringAgentCheck)
        "*.monitoring.core.usgovcloudapi.net",
        # Microsoft Defender AV
        "mdav.us.endpoint.security.microsoft.com",
        # Certificate validation (OCSP/CRL)
        "ocsp.digicert.com",
        "crl3.digicert.com",
        "crl2.microsoft.com",
        "oneocsp.microsoft.com",
        # General Microsoft / Windows App UI
        "go.microsoft.com",
        "www.microsoft.com",
        "aka.ms",
        "res.cdn.office.net",
      ]
    }
  }

  network_rule_collection {
    name     = "AllowAVDShortpath"
    priority = 300
    action   = "Allow"

    rule {
      name                  = "AllowRDPShortpathUDP"
      protocols             = ["UDP"]
      source_addresses      = ["*"]
      destination_addresses = ["WindowsVirtualDesktop"]
      destination_ports     = ["443", "3478"]
    }
  }
}

# ---------------------------------------------------------------------------
# Firewall Policy Rule Collection Group — Web category filtering
# ---------------------------------------------------------------------------

resource "azurerm_firewall_policy_rule_collection_group" "web_categories_filtering" {
  name               = "${local.name_prefix}-afwp-web-rcg"
  firewall_policy_id = azurerm_firewall_policy.mgmt.id
  priority           = 300

  application_rule_collection {
    name     = "AllowWebCategories"
    priority = 100
    action   = "Allow"

    rule {
      name = "allow-web-browsing"
      protocols {
        type = "Http"
        port = 80
      }
      protocols {
        type = "Https"
        port = 443
      }
      source_addresses = ["*"]
      web_categories = [
        "business",
        "computersandtechnology",
        "education",
        "finance",
        "forumsandnewsgroups",
        "government",
        "healthandmedicine",
        "informationsecurity",
        "jobsearch",
        "news",
        "nonprofitsandngos",
        "personalsites",
        "professionalnetworking",
        "searchenginesandportals",
        "translators",
        "webrepositoryandstorage",
        "webbasedemail",
        "advertisementsandpopups",
        "chat",
        "games",
        "instantmessaging",
        "shopping",
        "socialnetworking",
        "arts",
        "fashionandbeauty",
        "general",
        "leisureandrecreation",
        "natureandconservation",
        "politicsandlaw",
        "realestate",
        "religion",
        "restaurantsanddining",
        "sports",
        "transportation",
        "travel",
      ]
    }
  }

  application_rule_collection {
    name     = "BlockWebCategories"
    priority = 200
    action   = "Deny"

    rule {
      name = "block-web-browsing"
      protocols {
        type = "Http"
        port = 80
      }
      protocols {
        type = "Https"
        port = 443
      }
      source_addresses = ["*"]
      web_categories = [
        "childabuseimages",
        "criminalactivity",
        "datingandpersonals",
        "gambling",
        "hacking",
        "hateandintolerance",
        "illegaldrug",
        "illegalsoftware",
        "lingerieandswimsuits",
        "marijuana",
        "nudity",
        "pornographyandsexuallyexplicit",
        "selfharm",
        "sexeducation",
        "tasteless",
        "violence",
        "weapons",
        "imagesharing",
        "peertopeer",
        "streamingmediaanddownloads",
        "downloadsites",
        "entertainment",
        "cults",
      ]
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
