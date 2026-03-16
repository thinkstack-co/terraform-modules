terraform {
  required_providers {
    msgraph = {
      source  = "microsoft/msgraph"
      version = "~> 0.3.0"
    }
  }
}

# ---------------------------------------------------------------------------
# BitLocker Configuration Policy
# ---------------------------------------------------------------------------

resource "msgraph_resource" "bitlocker" {
  url         = "deviceManagement/configurationPolicies"
  api_version = "beta"

  response_export_values = { id = "id" }

  body = jsonencode({
    name         = "CMMC - BitLocker Encryption"
    description  = "Enforces BitLocker ${var.bitlocker_encryption_method} encryption on OS and fixed drives."
    platforms    = "windows10"
    technologies = "mdm"
    settings = [
      {
        # Require BitLocker on OS drive
        "@odata.type" = "#microsoft.graph.deviceManagementConfigurationSetting"
        settingInstance = {
          "@odata.type"       = "#microsoft.graph.deviceManagementConfigurationChoiceSettingInstance"
          settingDefinitionId = "device_vendor_msft_bitlocker_requiredeviceencryption"
          choiceSettingValue = {
            value    = "device_vendor_msft_bitlocker_requiredeviceencryption_1"
            children = []
          }
        }
      },
      {
        # OS drive encryption method
        "@odata.type" = "#microsoft.graph.deviceManagementConfigurationSetting"
        settingInstance = {
          "@odata.type"       = "#microsoft.graph.deviceManagementConfigurationChoiceSettingInstance"
          settingDefinitionId = "device_vendor_msft_bitlocker_encryptionmethodbydrivetype_systemdrivesencryptiontype"
          choiceSettingValue = {
            value    = "device_vendor_msft_bitlocker_encryptionmethodbydrivetype_systemdrivesencryptiontype_${var.bitlocker_encryption_method}"
            children = []
          }
        }
      },
      {
        # Fixed drive encryption method
        "@odata.type" = "#microsoft.graph.deviceManagementConfigurationSetting"
        settingInstance = {
          "@odata.type"       = "#microsoft.graph.deviceManagementConfigurationChoiceSettingInstance"
          settingDefinitionId = "device_vendor_msft_bitlocker_encryptionmethodbydrivetype_fixeddrivesencryptiontype"
          choiceSettingValue = {
            value    = "device_vendor_msft_bitlocker_encryptionmethodbydrivetype_fixeddrivesencryptiontype_${var.bitlocker_encryption_method}"
            children = []
          }
        }
      },
      {
        # Require recovery information at startup
        "@odata.type" = "#microsoft.graph.deviceManagementConfigurationSetting"
        settingInstance = {
          "@odata.type"       = "#microsoft.graph.deviceManagementConfigurationChoiceSettingInstance"
          settingDefinitionId = "device_vendor_msft_bitlocker_systemdrivesrecoveryoptions_osrecoverykeyusage"
          choiceSettingValue = {
            value    = "device_vendor_msft_bitlocker_systemdrivesrecoveryoptions_osrecoverykeyusage_2"
            children = []
          }
        }
      }
    ]
  })
}

resource "msgraph_resource_action" "bitlocker_assign" {
  resource_url = "deviceManagement/configurationPolicies/${msgraph_resource.bitlocker.output.id}"
  action       = "assign"
  method       = "POST"
  api_version  = "beta"

  body = jsonencode({
    assignments = [for gid in var.target_group_ids : {
      target = {
        "@odata.type" = "#microsoft.graph.groupAssignmentTarget"
        groupId       = gid
      }
    }]
  })
}

# ---------------------------------------------------------------------------
# Windows Defender Configuration Policy
# ---------------------------------------------------------------------------

