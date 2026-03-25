terraform {
  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = "~> 4.0"
    }
    azuread = {
      source  = "hashicorp/azuread"
      version = "~> 2.0"
    }
    tls = {
      source  = "hashicorp/tls"
      version = "~> 4.0"
    }
  }
}

locals {
  name_prefix = substr(replace(var.resource_group_name, "-rg", ""), 0, 12)
}

# ---------------------------------------------------------------------------
# SSH Key Pairs for Controller and Gateway
# ---------------------------------------------------------------------------

resource "tls_private_key" "controller" {
  algorithm = "RSA"
  rsa_bits  = 4096
}

resource "tls_private_key" "gateway" {
  algorithm = "RSA"
  rsa_bits  = 4096
}

# ---------------------------------------------------------------------------
# Key Vault — stores SSH private keys
# ---------------------------------------------------------------------------

data "azurerm_client_config" "current" {}

resource "azurerm_key_vault" "appgate" {
  name                = "${local.name_prefix}-ag-kv-1"
  location            = var.location
  resource_group_name = var.resource_group_name
  tenant_id           = var.tenant_id
  sku_name            = "standard"

  soft_delete_retention_days = 90
  purge_protection_enabled   = true

  tags = var.tags
}

resource "azurerm_key_vault_access_policy" "terraform_sp" {
  key_vault_id = azurerm_key_vault.appgate.id
  tenant_id    = var.tenant_id
  object_id    = data.azurerm_client_config.current.object_id

  secret_permissions = ["Get", "List", "Set", "Delete", "Recover", "Backup", "Restore", "Purge"]
}

resource "azurerm_key_vault_secret" "controller_key" {
  name         = "ag-ctl-private-key"
  value        = tls_private_key.controller.private_key_pem
  key_vault_id = azurerm_key_vault.appgate.id

  depends_on = [azurerm_key_vault_access_policy.terraform_sp]
}

resource "azurerm_key_vault_secret" "gateway_key" {
  name         = "ag-gw-private-key"
  value        = tls_private_key.gateway.private_key_pem
  key_vault_id = azurerm_key_vault.appgate.id

  depends_on = [azurerm_key_vault_access_policy.terraform_sp]
}

# ---------------------------------------------------------------------------
# Marketplace Agreement — cyxtera Appgate SDP
# ---------------------------------------------------------------------------

resource "azurerm_marketplace_agreement" "appgate" {
  publisher = "cyxtera"
  offer     = "appgatesdp-vm"
  plan      = "v6_5_vm"
}

# ---------------------------------------------------------------------------
# Appgate Controller VM
# ---------------------------------------------------------------------------

resource "azurerm_network_interface" "controller" {
  count               = var.deploy_vms ? 1 : 0
  name                = "${local.name_prefix}-ag-ctl-nic-1"
  location            = var.location
  resource_group_name = var.resource_group_name
  tags                = var.tags

  ip_configuration {
    name                          = "ipconfig1"
    subnet_id                     = var.ztna_subnet_id
    private_ip_address_allocation = "Dynamic"
  }
}

resource "azurerm_linux_virtual_machine" "controller" {
  count               = var.deploy_vms ? 1 : 0
  name                = "${local.name_prefix}-ag-ctl-1"
  location            = var.location
  resource_group_name = var.resource_group_name
  size                = var.controller_vm_size
  admin_username      = "appgate"
  tags                = var.tags

  network_interface_ids = [azurerm_network_interface.controller[0].id]

  admin_ssh_key {
    username   = "appgate"
    public_key = tls_private_key.controller.public_key_openssh
  }

  os_disk {
    caching              = "ReadWrite"
    storage_account_type = "Premium_LRS"
    disk_size_gb         = 128
  }

  source_image_reference {
    publisher = "cyxtera"
    offer     = "appgatesdp-vm"
    sku       = "v6_5_vm"
    version   = "6.5.4"
  }

  plan {
    name      = "v6_5_vm"
    product   = "appgatesdp-vm"
    publisher = "cyxtera"
  }

  depends_on = [azurerm_marketplace_agreement.appgate]
}

# ---------------------------------------------------------------------------
# Appgate Gateway VM
# ---------------------------------------------------------------------------

resource "azurerm_network_interface" "gateway" {
  count               = var.deploy_vms ? 1 : 0
  name                = "${local.name_prefix}-ag-gw-nic-1"
  location            = var.location
  resource_group_name = var.resource_group_name
  tags                = var.tags

  ip_configuration {
    name                          = "ipconfig1"
    subnet_id                     = var.ztna_subnet_id
    private_ip_address_allocation = "Dynamic"
  }
}

