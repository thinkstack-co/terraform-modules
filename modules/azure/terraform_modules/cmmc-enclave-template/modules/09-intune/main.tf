terraform {
  required_providers {
    microsoft365 = {
      source  = "hashicorp/microsoft365"
      version = "~> 1.0"
    }
  }
}

# ---------------------------------------------------------------------------
# BitLocker Configuration Policy
# ---------------------------------------------------------------------------

resource "microsoft365_graph_beta_device_management_configuration_policy" "bitlocker" {
  name        = "CMMC - BitLocker Encryption"
  description = "Enforces BitLocker ${var.bitlocker_encryption_method} encryption on OS and fixed drives."
  platforms   = "windows10"
  technologies = "mdm"

  settings = jsonencode([
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
  ])
}

resource "microsoft365_graph_beta_device_management_configuration_policy_assignment" "bitlocker" {
  for_each  = toset(var.target_group_ids)
  policy_id = microsoft365_graph_beta_device_management_configuration_policy.bitlocker.id

  target = {
    "@odata.type" = "#microsoft.graph.groupAssignmentTarget"
    group_id      = each.value
  }
}

# ---------------------------------------------------------------------------
# Windows Defender Configuration Policy
# ---------------------------------------------------------------------------

resource "microsoft365_graph_beta_device_management_configuration_policy" "defender" {
  name        = "CMMC - Windows Defender Antivirus"
  description = "Configures Windows Defender for CMMC compliance."
  platforms   = "windows10"
  technologies = "mdm"

  settings = jsonencode([
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
  ])
}

resource "microsoft365_graph_beta_device_management_configuration_policy_assignment" "defender" {
  for_each  = toset(var.target_group_ids)
  policy_id = microsoft365_graph_beta_device_management_configuration_policy.defender.id

  target = {
    "@odata.type" = "#microsoft.graph.groupAssignmentTarget"
    group_id      = each.value
  }
}

# ---------------------------------------------------------------------------
# Windows Firewall Configuration Policy
# ---------------------------------------------------------------------------

resource "microsoft365_graph_beta_device_management_configuration_policy" "firewall" {
  name        = "CMMC - Windows Firewall"
  description = "Enables Windows Firewall on all profiles for CMMC compliance."
  platforms   = "windows10"
  technologies = "mdm"

  settings = jsonencode([
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
  ])
}

resource "microsoft365_graph_beta_device_management_configuration_policy_assignment" "firewall" {
  for_each  = toset(var.target_group_ids)
  policy_id = microsoft365_graph_beta_device_management_configuration_policy.firewall.id

  target = {
    "@odata.type" = "#microsoft.graph.groupAssignmentTarget"
    group_id      = each.value
  }
}

# ---------------------------------------------------------------------------
# Device Compliance Policy
# ---------------------------------------------------------------------------

resource "microsoft365_graph_beta_device_management_compliance_policy" "windows" {
  name        = "CMMC - Windows Device Compliance"
  description = "Enforces CMMC compliance requirements on Windows devices."
  platforms   = "windows10AndLater"

  settings = jsonencode([
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
  ])

  scheduled_actions_for_rule = [
    {
      rule_name = "MarkDeviceNonCompliant"
      scheduled_action_configurations = [
        {
          action_type        = "block"
          grace_period_hours = var.compliance_grace_period_hours
        }
      ]
    }
  ]
}

resource "microsoft365_graph_beta_device_management_compliance_policy_assignment" "windows" {
  for_each  = toset(var.target_group_ids)
  policy_id = microsoft365_graph_beta_device_management_compliance_policy.windows.id

  target = {
    "@odata.type" = "#microsoft.graph.groupAssignmentTarget"
    group_id      = each.value
  }
}
