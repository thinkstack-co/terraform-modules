terraform {
  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = "~> 4.0"
    }
    azapi = {
      source  = "azure/azapi"
      version = "~> 2.0"
    }
  }
}

locals {
  name_prefix = "${var.customer_name}-aib"
}

# ---------------------------------------------------------------------------
# User-Assigned Managed Identity for Azure Image Builder
# ---------------------------------------------------------------------------

resource "azurerm_user_assigned_identity" "aib" {
  name                = "${local.name_prefix}-id"
  resource_group_name = var.resource_group_name
  location            = var.location
  tags                = var.tags
}

# AIB needs Contributor on the resource group to:
#   - Create/manage staging storage and temp build VMs
#   - Write image versions to the Compute Gallery (same RG)
resource "azurerm_role_assignment" "aib_contributor" {
  scope                = "/subscriptions/${var.subscription_id}/resourceGroups/${var.resource_group_name}"
  role_definition_name = "Contributor"
  principal_id         = azurerm_user_assigned_identity.aib.principal_id
}

# ---------------------------------------------------------------------------
# Image Template — Win11 Multi-Session + Windows Update + M365 Apps
# ---------------------------------------------------------------------------

resource "azapi_resource" "aib_template" {
  type      = "Microsoft.VirtualMachineImages/imageTemplates@2024-02-01"
  name      = "${local.name_prefix}-win11-m365"
  location  = var.location
  parent_id = "/subscriptions/${var.subscription_id}/resourceGroups/${var.resource_group_name}"

  identity {
    type         = "UserAssigned"
    identity_ids = [azurerm_user_assigned_identity.aib.id]
  }

  body = {
    properties = {
      buildTimeoutInMinutes = 120

      vmProfile = {
        vmSize       = "Standard_D4s_v3"
        osDiskSizeGB = 127
      }

      # Windows 11 Multi-Session (AVD-optimized) base image
      source = {
        type      = "PlatformImage"
        publisher = "MicrosoftWindowsDesktop"
        offer     = "windows-11"
        sku       = var.source_image_sku
        version   = "latest"
      }

      customize = [
        # Step 1: Apply all Windows Updates
        {
          type           = "WindowsUpdate"
          searchCriteria = "IsInstalled=0"
          filters        = ["exclude:$_.Title -like '*Preview*'"]
          updateLimit    = 40
        },
        # Step 2: Install M365 Apps via Office Deployment Tool
        {
          type = "PowerShell"
          name = "InstallM365Apps"
          inline = [
            "Write-Host 'Downloading Office Deployment Tool...'",
            "$odtPath = 'C:\\Windows\\Temp\\odt'",
            "New-Item -ItemType Directory -Path $odtPath -Force | Out-Null",
            "$odtExe = Join-Path $odtPath 'officedeploymenttool.exe'",
            "Invoke-WebRequest -Uri 'https://download.microsoft.com/download/2/7/A/27AF1BE6-DD20-4CB4-B154-EBAB8A7D4A7E/officedeploymenttool_17328-20162.exe' -OutFile $odtExe",
            "Start-Process -FilePath $odtExe -ArgumentList \"/quiet /extract:$odtPath\" -Wait",
            "@'",
            "<Configuration>",
            "  <Add OfficeClientEdition=\"64\" Channel=\"Current\">",
            "    <Product ID=\"O365ProPlusRetail\">",
            "      <Language ID=\"en-us\" />",
            "      <ExcludeApp ID=\"Teams\" />",
            "      <ExcludeApp ID=\"Groove\" />",
            "      <ExcludeApp ID=\"Lync\" />",
            "    </Product>",
            "  </Add>",
            "  <Property Name=\"SharedComputerLicensing\" Value=\"1\" />",
            "  <Property Name=\"PinIconsToTaskbar\" Value=\"FALSE\" />",
            "  <Display Level=\"None\" AcceptEULA=\"TRUE\" />",
            "  <Updates Enabled=\"TRUE\" />",
            "</Configuration>",
            "'@ | Set-Content -Path (Join-Path $odtPath 'config.xml')",
            "Write-Host 'Installing M365 Apps...'",
            "Start-Process -FilePath (Join-Path $odtPath 'setup.exe') -ArgumentList \"/configure $(Join-Path $odtPath 'config.xml')\" -Wait",
            "Write-Host 'M365 Apps installation complete.'",
          ]
        }
      ]

      distribute = [
        {
          type               = "SharedImage"
          galleryImageId     = var.gallery_image_definition_id
          runOutputName      = "win11-m365-output"
          replicationRegions = [var.location]
          storageAccountType = "Standard_LRS"
          artifactTags       = {}
        }
      ]
    }
  }

  tags = var.tags

  depends_on = [azurerm_role_assignment.aib_contributor]
}
