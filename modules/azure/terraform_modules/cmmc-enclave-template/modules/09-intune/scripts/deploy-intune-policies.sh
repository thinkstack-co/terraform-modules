#!/usr/bin/env bash
# deploy-intune-policies.sh
#
# Creates CMMC Intune device configuration and compliance policies in
# Microsoft Intune for Azure Government via the MS Graph API.
#
# Run from Azure Cloud Shell authenticated to the target tenant.
#
# Usage:
#   ./deploy-intune-policies.sh \
#     --group-id <entra-group-object-id> \
#     [--group-id <another-group-id>] \
#     [--encryption-method xtsAes128|xtsAes256] \
#     [--grace-period-hours 0]
#
# Options:
#   --group-id              Entra ID group object ID to assign policies to (repeatable)
#   --encryption-method     BitLocker encryption: xtsAes128 (default) or xtsAes256
#   --grace-period-hours    Hours before non-compliant devices are blocked (default: 0)

set -euo pipefail

GRAPH="https://graph.microsoft.us/beta"
ENCRYPTION_METHOD="xtsAes128"
GRACE_PERIOD_HOURS=0
GROUP_IDS=()

# ---------------------------------------------------------------------------
# Parse arguments
# ---------------------------------------------------------------------------

while [[ $# -gt 0 ]]; do
  case "$1" in
    --group-id)
      GROUP_IDS+=("$2"); shift 2 ;;
    --encryption-method)
      ENCRYPTION_METHOD="$2"; shift 2 ;;
    --grace-period-hours)
      GRACE_PERIOD_HOURS="$2"; shift 2 ;;
    *)
      echo "Unknown argument: $1" >&2; exit 1 ;;
  esac
done

