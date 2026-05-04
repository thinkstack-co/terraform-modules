terraform {
  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = "~> 4.0"
    }
  }
}

locals {
  fslogix_unc_path = "\\\\${var.fslogix_storage_account}.file.core.usgovcloudapi.net\\${var.fslogix_share_name}"
}

# ---------------------------------------------------------------------------
# Network Interfaces
# ---------------------------------------------------------------------------

resource "azurerm_network_interface" "session_host" {
  count               = var.host_count
  name                = "${var.customer_name}-avd-${format("%02d", count.index + 1)}-nic"
  location            = var.location
  resource_group_name = var.resource_group_name
  tags                = var.tags

  ip_configuration {
    name                          = "ipconfig1"
    subnet_id                     = var.subnet_id
    private_ip_address_allocation = "Dynamic"
  }
}

# ---------------------------------------------------------------------------
# Session Host VMs — Windows 11, Trusted Launch, Entra-joined
# ---------------------------------------------------------------------------

resource "azurerm_windows_virtual_machine" "session_host" {
  count               = var.host_count
  name                = "${var.customer_name}-avd-${format("%02d", count.index + 1)}"
  location            = var.location
  resource_group_name = var.resource_group_name
  size                = var.vm_size
  admin_username      = var.admin_username
  admin_password      = var.admin_password
  tags                = var.tags

  network_interface_ids = [azurerm_network_interface.session_host[count.index].id]

  # Trusted Launch (UEFI + vTPM)
  vtpm_enabled        = true
  secure_boot_enabled = true

  os_disk {
    caching              = "ReadWrite"
    storage_account_type = var.os_disk_type
    disk_size_gb         = 128
  }

  source_image_id = "${var.gallery_image_id}/versions/${var.image_version}"

  # Windows Client licensing for AVD
  license_type = "Windows_Client"

  identity {
    type = "SystemAssigned"
  }

  # Why: admin_password is set at VM creation but is expected to drift over
  # time (rotated out of band via Azure's reset-password flow, manually, or
  # by a separate rotation process). The azurerm provider treats any change
  # to admin_password as forcing replacement, which would destroy the VM and
  # all its extensions. Ignore drift so password rotation does not destroy
  # session hosts.
  lifecycle {
    ignore_changes = [admin_password]
  }
}

# ---------------------------------------------------------------------------
# Entra ID Join Extension
# ---------------------------------------------------------------------------

resource "azurerm_virtual_machine_extension" "aad_login" {
  count                = var.host_count
  name                 = "AADLoginForWindows"
  virtual_machine_id   = azurerm_windows_virtual_machine.session_host[count.index].id
  publisher            = "Microsoft.Azure.ActiveDirectory"
  type                 = "AADLoginForWindows"
  type_handler_version = "2.2"

  settings = jsonencode({
    mdmId       = ""
    environment = "AzureUSGovernment"
  })

  tags = var.tags

  # Why: virtual_machine_id is occasionally re-evaluated as "Known after apply"
  # in TFC plans even when the underlying VM is unchanged, which forces
  # replacement of this extension and re-runs the Entra join on an already-
  # joined device. Ignore drift on the parent VM ID to suppress that churn.
  lifecycle {
    ignore_changes = [virtual_machine_id]
  }
}

# ---------------------------------------------------------------------------
# AVD Agent Registration Extension
# ---------------------------------------------------------------------------

resource "azurerm_virtual_machine_extension" "avd_dsc" {
  count                = var.host_count
  name                 = "Microsoft.PowerShell.DSC"
  virtual_machine_id   = azurerm_windows_virtual_machine.session_host[count.index].id
  publisher            = "Microsoft.Powershell"
  type                 = "DSC"
  type_handler_version = "2.83"

  settings = jsonencode({
    modulesUrl            = "https://raw.githubusercontent.com/Azure/RDS-Templates/master/ARM-wvd-templates/DSC/Configuration.zip"
    configurationFunction = "Configuration.ps1\\AddSessionHost"
    properties = {
      HostPoolName        = split("/", var.host_pool_id)[8]
      RegistrationInfoToken = var.registration_token
      AadJoin             = true
    }
  })

  depends_on = [azurerm_virtual_machine_extension.aad_login]
  tags       = var.tags

  # Why: virtual_machine_id is occasionally re-evaluated as "Known after apply"
  # in TFC plans even when the underlying VM is unchanged, which forces
  # replacement of this extension and would briefly drop the host from the
  # AVD host pool (kicking active users) while DSC re-registers it. Ignore
  # drift on the parent VM ID to suppress that churn.
  lifecycle {
    ignore_changes = [virtual_machine_id]
  }
}

# ---------------------------------------------------------------------------
# FSLogix Configuration via Custom Script Extension
# ---------------------------------------------------------------------------

resource "azurerm_virtual_machine_extension" "fslogix" {
  count                = var.host_count
  name                 = "FSLogixSetup"
  virtual_machine_id   = azurerm_windows_virtual_machine.session_host[count.index].id
  publisher            = "Microsoft.Compute"
  type                 = "CustomScriptExtension"
  type_handler_version = "1.10"

  protected_settings = jsonencode({
    commandToExecute = join(" ", [
      "powershell -ExecutionPolicy Unrestricted -Command",
      "\"New-Item -Path 'HKLM:\\SOFTWARE\\FSLogix\\Profiles' -Force;",
      "Set-ItemProperty -Path 'HKLM:\\SOFTWARE\\FSLogix\\Profiles' -Name 'Enabled' -Value 1;",
      "Set-ItemProperty -Path 'HKLM:\\SOFTWARE\\FSLogix\\Profiles' -Name 'VHDLocations' -Value '${local.fslogix_unc_path}';",
      "net use ${local.fslogix_unc_path} /user:AZURE\\${var.fslogix_storage_account} '${var.fslogix_storage_key}' /persistent:yes\"",
    ])
  })

  depends_on = [azurerm_virtual_machine_extension.aad_login]
  tags       = var.tags

  # Why: virtual_machine_id is occasionally re-evaluated as "Known after apply"
  # in TFC plans even when the underlying VM is unchanged, which forces
  # replacement of this extension and re-runs the FSLogix registry/network
  # setup script. Ignore drift on the parent VM ID to suppress that churn.
  lifecycle {
    ignore_changes = [virtual_machine_id]
  }
}
