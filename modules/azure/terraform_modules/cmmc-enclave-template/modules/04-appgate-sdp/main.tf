terraform {
  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = "~> 4.0"
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
  plan      = "v6_6_gov_vm"
}

# ---------------------------------------------------------------------------
# Appgate Controller VM
# ---------------------------------------------------------------------------

resource "azurerm_public_ip" "controller" {
  count               = var.deploy_vms ? 1 : 0
  name                = "${local.name_prefix}-ag-ctl-pip-1"
  location            = var.location
  resource_group_name = var.resource_group_name
  allocation_method   = "Static"
  sku                 = "Standard"
  domain_name_label   = "${local.name_prefix}-ag-ctl"
  tags                = var.tags
}

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
    public_ip_address_id          = azurerm_public_ip.controller[0].id
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
    sku       = "v6_6_gov_vm"
    version   = "6.6.0"
  }

  plan {
    name      = "v6_6_gov_vm"
    product   = "appgatesdp-vm"
    publisher = "cyxtera"
  }

  depends_on = [azurerm_marketplace_agreement.appgate]
}

# ---------------------------------------------------------------------------
# Appgate Gateway VM
# ---------------------------------------------------------------------------

resource "azurerm_public_ip" "gateway" {
  count               = var.deploy_vms ? 1 : 0
  name                = "${local.name_prefix}-ag-gw-pip-1"
  location            = var.location
  resource_group_name = var.resource_group_name
  allocation_method   = "Static"
  sku                 = "Standard"
  domain_name_label   = "${local.name_prefix}-ag-gw"
  tags                = var.tags
}

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
    public_ip_address_id          = azurerm_public_ip.gateway[0].id
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
    sku       = "v6_6_gov_vm"
    version   = "6.6.0"
  }

  plan {
    name      = "v6_6_gov_vm"
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

    # Controller rules
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
      name                = "ctl-https"
      protocols           = ["TCP"]
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

    # Gateway rules
    rule {
      name                = "gw-https"
      protocols           = ["TCP"]
      source_addresses    = ["*"]
      destination_address = var.firewall_public_ip
      destination_ports   = ["8444"]
      translated_address  = azurerm_network_interface.gateway[0].private_ip_address
      translated_port     = "443"
    }

    rule {
      name                = "gw-ssh"
      protocols           = ["TCP"]
      source_addresses    = var.source_admin_ips
      destination_address = var.firewall_public_ip
      destination_ports   = ["8022"]
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
# TODO: Appgate OIDC Application Registration
# ---------------------------------------------------------------------------

# resource "azuread_application" "appgate_oidc" {
#   display_name = "${var.customer_name} - Appgate OIDC"
#   ...
# }