resource "msgraph_resource" "defender" {
  url         = "deviceManagement/configurationPolicies"
  api_version = "beta"

  response_export_values = { id = "id" }

  body = jsonencode({
    name         = "CMMC - Windows Defender Antivirus"
    description  = "Configures Windows Defender for CMMC compliance."
    platforms    = "windows10"
    technologies = "mdm"
    settings = [
      {
        # Real-time monitoring
        "@odata.type" = "#microsoft.graph.deviceManagementConfigurationSetting"
        settingInstance = {
          "@odata.type"       = "#microsoft.graph.deviceManagementConfigurationChoiceSettingInstance"
          settingDefinitionId = "device_vendor_msft_defender_allowrealtimemonitoring"
          choiceSettingValue = {
            value    = "device_vendor_msft_defender_allowrealtimemonitoring_1"
            children = []
          }
        }
      },
      {
        # Cloud-delivered protection
        "@odata.type" = "#microsoft.graph.deviceManagementConfigurationSetting"
        settingInstance = {
          "@odata.type"       = "#microsoft.graph.deviceManagementConfigurationChoiceSettingInstance"
          settingDefinitionId = "device_vendor_msft_defender_allowcloudprotection"
          choiceSettingValue = {
            value    = "device_vendor_msft_defender_allowcloudprotection_1"
            children = []
          }
        }
      },
      {
        # Behavior monitoring
        "@odata.type" = "#microsoft.graph.deviceManagementConfigurationSetting"
        settingInstance = {
          "@odata.type"       = "#microsoft.graph.deviceManagementConfigurationChoiceSettingInstance"
          settingDefinitionId = "device_vendor_msft_defender_allowbehaviormonitoring"
          choiceSettingValue = {
            value    = "device_vendor_msft_defender_allowbehaviormonitoring_1"
            children = []
          }
        }
      },
      {
        # Disable Xbox game scanning (not relevant in AVD context)
        "@odata.type" = "#microsoft.graph.deviceManagementConfigurationSetting"
        settingInstance = {
          "@odata.type"       = "#microsoft.graph.deviceManagementConfigurationChoiceSettingInstance"
          settingDefinitionId = "device_vendor_msft_defender_excludedprocesses"
          choiceSettingValue = {
            value    = "device_vendor_msft_defender_excludedprocesses_0"
            children = []
          }
        }
      }
    ]
  })
}

resource "msgraph_resource_action" "defender_assign" {
  resource_url = "deviceManagement/configurationPolicies/${msgraph_resource.defender.output.id}"
  action       = "assign"
  method       = "POST"
  api_version  = "beta"

  body = jsonencode({
    assignments = [for gid in var.target_group_ids : {
      target = {
        "@odata.type" = "#microsoft.graph.groupAssignmentTarget"
        groupId       = gid
      }
    }]
  })
}

# ---------------------------------------------------------------------------
# Windows Firewall Configuration Policy
# ---------------------------------------------------------------------------

resource "msgraph_resource" "firewall" {
  url         = "deviceManagement/configurationPolicies"
  api_version = "beta"

  response_export_values = { id = "id" }

  body = jsonencode({
    name         = "CMMC - Windows Firewall"
    description  = "Enables Windows Firewall on all profiles for CMMC compliance."
    platforms    = "windows10"
    technologies = "mdm"
    settings = [
      {
        # Domain profile firewall enabled
        "@odata.type" = "#microsoft.graph.deviceManagementConfigurationSetting"
        settingInstance = {
          "@odata.type"       = "#microsoft.graph.deviceManagementConfigurationChoiceSettingInstance"
          settingDefinitionId = "vendor_msft_firewall_mdmstore_domainprofile_enablefirewall"
          choiceSettingValue = {
            value    = "vendor_msft_firewall_mdmstore_domainprofile_enablefirewall_true"
            children = []
          }
        }
      },
      {
        # Private profile firewall enabled
        "@odata.type" = "#microsoft.graph.deviceManagementConfigurationSetting"
        settingInstance = {
          "@odata.type"       = "#microsoft.graph.deviceManagementConfigurationChoiceSettingInstance"
          settingDefinitionId = "vendor_msft_firewall_mdmstore_privateprofile_enablefirewall"
          choiceSettingValue = {
            value    = "vendor_msft_firewall_mdmstore_privateprofile_enablefirewall_true"
            children = []
          }
        }
      },
      {
        # Public profile firewall enabled
        "@odata.type" = "#microsoft.graph.deviceManagementConfigurationSetting"
        settingInstance = {
          "@odata.type"       = "#microsoft.graph.deviceManagementConfigurationChoiceSettingInstance"
          settingDefinitionId = "vendor_msft_firewall_mdmstore_publicprofile_enablefirewall"
          choiceSettingValue = {
            value    = "vendor_msft_firewall_mdmstore_publicprofile_enablefirewall_true"
            children = []
          }
        }
      }
    ]
  })
}