resource "azurerm_linux_virtual_machine" "gateway" {
  count               = var.deploy_vms ? 1 : 0
  name                = "${local.name_prefix}-ag-gw-1"
  location            = var.location
  resource_group_name = var.resource_group_name
  size                = var.gateway_vm_size
  admin_username      = "appgate"
  tags                = var.tags

  network_interface_ids = [azurerm_network_interface.gateway[0].id]

  admin_ssh_key {
    username   = "appgate"
    public_key = tls_private_key.gateway.public_key_openssh
  }

  os_disk {
    caching              = "ReadWrite"
    storage_account_type = "Premium_LRS"
    disk_size_gb         = 128
  }

  source_image_reference {
    publisher = "cyxtera"
    offer     = "appgatesdp-vm"
    sku       = "v6_5_vm"
    version   = "6.5.4"
  }

  plan {
    name      = "v6_5_vm"
    product   = "appgatesdp-vm"
    publisher = "cyxtera"
  }

  depends_on = [azurerm_marketplace_agreement.appgate]
}

# ---------------------------------------------------------------------------
# Firewall DNAT + Network Rules for Appgate SDP
# ---------------------------------------------------------------------------

resource "azurerm_firewall_policy_rule_collection_group" "appgate" {
  count              = var.deploy_vms ? 1 : 0
  name               = "${local.name_prefix}-afwp-appgate-rcg"
  firewall_policy_id = var.firewall_policy_id
  priority           = 100

  nat_rule_collection {
    name     = "AppgateDNAT"
    priority = 100
    action   = "Dnat"

    # ── Controller (firewall PIP[0] / var.firewall_public_ip) ────────────

    rule {
      name                = "ctl-admin-ui"
      protocols           = ["TCP"]
      source_addresses    = var.source_admin_ips
      destination_address = var.firewall_public_ip
      destination_ports   = ["8443"]
      translated_address  = azurerm_network_interface.controller[0].private_ip_address
      translated_port     = "8443"
    }

    rule {
      name                = "ctl-https-tcp"
      protocols           = ["TCP"]
      source_addresses    = ["*"]
      destination_address = var.firewall_public_ip
      destination_ports   = ["443"]
      translated_address  = azurerm_network_interface.controller[0].private_ip_address
      translated_port     = "443"
    }

    rule {
      name                = "ctl-spa-udp"
      protocols           = ["UDP"]
      source_addresses    = ["*"]
      destination_address = var.firewall_public_ip
      destination_ports   = ["443"]
      translated_address  = azurerm_network_interface.controller[0].private_ip_address
      translated_port     = "443"
    }

    rule {
      name                = "ctl-ssh"
      protocols           = ["TCP"]
      source_addresses    = var.source_admin_ips
      destination_address = var.firewall_public_ip
      destination_ports   = ["22"]
      translated_address  = azurerm_network_interface.controller[0].private_ip_address
      translated_port     = "22"
    }

    # ── Gateway (firewall PIP[1] / var.gateway_firewall_public_ip) ───────

    rule {
      name                = "gw-https-tcp"
      protocols           = ["TCP"]
      source_addresses    = ["*"]
      destination_address = var.gateway_firewall_public_ip
      destination_ports   = ["443"]
      translated_address  = azurerm_network_interface.gateway[0].private_ip_address
      translated_port     = "443"
    }

    rule {
      name                = "gw-spa-udp"
      protocols           = ["UDP"]
      source_addresses    = ["*"]
      destination_address = var.gateway_firewall_public_ip
      destination_ports   = ["443"]
      translated_address  = azurerm_network_interface.gateway[0].private_ip_address
      translated_port     = "443"
    }

    rule {
      name                = "gw-ssh"
      protocols           = ["TCP"]
      source_addresses    = var.source_admin_ips
      destination_address = var.gateway_firewall_public_ip
      destination_ports   = ["22"]
      translated_address  = azurerm_network_interface.gateway[0].private_ip_address
      translated_port     = "22"
    }
  }

  network_rule_collection {
    name     = "AppgateNetwork"
    priority = 200
    action   = "Allow"

    rule {
      name                  = "appgate-ntp"
      protocols             = ["UDP"]
      source_addresses      = ["172.16.0.128/26"]
      destination_addresses = ["91.189.91.157", "91.189.89.198", "91.189.94.4", "91.189.91.156"]
      destination_ports     = ["123"]
    }
  }
}

# ---------------------------------------------------------------------------
# Appgate OIDC Application Registration (Entra ID)
# ---------------------------------------------------------------------------

resource "azuread_application" "appgate_oidc" {
  display_name            = "${var.customer_name} - Appgate OIDC"
  group_membership_claims = ["SecurityGroup"]

  public_client {
    redirect_uris = ["appgate://oidccallback"]
  }

  required_resource_access {
    resource_app_id = "00000003-0000-0000-c000-000000000000" # Microsoft Graph

    resource_access {
      id   = "37f7f235-527c-4136-accd-4a02d197296e" # openid
      type = "Scope"
    }

    resource_access {
      id   = "14dad69e-099b-42c9-810b-d002981feec1" # profile
      type = "Scope"
    }

    resource_access {
      id   = "64a6cdd6-aab1-4aaf-94b8-3cc8405e90d6" # email
      type = "Scope"
    }

    resource_access {
      id   = "7427e0e9-2fba-42fe-b0c0-848c9e6a8182" # offline_access
      type = "Scope"
    }
  }
}

resource "azuread_service_principal" "appgate_oidc" {
  client_id = azuread_application.appgate_oidc.client_id
}