if [[ ${#GROUP_IDS[@]} -eq 0 ]]; then
  echo "Error: at least one --group-id is required." >&2
  echo "Usage: $0 --group-id <object-id> [--group-id <object-id>] [--encryption-method xtsAes128|xtsAes256] [--grace-period-hours 0]" >&2
  exit 1
fi

if [[ "$ENCRYPTION_METHOD" != "xtsAes128" && "$ENCRYPTION_METHOD" != "xtsAes256" ]]; then
  echo "Error: --encryption-method must be 'xtsAes128' or 'xtsAes256'." >&2
  exit 1
fi

# ---------------------------------------------------------------------------
# Verify Azure Government environment
# ---------------------------------------------------------------------------

ENVIRONMENT=$(az account show --query "environmentName" -o tsv 2>/dev/null || true)
if [[ "$ENVIRONMENT" != "AzureUSGovernment" ]]; then
  echo "Error: Azure CLI is not targeting AzureUSGovernment (current: '${ENVIRONMENT}')." >&2
  echo "Run: az cloud set --name AzureUSGovernment && az login" >&2
  exit 1
fi

echo "Environment: $ENVIRONMENT"
echo "Graph endpoint: $GRAPH"
echo "Group IDs: ${GROUP_IDS[*]}"
echo "Encryption method: $ENCRYPTION_METHOD"
echo "Grace period hours: $GRACE_PERIOD_HOURS"
echo ""

# ---------------------------------------------------------------------------
# Helper: build assignment targets JSON array
# ---------------------------------------------------------------------------

build_assignments() {
  local arr="["
  local first=true
  for gid in "${GROUP_IDS[@]}"; do
    if [[ "$first" == "true" ]]; then first=false; else arr+=","; fi
    arr+="{\"target\":{\"@odata.type\":\"#microsoft.graph.groupAssignmentTarget\",\"groupId\":\"${gid}\"}}"
  done
  arr+="]"
  echo "$arr"
}

# ---------------------------------------------------------------------------
# Helper: check if a configurationPolicy with a given name already exists
# Returns the ID if found, empty string if not
# ---------------------------------------------------------------------------

find_config_policy() {
  local name="$1"
  local encoded_name
  encoded_name=$(python3 -c "import urllib.parse; print(urllib.parse.quote(\"$name\"))")
  az rest --method GET \
    --url "${GRAPH}/deviceManagement/configurationPolicies?\$filter=name+eq+'${encoded_name}'" \
    --query "value[0].id" -o tsv 2>/dev/null || echo ""
}

find_compliance_policy() {
  local name="$1"
  local encoded_name
  encoded_name=$(python3 -c "import urllib.parse; print(urllib.parse.quote(\"$name\"))")
  az rest --method GET \
    --url "${GRAPH}/deviceManagement/compliancePolicies?\$filter=name+eq+'${encoded_name}'" \
    --query "value[0].id" -o tsv 2>/dev/null || echo ""
}

# ---------------------------------------------------------------------------
# 1. BitLocker Configuration Policy
# ---------------------------------------------------------------------------

echo "==> BitLocker Configuration Policy"
BITLOCKER_ID=$(find_config_policy "CMMC - BitLocker Encryption")

if [[ -n "$BITLOCKER_ID" ]]; then
  echo "    Already exists (ID: $BITLOCKER_ID) — skipping."
else
  BITLOCKER_BODY=$(cat <<EOF
{
  "name": "CMMC - BitLocker Encryption",
  "description": "Enforces BitLocker ${ENCRYPTION_METHOD} encryption on OS and fixed drives.",
  "platforms": "windows10",
  "technologies": "mdm",
  "settings": [
    {
      "@odata.type": "#microsoft.graph.deviceManagementConfigurationSetting",
      "settingInstance": {
        "@odata.type": "#microsoft.graph.deviceManagementConfigurationChoiceSettingInstance",
        "settingDefinitionId": "device_vendor_msft_bitlocker_requiredeviceencryption",
        "choiceSettingValue": {
          "value": "device_vendor_msft_bitlocker_requiredeviceencryption_1",
          "children": []
        }
      }
    },
    {
      "@odata.type": "#microsoft.graph.deviceManagementConfigurationSetting",
      "settingInstance": {
        "@odata.type": "#microsoft.graph.deviceManagementConfigurationChoiceSettingInstance",
        "settingDefinitionId": "device_vendor_msft_bitlocker_encryptionmethodbydrivetype_systemdrivesencryptiontype",
        "choiceSettingValue": {
          "value": "device_vendor_msft_bitlocker_encryptionmethodbydrivetype_systemdrivesencryptiontype_${ENCRYPTION_METHOD}",
          "children": []
        }
      }
    },
    {
      "@odata.type": "#microsoft.graph.deviceManagementConfigurationSetting",
      "settingInstance": {
        "@odata.type": "#microsoft.graph.deviceManagementConfigurationChoiceSettingInstance",
        "settingDefinitionId": "device_vendor_msft_bitlocker_encryptionmethodbydrivetype_fixeddrivesencryptiontype",
        "choiceSettingValue": {
          "value": "device_vendor_msft_bitlocker_encryptionmethodbydrivetype_fixeddrivesencryptiontype_${ENCRYPTION_METHOD}",
          "children": []
        }
      }
    },
    {
      "@odata.type": "#microsoft.graph.deviceManagementConfigurationSetting",
      "settingInstance": {
        "@odata.type": "#microsoft.graph.deviceManagementConfigurationChoiceSettingInstance",
        "settingDefinitionId": "device_vendor_msft_bitlocker_systemdrivesrecoveryoptions_osrecoverykeyusage",
        "choiceSettingValue": {
          "value": "device_vendor_msft_bitlocker_systemdrivesrecoveryoptions_osrecoverykeyusage_2",
          "children": []
        }
      }
    }
  ]
}
EOF
)
  BITLOCKER_ID=$(az rest --method POST \
    --url "${GRAPH}/deviceManagement/configurationPolicies" \
    --headers "Content-Type=application/json" \
    --body "$BITLOCKER_BODY" \
    --query "id" -o tsv)
  echo "    Created (ID: $BITLOCKER_ID)"

  az rest --method POST \
    --url "${GRAPH}/deviceManagement/configurationPolicies/${BITLOCKER_ID}/assign" \
    --headers "Content-Type=application/json" \
    --body "{\"assignments\": $(build_assignments)}" > /dev/null
  echo "    Assigned to ${#GROUP_IDS[@]} group(s)."
fi

# ---------------------------------------------------------------------------
# 2. Windows Defender Configuration Policy
# ---------------------------------------------------------------------------

echo "==> Windows Defender Configuration Policy"
DEFENDER_ID=$(find_config_policy "CMMC - Windows Defender Antivirus")

if [[ -n "$DEFENDER_ID" ]]; then
  echo "    Already exists (ID: $DEFENDER_ID) — skipping."
else
  DEFENDER_BODY=$(cat <<'EOF'
{
  "name": "CMMC - Windows Defender Antivirus",
  "description": "Configures Windows Defender for CMMC compliance.",
  "platforms": "windows10",
  "technologies": "mdm",
  "settings": [
    {
      "@odata.type": "#microsoft.graph.deviceManagementConfigurationSetting",
      "settingInstance": {
        "@odata.type": "#microsoft.graph.deviceManagementConfigurationChoiceSettingInstance",
        "settingDefinitionId": "device_vendor_msft_defender_allowrealtimemonitoring",
        "choiceSettingValue": {
          "value": "device_vendor_msft_defender_allowrealtimemonitoring_1",
          "children": []
        }
      }
    },
    {
      "@odata.type": "#microsoft.graph.deviceManagementConfigurationSetting",
      "settingInstance": {
        "@odata.type": "#microsoft.graph.deviceManagementConfigurationChoiceSettingInstance",
        "settingDefinitionId": "device_vendor_msft_defender_allowcloudprotection",
        "choiceSettingValue": {
          "value": "device_vendor_msft_defender_allowcloudprotection_1",
          "children": []
        }
      }
    },
    {
      "@odata.type": "#microsoft.graph.deviceManagementConfigurationSetting",
      "settingInstance": {
        "@odata.type": "#microsoft.graph.deviceManagementConfigurationChoiceSettingInstance",
        "settingDefinitionId": "device_vendor_msft_defender_allowbehaviormonitoring",
        "choiceSettingValue": {
          "value": "device_vendor_msft_defender_allowbehaviormonitoring_1",
          "children": []
        }
      }
    }
  ]
}
EOF
)
  DEFENDER_ID=$(az rest --method POST \
    --url "${GRAPH}/deviceManagement/configurationPolicies" \
    --headers "Content-Type=application/json" \
    --body "$DEFENDER_BODY" \
    --query "id" -o tsv)
  echo "    Created (ID: $DEFENDER_ID)"

  az rest --method POST \
    --url "${GRAPH}/deviceManagement/configurationPolicies/${DEFENDER_ID}/assign" \
    --headers "Content-Type=application/json" \
    --body "{\"assignments\": $(build_assignments)}" > /dev/null
  echo "    Assigned to ${#GROUP_IDS[@]} group(s)."
fi

# ---------------------------------------------------------------------------
# 3. Windows Firewall Configuration Policy
# ---------------------------------------------------------------------------

echo "==> Windows Firewall Configuration Policy"
FIREWALL_ID=$(find_config_policy "CMMC - Windows Firewall")

if [[ -n "$FIREWALL_ID" ]]; then
  echo "    Already exists (ID: $FIREWALL_ID) — skipping."
else
  FIREWALL_BODY=$(cat <<'EOF'
{
  "name": "CMMC - Windows Firewall",
  "description": "Enables Windows Firewall on all profiles for CMMC compliance.",
  "platforms": "windows10",
  "technologies": "mdm",
  "settings": [
    {
      "@odata.type": "#microsoft.graph.deviceManagementConfigurationSetting",
      "settingInstance": {
        "@odata.type": "#microsoft.graph.deviceManagementConfigurationChoiceSettingInstance",
        "settingDefinitionId": "vendor_msft_firewall_mdmstore_domainprofile_enablefirewall",
        "choiceSettingValue": {
          "value": "vendor_msft_firewall_mdmstore_domainprofile_enablefirewall_true",
          "children": []
        }
      }
    },
    {
      "@odata.type": "#microsoft.graph.deviceManagementConfigurationSetting",
      "settingInstance": {
        "@odata.type": "#microsoft.graph.deviceManagementConfigurationChoiceSettingInstance",
        "settingDefinitionId": "vendor_msft_firewall_mdmstore_privateprofile_enablefirewall",
        "choiceSettingValue": {
          "value": "vendor_msft_firewall_mdmstore_privateprofile_enablefirewall_true",
          "children": []
        }
      }
    },
    {
      "@odata.type": "#microsoft.graph.deviceManagementConfigurationSetting",
      "settingInstance": {
        "@odata.type": "#microsoft.graph.deviceManagementConfigurationChoiceSettingInstance",
        "settingDefinitionId": "vendor_msft_firewall_mdmstore_publicprofile_enablefirewall",
        "choiceSettingValue": {
          "value": "vendor_msft_firewall_mdmstore_publicprofile_enablefirewall_true",
          "children": []
        }
      }
    }
  ]
}
EOF
)
  FIREWALL_ID=$(az rest --method POST \
    --url "${GRAPH}/deviceManagement/configurationPolicies" \
    --headers "Content-Type=application/json" \
    --body "$FIREWALL_BODY" \
    --query "id" -o tsv)
  echo "    Created (ID: $FIREWALL_ID)"

  az rest --method POST \
    --url "${GRAPH}/deviceManagement/configurationPolicies/${FIREWALL_ID}/assign" \
    --headers "Content-Type=application/json" \
    --body "{\"assignments\": $(build_assignments)}" > /dev/null
  echo "    Assigned to ${#GROUP_IDS[@]} group(s)."
fi

# ---------------------------------------------------------------------------
# 4. Device Compliance Policy
# ---------------------------------------------------------------------------

echo "==> Windows Device Compliance Policy"
COMPLIANCE_ID=$(find_compliance_policy "CMMC - Windows Device Compliance")

if [[ -n "$COMPLIANCE_ID" ]]; then
  echo "    Already exists (ID: $COMPLIANCE_ID) — skipping."
else
  COMPLIANCE_BODY=$(cat <<EOF
{
  "name": "CMMC - Windows Device Compliance",
  "description": "Enforces CMMC compliance requirements on Windows devices.",
  "platforms": "windows10AndLater",
  "settings": [
    {
      "@odata.type": "#microsoft.graph.deviceManagementConfigurationSetting",
      "settingInstance": {
        "@odata.type": "#microsoft.graph.deviceManagementConfigurationChoiceSettingInstance",
        "settingDefinitionId": "deviceconfiguration--windows10compliancepolicy_antivirusenabled",
        "choiceSettingValue": {
          "value": "deviceconfiguration--windows10compliancepolicy_antivirusenabled_true",
          "children": []
        }
      }
    },
    {
      "@odata.type": "#microsoft.graph.deviceManagementConfigurationSetting",
      "settingInstance": {
        "@odata.type": "#microsoft.graph.deviceManagementConfigurationChoiceSettingInstance",
        "settingDefinitionId": "deviceconfiguration--windows10compliancepolicy_defenderenabled",
        "choiceSettingValue": {
          "value": "deviceconfiguration--windows10compliancepolicy_defenderenabled_true",
          "children": []
        }
      }
    },
    {
      "@odata.type": "#microsoft.graph.deviceManagementConfigurationSetting",
      "settingInstance": {
        "@odata.type": "#microsoft.graph.deviceManagementConfigurationChoiceSettingInstance",
        "settingDefinitionId": "deviceconfiguration--windows10compliancepolicy_firewallblocked",
        "choiceSettingValue": {
          "value": "deviceconfiguration--windows10compliancepolicy_firewallblocked_false",
          "children": []
        }
      }
    },
    {
      "@odata.type": "#microsoft.graph.deviceManagementConfigurationSetting",
      "settingInstance": {
        "@odata.type": "#microsoft.graph.deviceManagementConfigurationChoiceSettingInstance",
        "settingDefinitionId": "deviceconfiguration--windows10compliancepolicy_bitlockerenabled",
        "choiceSettingValue": {
          "value": "deviceconfiguration--windows10compliancepolicy_bitlockerenabled_true",
          "children": []
        }
      }
    }
  ],
  "scheduledActionsForRule": [
    {
      "ruleName": "MarkDeviceNonCompliant",
      "scheduledActionConfigurations": [
        {
          "actionType": "block",
          "gracePeriodHours": ${GRACE_PERIOD_HOURS}
        }
      ]
    }
  ]
}
EOF
)
  COMPLIANCE_ID=$(az rest --method POST \
    --url "${GRAPH}/deviceManagement/compliancePolicies" \
    --headers "Content-Type=application/json" \
    --body "$COMPLIANCE_BODY" \
    --query "id" -o tsv)
  echo "    Created (ID: $COMPLIANCE_ID)"

  az rest --method POST \
    --url "${GRAPH}/deviceManagement/compliancePolicies/${COMPLIANCE_ID}/assign" \
    --headers "Content-Type=application/json" \
    --body "{\"assignments\": $(build_assignments)}" > /dev/null
  echo "    Assigned to ${#GROUP_IDS[@]} group(s)."
fi

# ---------------------------------------------------------------------------
# Summary
# ---------------------------------------------------------------------------

echo ""
echo "Done."
echo ""
printf "%-40s %s\n" "Policy" "ID"
printf "%-40s %s\n" "------" "--"
printf "%-40s %s\n" "CMMC - BitLocker Encryption"        "$BITLOCKER_ID"
printf "%-40s %s\n" "CMMC - Windows Defender Antivirus"  "$DEFENDER_ID"
printf "%-40s %s\n" "CMMC - Windows Firewall"            "$FIREWALL_ID"
printf "%-40s %s\n" "CMMC - Windows Device Compliance"   "$COMPLIANCE_ID"
echo ""
echo "Verify at: https://intune.microsoft.us → Devices → Configuration / Compliance policies"