resource "msgraph_resource_action" "firewall_assign" {
  resource_url = "deviceManagement/configurationPolicies/${msgraph_resource.firewall.output.id}"
  action       = "assign"
  method       = "POST"
  api_version  = "beta"

  body = jsonencode({
    assignments = [for gid in var.target_group_ids : {
      target = {
        "@odata.type" = "#microsoft.graph.groupAssignmentTarget"
        groupId       = gid
      }
    }]
  })
}

# ---------------------------------------------------------------------------
# Device Compliance Policy
# ---------------------------------------------------------------------------

resource "msgraph_resource" "compliance_windows" {
  url         = "deviceManagement/compliancePolicies"
  api_version = "beta"

  response_export_values = { id = "id" }

  body = jsonencode({
    name        = "CMMC - Windows Device Compliance"
    description = "Enforces CMMC compliance requirements on Windows devices."
    platforms   = "windows10AndLater"
    settings = [
      {
        "@odata.type" = "#microsoft.graph.deviceManagementConfigurationSetting"
        settingInstance = {
          "@odata.type"       = "#microsoft.graph.deviceManagementConfigurationChoiceSettingInstance"
          settingDefinitionId = "deviceconfiguration--windows10compliancepolicy_antivirusenabled"
          choiceSettingValue = {
            value    = "deviceconfiguration--windows10compliancepolicy_antivirusenabled_true"
            children = []
          }
        }
      },
      {
        "@odata.type" = "#microsoft.graph.deviceManagementConfigurationSetting"
        settingInstance = {
          "@odata.type"       = "#microsoft.graph.deviceManagementConfigurationChoiceSettingInstance"
          settingDefinitionId = "deviceconfiguration--windows10compliancepolicy_defenderenabled"
          choiceSettingValue = {
            value    = "deviceconfiguration--windows10compliancepolicy_defenderenabled_true"
            children = []
          }
        }
      },
      {
        "@odata.type" = "#microsoft.graph.deviceManagementConfigurationSetting"
        settingInstance = {
          "@odata.type"       = "#microsoft.graph.deviceManagementConfigurationChoiceSettingInstance"
          settingDefinitionId = "deviceconfiguration--windows10compliancepolicy_firewallblocked"
          choiceSettingValue = {
            value    = "deviceconfiguration--windows10compliancepolicy_firewallblocked_false"
            children = []
          }
        }
      },
      {
        "@odata.type" = "#microsoft.graph.deviceManagementConfigurationSetting"
        settingInstance = {
          "@odata.type"       = "#microsoft.graph.deviceManagementConfigurationChoiceSettingInstance"
          settingDefinitionId = "deviceconfiguration--windows10compliancepolicy_bitlockerenabled"
          choiceSettingValue = {
            value    = "deviceconfiguration--windows10compliancepolicy_bitlockerenabled_true"
            children = []
          }
        }
      }
    ]
    scheduledActionsForRule = [
      {
        ruleName = "MarkDeviceNonCompliant"
        scheduledActionConfigurations = [
          {
            actionType       = "block"
            gracePeriodHours = var.compliance_grace_period_hours
          }
        ]
      }
    ]
  })
}

resource "msgraph_resource_action" "compliance_windows_assign" {
  resource_url = "deviceManagement/compliancePolicies/${msgraph_resource.compliance_windows.output.id}"
  action       = "assign"
  method       = "POST"
  api_version  = "beta"

  body = jsonencode({
    assignments = [for gid in var.target_group_ids : {
      target = {
        "@odata.type" = "#microsoft.graph.groupAssignmentTarget"
        groupId       = gid
      }
    }]
  })
}
