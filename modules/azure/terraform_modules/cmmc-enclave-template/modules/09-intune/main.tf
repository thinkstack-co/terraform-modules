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
    assignments = [{
      target = {
        "@odata.type" = "#microsoft.graph.groupAssignmentTarget"
        groupId       = var.avd_host_group_id
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

# ---------------------------------------------------------------------------
# Configure device and resource redirection
# ---------------------------------------------------------------------------

resource "msgraph_resource" "settings_catalog_rdp_redirection" {
  url         = "deviceManagement/configurationPolicies"
  api_version = "beta"

  response_export_values = { id = "id" }

  body = jsonencode({
    name         = "Configure device and resource redirection"
    description  = ""
    platforms    = "windows10"
    technologies = "mdm"
    settings = [
      { id = "0", settingInstance = { settingInstanceTemplateReference = null, "@odata.type" = "#microsoft.graph.deviceManagementConfigurationChoiceSettingInstance", settingDefinitionId = "device_vendor_msft_policy_config_admx_terminalserver_ts_time_zone", choiceSettingValue = { settingValueTemplateReference = null, children = [], value = "device_vendor_msft_policy_config_admx_terminalserver_ts_time_zone_1" } } },
      { id = "1", settingInstance = { settingInstanceTemplateReference = null, "@odata.type" = "#microsoft.graph.deviceManagementConfigurationChoiceSettingInstance", settingDefinitionId = "device_vendor_msft_policy_config_admx_terminalserver_ts_client_clipboard", choiceSettingValue = { settingValueTemplateReference = null, children = [], value = "device_vendor_msft_policy_config_admx_terminalserver_ts_client_clipboard_1" } } },
      { id = "2", settingInstance = { settingInstanceTemplateReference = null, "@odata.type" = "#microsoft.graph.deviceManagementConfigurationChoiceSettingInstance", settingDefinitionId = "device_vendor_msft_policy_config_admx_terminalserver_ts_client_com", choiceSettingValue = { settingValueTemplateReference = null, children = [], value = "device_vendor_msft_policy_config_admx_terminalserver_ts_client_com_1" } } },
      { id = "3", settingInstance = { settingInstanceTemplateReference = null, "@odata.type" = "#microsoft.graph.deviceManagementConfigurationChoiceSettingInstance", settingDefinitionId = "device_vendor_msft_policy_config_remotedesktopservices_donotallowdriveredirection", choiceSettingValue = { settingValueTemplateReference = null, children = [], value = "device_vendor_msft_policy_config_remotedesktopservices_donotallowdriveredirection_1" } } },
      { id = "4", settingInstance = { settingInstanceTemplateReference = null, "@odata.type" = "#microsoft.graph.deviceManagementConfigurationChoiceSettingInstance", settingDefinitionId = "device_vendor_msft_policy_config_admx_terminalserver_ts_client_lpt", choiceSettingValue = { settingValueTemplateReference = null, children = [], value = "device_vendor_msft_policy_config_admx_terminalserver_ts_client_lpt_1" } } },
      { id = "5", settingInstance = { settingInstanceTemplateReference = null, "@odata.type" = "#microsoft.graph.deviceManagementConfigurationChoiceSettingInstance", settingDefinitionId = "device_vendor_msft_policy_config_admx_terminalserver_ts_smart_card", choiceSettingValue = { settingValueTemplateReference = null, children = [], value = "device_vendor_msft_policy_config_admx_terminalserver_ts_smart_card_1" } } },
      { id = "6", settingInstance = { settingInstanceTemplateReference = null, "@odata.type" = "#microsoft.graph.deviceManagementConfigurationChoiceSettingInstance", settingDefinitionId = "device_vendor_msft_policy_config_admx_terminalserver_ts_client_pnp", choiceSettingValue = { settingValueTemplateReference = null, children = [], value = "device_vendor_msft_policy_config_admx_terminalserver_ts_client_pnp_1" } } },
    ]
  })
}

resource "msgraph_resource_action" "rdp_redirection_assign" {
  resource_url = "deviceManagement/configurationPolicies/${msgraph_resource.settings_catalog_rdp_redirection.output.id}"
  action       = "assign"
  method       = "POST"
  api_version  = "beta"
  body = jsonencode({ assignments = [{ target = { "@odata.type" = "#microsoft.graph.groupAssignmentTarget", groupId = var.avd_host_group_id } }] })
}

# ---------------------------------------------------------------------------
# Configure GPU acceleration for Azure Virtual Desktop (optional)
# ---------------------------------------------------------------------------

resource "msgraph_resource" "settings_catalog_gpu_acceleration" {
  count       = var.gpu_vm_group_id != null ? 1 : 0
  url         = "deviceManagement/configurationPolicies"
  api_version = "beta"

  response_export_values = { id = "id" }

  body = jsonencode({
    name         = "Configure GPU acceleration for Azure Virtual Desktop"
    description  = "Azure Virtual Desktop supports GPU acceleration in rendering and encoding for improved app performance and scalability."
    platforms    = "windows10"
    technologies = "mdm"
    settings = [
      { id = "0", settingInstance = { settingInstanceTemplateReference = null, "@odata.type" = "#microsoft.graph.deviceManagementConfigurationChoiceSettingInstance", settingDefinitionId = "device_vendor_msft_policy_config_admx_terminalserver_ts_server_avc_hw_encode_preferred", choiceSettingValue = { settingValueTemplateReference = null, children = [], value = "device_vendor_msft_policy_config_admx_terminalserver_ts_server_avc_hw_encode_preferred_1" } } },
      { id = "1", settingInstance = { settingInstanceTemplateReference = null, "@odata.type" = "#microsoft.graph.deviceManagementConfigurationChoiceSettingInstance", settingDefinitionId = "device_vendor_msft_policy_config_admx_terminalserver_ts_server_avc444_mode_preferred", choiceSettingValue = { settingValueTemplateReference = null, children = [], value = "device_vendor_msft_policy_config_admx_terminalserver_ts_server_avc444_mode_preferred_1" } } },
      { id = "2", settingInstance = { settingInstanceTemplateReference = null, "@odata.type" = "#microsoft.graph.deviceManagementConfigurationChoiceSettingInstance", settingDefinitionId = "device_vendor_msft_policy_config_admx_terminalserver_ts_dx_use_full_hwgpu", choiceSettingValue = { settingValueTemplateReference = null, children = [], value = "device_vendor_msft_policy_config_admx_terminalserver_ts_dx_use_full_hwgpu_1" } } },
    ]
  })
}

resource "msgraph_resource_action" "gpu_acceleration_assign" {
  count        = var.gpu_vm_group_id != null ? 1 : 0
  resource_url = "deviceManagement/configurationPolicies/${msgraph_resource.settings_catalog_gpu_acceleration[0].output.id}"
  action       = "assign"
  method       = "POST"
  api_version  = "beta"
  body = jsonencode({ assignments = [{ target = { "@odata.type" = "#microsoft.graph.groupAssignmentTarget", groupId = var.gpu_vm_group_id } }] })
}

# ---------------------------------------------------------------------------
# Configure OneDrive settings
# ---------------------------------------------------------------------------

resource "msgraph_resource" "settings_catalog_onedrive" {
  url         = "deviceManagement/configurationPolicies"
  api_version = "beta"

  response_export_values = { id = "id" }

  body = jsonencode({
    name         = "Configure OneDrive settings"
    description  = ""
    platforms    = "windows10"
    technologies = "mdm"
    settings = [
      {
        id = "0"
        settingInstance = {
          settingInstanceTemplateReference = null
          "@odata.type"       = "#microsoft.graph.deviceManagementConfigurationChoiceSettingInstance"
          settingDefinitionId = "device_vendor_msft_policy_config_onedrivengscv2~policy~onedrivengsc_allowtenantlist"
          choiceSettingValue = {
            settingValueTemplateReference = null
            value    = "device_vendor_msft_policy_config_onedrivengscv2~policy~onedrivengsc_allowtenantlist_1"
            children = [{
              settingInstanceTemplateReference = null
              "@odata.type"       = "#microsoft.graph.deviceManagementConfigurationSimpleSettingCollectionInstance"
              settingDefinitionId = "device_vendor_msft_policy_config_onedrivengscv2~policy~onedrivengsc_allowtenantlist_allowtenantlistbox"
              simpleSettingCollectionValue = [{ settingValueTemplateReference = null, "@odata.type" = "#microsoft.graph.deviceManagementConfigurationStringSettingValue", value = var.tenant_id }]
            }]
          }
        }
      },
      {
        id = "1"
        settingInstance = {
          settingInstanceTemplateReference = null
          "@odata.type"       = "#microsoft.graph.deviceManagementConfigurationChoiceSettingInstance"
          settingDefinitionId = "device_vendor_msft_policy_config_onedrivengscv4~policy~onedrivengsc_enableodignorelistfromgpo"
          choiceSettingValue = {
            settingValueTemplateReference = null
            value    = "device_vendor_msft_policy_config_onedrivengscv4~policy~onedrivengsc_enableodignorelistfromgpo_1"
            children = [{
              settingInstanceTemplateReference = null
              "@odata.type"       = "#microsoft.graph.deviceManagementConfigurationSimpleSettingCollectionInstance"
              settingDefinitionId = "device_vendor_msft_policy_config_onedrivengscv4~policy~onedrivengsc_enableodignorelistfromgpo_enableodignorelistfromgpolistbox"
              simpleSettingCollectionValue = [
                { settingValueTemplateReference = null, "@odata.type" = "#microsoft.graph.deviceManagementConfigurationStringSettingValue", value = "*.mp3" },
                { settingValueTemplateReference = null, "@odata.type" = "#microsoft.graph.deviceManagementConfigurationStringSettingValue", value = "*.pst" },
              ]
            }]
          }
        }
      },
      { id = "2", settingInstance = { settingInstanceTemplateReference = null, "@odata.type" = "#microsoft.graph.deviceManagementConfigurationChoiceSettingInstance", settingDefinitionId = "device_vendor_msft_policy_config_onedrivengscv2~policy~onedrivengsc_blockexternalsync", choiceSettingValue = { settingValueTemplateReference = null, children = [], value = "device_vendor_msft_policy_config_onedrivengscv2~policy~onedrivengsc_blockexternalsync_1" } } },
      {
        id = "3"
        settingInstance = {
          settingInstanceTemplateReference = null
          "@odata.type"       = "#microsoft.graph.deviceManagementConfigurationChoiceSettingInstance"
          settingDefinitionId = "device_vendor_msft_policy_config_onedrivengscv2~policy~onedrivengsc_kfmoptinwithwizard"
          choiceSettingValue = {
            settingValueTemplateReference = null
            value    = "device_vendor_msft_policy_config_onedrivengscv2~policy~onedrivengsc_kfmoptinwithwizard_1"
            children = [{
              settingInstanceTemplateReference = null
              "@odata.type"       = "#microsoft.graph.deviceManagementConfigurationSimpleSettingInstance"
              settingDefinitionId = "device_vendor_msft_policy_config_onedrivengscv2~policy~onedrivengsc_kfmoptinwithwizard_kfmoptinwithwizard_textbox"
              simpleSettingValue  = { settingValueTemplateReference = null, "@odata.type" = "#microsoft.graph.deviceManagementConfigurationStringSettingValue", value = var.tenant_id }
            }]
          }
        }
      },
      {
        id = "4"
        settingInstance = {
          settingInstanceTemplateReference = null
          "@odata.type"       = "#microsoft.graph.deviceManagementConfigurationChoiceSettingInstance"
          settingDefinitionId = "device_vendor_msft_policy_config_onedrivengscv3~policy~onedrivengsc_localmassdeletefiledeletethreshold"
          choiceSettingValue = {
            settingValueTemplateReference = null
            value    = "device_vendor_msft_policy_config_onedrivengscv3~policy~onedrivengsc_localmassdeletefiledeletethreshold_1"
            children = [{
              settingInstanceTemplateReference = null
              "@odata.type"       = "#microsoft.graph.deviceManagementConfigurationSimpleSettingInstance"
              settingDefinitionId = "device_vendor_msft_policy_config_onedrivengscv3~policy~onedrivengsc_localmassdeletefiledeletethreshold_lmdfiledeletethresholdbox"
              simpleSettingValue  = { settingValueTemplateReference = null, "@odata.type" = "#microsoft.graph.deviceManagementConfigurationIntegerSettingValue", value = 25 }
            }]
          }
        }
      },
      { id = "5", settingInstance = { settingInstanceTemplateReference = null, "@odata.type" = "#microsoft.graph.deviceManagementConfigurationChoiceSettingInstance", settingDefinitionId = "device_vendor_msft_policy_config_onedrivengscv2~policy~onedrivengsc_forcedlocalmassdeletedetection", choiceSettingValue = { settingValueTemplateReference = null, children = [], value = "device_vendor_msft_policy_config_onedrivengscv2~policy~onedrivengsc_forcedlocalmassdeletedetection_1" } } },
      {
        id = "6"
        settingInstance = {
          settingInstanceTemplateReference = null
          "@odata.type"       = "#microsoft.graph.deviceManagementConfigurationChoiceSettingInstance"
          settingDefinitionId = "device_vendor_msft_policy_config_onedrivengscv2~policy~onedrivengsc_kfmoptinnowizard"
          choiceSettingValue = {
            settingValueTemplateReference = null
            value    = "device_vendor_msft_policy_config_onedrivengscv2~policy~onedrivengsc_kfmoptinnowizard_1"
            children = [
              {
                settingInstanceTemplateReference = null
                "@odata.type"       = "#microsoft.graph.deviceManagementConfigurationChoiceSettingInstance"
                settingDefinitionId = "device_vendor_msft_policy_config_onedrivengscv2~policy~onedrivengsc_kfmoptinnowizard_kfmoptinnowizard_dropdown"
                choiceSettingValue  = { settingValueTemplateReference = null, children = [], value = "device_vendor_msft_policy_config_onedrivengscv2~policy~onedrivengsc_kfmoptinnowizard_kfmoptinnowizard_dropdown_0" }
              },
              {
                settingInstanceTemplateReference = null
                "@odata.type"       = "#microsoft.graph.deviceManagementConfigurationSimpleSettingInstance"
                settingDefinitionId = "device_vendor_msft_policy_config_onedrivengscv2~policy~onedrivengsc_kfmoptinnowizard_kfmoptinnowizard_textbox"
                simpleSettingValue  = { settingValueTemplateReference = null, "@odata.type" = "#microsoft.graph.deviceManagementConfigurationStringSettingValue", value = var.tenant_id }
              },
            ]
          }
        }
      },
      { id = "7", settingInstance = { settingInstanceTemplateReference = null, "@odata.type" = "#microsoft.graph.deviceManagementConfigurationChoiceSettingInstance", settingDefinitionId = "device_vendor_msft_policy_config_onedrivengscv2~policy~onedrivengsc_silentaccountconfig", choiceSettingValue = { settingValueTemplateReference = null, children = [], value = "device_vendor_msft_policy_config_onedrivengscv2~policy~onedrivengsc_silentaccountconfig_1" } } },
    ]
  })
}

resource "msgraph_resource_action" "onedrive_assign" {
  resource_url = "deviceManagement/configurationPolicies/${msgraph_resource.settings_catalog_onedrive.output.id}"
  action       = "assign"
  method       = "POST"
  api_version  = "beta"
  body = jsonencode({ assignments = [{ target = { "@odata.type" = "#microsoft.graph.groupAssignmentTarget", groupId = var.avd_host_group_id } }] })
}

# ---------------------------------------------------------------------------
# Configure Windows NTP client
# ---------------------------------------------------------------------------

resource "msgraph_resource" "settings_catalog_ntp" {
  url         = "deviceManagement/configurationPolicies"
  api_version = "beta"

  response_export_values = { id = "id" }

  body = jsonencode({
    name         = "Configure Windows NTP client"
    description  = ""
    platforms    = "windows10"
    technologies = "mdm"
    settings = [{
      id = "0"
      settingInstance = {
        settingInstanceTemplateReference = null
        "@odata.type"       = "#microsoft.graph.deviceManagementConfigurationChoiceSettingInstance"
        settingDefinitionId = "device_vendor_msft_policy_config_admx_w32time_w32time_policy_configure_ntpclient"
        choiceSettingValue = {
          settingValueTemplateReference = null
          value    = "device_vendor_msft_policy_config_admx_w32time_w32time_policy_configure_ntpclient_1"
          children = [
            { settingInstanceTemplateReference = null, "@odata.type" = "#microsoft.graph.deviceManagementConfigurationSimpleSettingInstance", settingDefinitionId = "device_vendor_msft_policy_config_admx_w32time_w32time_policy_configure_ntpclient_w32time_crosssitesyncflags", simpleSettingValue = { settingValueTemplateReference = null, "@odata.type" = "#microsoft.graph.deviceManagementConfigurationIntegerSettingValue", value = 2 } },
            { settingInstanceTemplateReference = null, "@odata.type" = "#microsoft.graph.deviceManagementConfigurationSimpleSettingInstance", settingDefinitionId = "device_vendor_msft_policy_config_admx_w32time_w32time_policy_configure_ntpclient_w32time_ntpclienteventlogflags", simpleSettingValue = { settingValueTemplateReference = null, "@odata.type" = "#microsoft.graph.deviceManagementConfigurationIntegerSettingValue", value = 0 } },
            { settingInstanceTemplateReference = null, "@odata.type" = "#microsoft.graph.deviceManagementConfigurationSimpleSettingInstance", settingDefinitionId = "device_vendor_msft_policy_config_admx_w32time_w32time_policy_configure_ntpclient_w32time_ntpserver", simpleSettingValue = { settingValueTemplateReference = null, "@odata.type" = "#microsoft.graph.deviceManagementConfigurationStringSettingValue", value = "time.nist.gov0x01" } },
            { settingInstanceTemplateReference = null, "@odata.type" = "#microsoft.graph.deviceManagementConfigurationSimpleSettingInstance", settingDefinitionId = "device_vendor_msft_policy_config_admx_w32time_w32time_policy_configure_ntpclient_w32time_resolvepeerbackoffmaxtimes", simpleSettingValue = { settingValueTemplateReference = null, "@odata.type" = "#microsoft.graph.deviceManagementConfigurationIntegerSettingValue", value = 7 } },
            { settingInstanceTemplateReference = null, "@odata.type" = "#microsoft.graph.deviceManagementConfigurationSimpleSettingInstance", settingDefinitionId = "device_vendor_msft_policy_config_admx_w32time_w32time_policy_configure_ntpclient_w32time_resolvepeerbackoffminutes", simpleSettingValue = { settingValueTemplateReference = null, "@odata.type" = "#microsoft.graph.deviceManagementConfigurationIntegerSettingValue", value = 15 } },
            { settingInstanceTemplateReference = null, "@odata.type" = "#microsoft.graph.deviceManagementConfigurationSimpleSettingInstance", settingDefinitionId = "device_vendor_msft_policy_config_admx_w32time_w32time_policy_configure_ntpclient_w32time_specialpollinterval", simpleSettingValue = { settingValueTemplateReference = null, "@odata.type" = "#microsoft.graph.deviceManagementConfigurationIntegerSettingValue", value = 3600 } },
            { settingInstanceTemplateReference = null, "@odata.type" = "#microsoft.graph.deviceManagementConfigurationChoiceSettingInstance", settingDefinitionId = "device_vendor_msft_policy_config_admx_w32time_w32time_policy_configure_ntpclient_w32time_type", choiceSettingValue = { settingValueTemplateReference = null, children = [], value = "device_vendor_msft_policy_config_admx_w32time_w32time_policy_configure_ntpclient_w32time_type_ntp" } },
          ]
        }
      }
    }]
  })
}

resource "msgraph_resource_action" "ntp_assign" {
  resource_url = "deviceManagement/configurationPolicies/${msgraph_resource.settings_catalog_ntp.output.id}"
  action       = "assign"
  method       = "POST"
  api_version  = "beta"
  body = jsonencode({ assignments = [{ target = { "@odata.type" = "#microsoft.graph.groupAssignmentTarget", groupId = var.avd_host_group_id } }] })
}

# ---------------------------------------------------------------------------
# Disable password reveal
# ---------------------------------------------------------------------------

resource "msgraph_resource" "settings_catalog_password_reveal" {
  url         = "deviceManagement/configurationPolicies"
  api_version = "beta"

  response_export_values = { id = "id" }

  body = jsonencode({
    name         = "Disable password reveal"
    description  = "Disables the password reveal button"
    platforms    = "windows10"
    technologies = "mdm"
    settings = [{ id = "0", settingInstance = { settingInstanceTemplateReference = null, "@odata.type" = "#microsoft.graph.deviceManagementConfigurationChoiceSettingInstance", settingDefinitionId = "user_vendor_msft_policy_config_credentialsui_disablepasswordreveal", choiceSettingValue = { settingValueTemplateReference = null, children = [], value = "user_vendor_msft_policy_config_credentialsui_disablepasswordreveal_1" } } }]
  })
}

resource "msgraph_resource_action" "password_reveal_assign" {
  resource_url = "deviceManagement/configurationPolicies/${msgraph_resource.settings_catalog_password_reveal.output.id}"
  action       = "assign"
  method       = "POST"
  api_version  = "beta"
  body = jsonencode({ assignments = [{ target = { "@odata.type" = "#microsoft.graph.groupAssignmentTarget", groupId = var.all_users_group_id } }] })
}

# ---------------------------------------------------------------------------
# Enable Azure Information Protection add-in for sensitivity labeling
# ---------------------------------------------------------------------------

resource "msgraph_resource" "settings_catalog_aip" {
  url         = "deviceManagement/configurationPolicies"
  api_version = "beta"

  response_export_values = { id = "id" }

  body = jsonencode({
    name         = "Enable Azure Information Protection add-in for sensitivity labeling"
    description  = "Enables the policy that ensures Azure Information Protection add-in for sensitivity labeling is present"
    platforms    = "windows10"
    technologies = "mdm"
    settings = [
      { id = "0", settingInstance = { settingInstanceTemplateReference = null, "@odata.type" = "#microsoft.graph.deviceManagementConfigurationChoiceSettingInstance", settingDefinitionId = "user_vendor_msft_policy_config_office16v13~policy~l_microsoftofficesystem~l_securitysettings_l_aipexception", choiceSettingValue = { settingValueTemplateReference = null, children = [], value = "user_vendor_msft_policy_config_office16v13~policy~l_microsoftofficesystem~l_securitysettings_l_aipexception_1" } } },
      { id = "1", settingInstance = { settingInstanceTemplateReference = null, "@odata.type" = "#microsoft.graph.deviceManagementConfigurationChoiceSettingInstance", settingDefinitionId = "user_vendor_msft_policy_config_office16v3~policy~l_microsoftofficesystem~l_securitysettings_l_useofficeforlabelling", choiceSettingValue = { settingValueTemplateReference = null, children = [], value = "user_vendor_msft_policy_config_office16v3~policy~l_microsoftofficesystem~l_securitysettings_l_useofficeforlabelling_0" } } },
    ]
  })
}

resource "msgraph_resource_action" "aip_assign" {
  resource_url = "deviceManagement/configurationPolicies/${msgraph_resource.settings_catalog_aip.output.id}"
  action       = "assign"
  method       = "POST"
  api_version  = "beta"
  body = jsonencode({ assignments = [{ target = { "@odata.type" = "#microsoft.graph.groupAssignmentTarget", groupId = var.all_users_group_id } }] })
}

# ---------------------------------------------------------------------------
# Enable interactive logon banner
# ---------------------------------------------------------------------------

resource "msgraph_resource" "settings_catalog_logon_banner" {
  url         = "deviceManagement/configurationPolicies"
  api_version = "beta"

  response_export_values = { id = "id" }

  body = jsonencode({
    name         = "Enable interactive logon banner"
    description  = "Displays interactive logon"
    platforms    = "windows10"
    technologies = "mdm"
    settings = [
      {
        id = "0"
        settingInstance = {
          settingInstanceTemplateReference = null
          "@odata.type"       = "#microsoft.graph.deviceManagementConfigurationSimpleSettingCollectionInstance"
          settingDefinitionId = "device_vendor_msft_policy_config_localpoliciessecurityoptions_interactivelogon_messagetextforusersattemptingtologon"
          simpleSettingCollectionValue = [{
            settingValueTemplateReference = null
            "@odata.type" = "#microsoft.graph.deviceManagementConfigurationStringSettingValue"
            value         = "This system is the property of ${var.customer_name} and is intended for authorized users only. Employees and users of ${var.customer_name}'s Electronic Systems (including desktop computers laptop computers servers mobile devices email Internet access and business applications) should have no expectation of privacy with regard to use of these resources. All individuals' activities while using ${var.customer_name}'s Electronic Systems may be monitored and audited. By signing on and using any of these Electronic Systems users acknowledge that all data messages documents etc. sent received or reviewed while using these Electronic Systems are property of ${var.customer_name}. Additionally this system contains federal contract information and/or Controlled Unclassified Information (CUI). By using this system (which includes any device attached to this system) you consent to abide by ${var.customer_name}'s policies regarding CUI. You further acknowledge that failure to abide by these terms and usage requirements may result in revoked or suspended access privileges."
          }]
        }
      },
      {
        id = "1"
        settingInstance = {
          settingInstanceTemplateReference = null
          "@odata.type"       = "#microsoft.graph.deviceManagementConfigurationSimpleSettingInstance"
          settingDefinitionId = "device_vendor_msft_policy_config_localpoliciessecurityoptions_interactivelogon_messagetitleforusersattemptingtologon"
          simpleSettingValue = {
            settingValueTemplateReference = null
            "@odata.type" = "#microsoft.graph.deviceManagementConfigurationStringSettingValue"
            value         = "${var.customer_name} Terms of Use"
          }
        }
      },
    ]
  })
}

resource "msgraph_resource_action" "logon_banner_assign" {
  resource_url = "deviceManagement/configurationPolicies/${msgraph_resource.settings_catalog_logon_banner.output.id}"
  action       = "assign"
  method       = "POST"
  api_version  = "beta"
  body = jsonencode({ assignments = [{ target = { "@odata.type" = "#microsoft.graph.groupAssignmentTarget", groupId = var.avd_host_group_id } }] })
}

# ---------------------------------------------------------------------------
# Enable screen capture protection
# ---------------------------------------------------------------------------

resource "msgraph_resource" "settings_catalog_screen_capture" {
  url         = "deviceManagement/configurationPolicies"
  api_version = "beta"

  response_export_values = { id = "id" }

  body = jsonencode({
    name         = "Enable screen capture protection"
    description  = "Prevents users from capturing the screen for sharing"
    platforms    = "windows10"
    technologies = "mdm"
    settings = [{
      id = "0"
      settingInstance = {
        settingInstanceTemplateReference = null
        "@odata.type"       = "#microsoft.graph.deviceManagementConfigurationChoiceSettingInstance"
        settingDefinitionId = "device_vendor_msft_policy_config_terminalserver-avdv1~policy~avd_gp_node_avd_server_screen_capture_protection"
        choiceSettingValue = {
          settingValueTemplateReference = null
          value    = "device_vendor_msft_policy_config_terminalserver-avdv1~policy~avd_gp_node_avd_server_screen_capture_protection_1"
          children = [{
            settingInstanceTemplateReference = null
            "@odata.type"       = "#microsoft.graph.deviceManagementConfigurationChoiceSettingInstance"
            settingDefinitionId = "device_vendor_msft_policy_config_terminalserver-avdv1~policy~avd_gp_node_avd_server_screen_capture_protection_avd_server_screen_capture_protection_level"
            choiceSettingValue  = { settingValueTemplateReference = null, children = [], value = "device_vendor_msft_policy_config_terminalserver-avdv1~policy~avd_gp_node_avd_server_screen_capture_protection_avd_server_screen_capture_protection_level_1" }
          }]
        }
      }
    }]
  })
}

resource "msgraph_resource_action" "screen_capture_assign" {
  resource_url = "deviceManagement/configurationPolicies/${msgraph_resource.settings_catalog_screen_capture.output.id}"
  action       = "assign"
  method       = "POST"
  api_version  = "beta"
  body = jsonencode({ assignments = [{ target = { "@odata.type" = "#microsoft.graph.groupAssignmentTarget", groupId = var.avd_host_group_id } }] })
}

# ---------------------------------------------------------------------------
# Set lock screen inactivity timer
# ---------------------------------------------------------------------------

resource "msgraph_resource" "device_config_lock_screen" {
  url         = "deviceManagement/deviceConfigurations"
  api_version = "beta"

  response_export_values = { id = "id" }

  body = jsonencode({
    "@odata.type"          = "#microsoft.graph.windows10EndpointProtectionConfiguration"
    displayName            = "Set lock screen inactivity timer"
    machineInactivityLimit = 15
  })
}

resource "msgraph_resource_action" "lock_screen_assign" {
  resource_url = "deviceManagement/deviceConfigurations/${msgraph_resource.device_config_lock_screen.output.id}"
  action       = "assign"
  method       = "POST"
  api_version  = "beta"
  body = jsonencode({ assignments = [{ target = { "@odata.type" = "#microsoft.graph.groupAssignmentTarget", groupId = var.all_users_group_id } }] })
}

# ---------------------------------------------------------------------------
# Set password policy
# ---------------------------------------------------------------------------

resource "msgraph_resource" "device_config_password_policy" {
  url         = "deviceManagement/deviceConfigurations"
  api_version = "beta"

  response_export_values = { id = "id" }

  body = jsonencode({
    "@odata.type"                                = "#microsoft.graph.windows10GeneralConfiguration"
    displayName                                  = "Set password policy"
    passwordRequired                             = true
    passwordRequiredType                         = "alphanumeric"
    passwordMinimumLength                        = 10
    passwordMinimumCharacterSetCount             = 4
    passwordExpirationDays                       = 90
    passwordPreviousPasswordBlockCount           = 10
    passwordSignInFailureCountBeforeFactoryReset = 10
    passwordRequireWhenResumeFromIdleState       = true
  })
}

resource "msgraph_resource_action" "password_policy_assign" {
  resource_url = "deviceManagement/deviceConfigurations/${msgraph_resource.device_config_password_policy.output.id}"
  action       = "assign"
  method       = "POST"
  api_version  = "beta"
  body = jsonencode({ assignments = [{ target = { "@odata.type" = "#microsoft.graph.groupAssignmentTarget", groupId = var.all_windows_devices_group_id } }] })
}
