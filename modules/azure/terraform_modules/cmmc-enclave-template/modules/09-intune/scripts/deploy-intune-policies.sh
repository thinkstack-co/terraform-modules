#!/usr/bin/env bash
# deploy-intune-policies.sh
#
# Creates CMMC + AVD Intune device configuration and compliance policies in
# Microsoft Intune for Azure Government via the MS Graph API.
#
# Run from Azure Cloud Shell authenticated to the target tenant.
#
# Usage:
#   ./deploy-intune-policies.sh \
#     --tenant-id <tenant-id> \
#     --customer-name "Acme Corp" \
#     --avd-host-group-id <object-id> \
#     --all-users-group-id <object-id> \
#     --all-windows-devices-group-id <object-id> \
#     --group-id <object-id> [--group-id <object-id>] \
#     [--gpu-vm-group-id <object-id>] \
#     [--encryption-method xtsAes128|xtsAes256] \
#     [--grace-period-hours 0]
#
# Options:
#   --tenant-id                     Entra tenant ID (required — used for OneDrive KFM settings)
#   --customer-name                 Customer name for logon banner (required)
#   --avd-host-group-id             Group ID for AVD-targeted policies + BitLocker (required)
#   --all-users-group-id            Group ID for user-targeted policies (required)
#   --all-windows-devices-group-id  Group ID for device-targeted policies (required)
#   --group-id                      Group ID for CMMC baseline policies: Defender, Firewall, Compliance (repeatable)
#   --gpu-vm-group-id               Group ID for GPU acceleration policy (optional)
#   --encryption-method             BitLocker encryption: xtsAes128 (default) or xtsAes256
#   --grace-period-hours            Hours before non-compliant devices are blocked (default: 0)

set -uo pipefail
POLICY_ERRORS=()

GRAPH="https://graph.microsoft.us/beta"
ENCRYPTION_METHOD="xtsAes128"
GRACE_PERIOD_HOURS=0
GROUP_IDS=()
TENANT_ID=""
CUSTOMER_NAME=""
AVD_HOST_GROUP_ID=""
ALL_USERS_GROUP_ID=""
ALL_WINDOWS_DEVICES_GROUP_ID=""
GPU_VM_GROUP_ID=""

# ---------------------------------------------------------------------------
# Parse arguments
# ---------------------------------------------------------------------------

while [[ $# -gt 0 ]]; do
	case "$1" in
	--tenant-id)
		TENANT_ID="$2"
		shift 2
		;;
	--customer-name)
		CUSTOMER_NAME="$2"
		shift 2
		;;
	--avd-host-group-id)
		AVD_HOST_GROUP_ID="$2"
		shift 2
		;;
	--all-users-group-id)
		ALL_USERS_GROUP_ID="$2"
		shift 2
		;;
	--all-windows-devices-group-id)
		ALL_WINDOWS_DEVICES_GROUP_ID="$2"
		shift 2
		;;
	--group-id)
		GROUP_IDS+=("$2")
		shift 2
		;;
	--gpu-vm-group-id)
		GPU_VM_GROUP_ID="$2"
		shift 2
		;;
	--encryption-method)
		ENCRYPTION_METHOD="$2"
		shift 2
		;;
	--grace-period-hours)
		GRACE_PERIOD_HOURS="$2"
		shift 2
		;;
	*)
		echo "Unknown argument: $1" >&2
		exit 1
		;;
	esac
done

ERRORS=0
[[ -z "$TENANT_ID" ]] && echo "Error: --tenant-id is required." >&2 && ERRORS=$((ERRORS + 1))
[[ -z "$CUSTOMER_NAME" ]] && echo "Error: --customer-name is required." >&2 && ERRORS=$((ERRORS + 1))
[[ -z "$AVD_HOST_GROUP_ID" ]] && echo "Error: --avd-host-group-id is required." >&2 && ERRORS=$((ERRORS + 1))
[[ -z "$ALL_USERS_GROUP_ID" ]] && echo "Error: --all-users-group-id is required." >&2 && ERRORS=$((ERRORS + 1))
[[ -z "$ALL_WINDOWS_DEVICES_GROUP_ID" ]] && echo "Error: --all-windows-devices-group-id is required." >&2 && ERRORS=$((ERRORS + 1))
[[ ${#GROUP_IDS[@]} -eq 0 ]] && echo "Error: at least one --group-id is required." >&2 && ERRORS=$((ERRORS + 1))
[[ $ERRORS -gt 0 ]] && exit 1

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

echo "Environment:                   $ENVIRONMENT"
echo "Graph endpoint:                $GRAPH"
echo "Tenant ID:                     $TENANT_ID"
echo "Customer name:                 $CUSTOMER_NAME"
echo "AVD host group:                $AVD_HOST_GROUP_ID"
echo "All users group:               $ALL_USERS_GROUP_ID"
echo "All Windows devices group:     $ALL_WINDOWS_DEVICES_GROUP_ID"
echo "CMMC baseline group(s):        ${GROUP_IDS[*]}"
echo "GPU VM group:                  ${GPU_VM_GROUP_ID:-<not set — GPU policy will be skipped>}"
echo "Encryption method:             $ENCRYPTION_METHOD"
echo "Grace period hours:            $GRACE_PERIOD_HOURS"
echo ""

# ---------------------------------------------------------------------------
# Helpers
# ---------------------------------------------------------------------------

build_assignments() {
	# Build assignments JSON array for one or more group IDs
	local arr="["
	local first=true
	for gid in "$@"; do
		if [[ "$first" == "true" ]]; then first=false; else arr+=","; fi
		arr+="{\"target\":{\"@odata.type\":\"#microsoft.graph.groupAssignmentTarget\",\"groupId\":\"${gid}\"}}"
	done
	arr+="]"
	echo "$arr"
}

find_config_policy() {
	local name="$1"
	local encoded_name
	encoded_name=$(python3 -c "import urllib.parse; print(urllib.parse.quote(\"$name\"))")
	az rest --method GET \
		--url "${GRAPH}/deviceManagement/configurationPolicies?\$filter=name+eq+'${encoded_name}'" \
		--query "value[0].id" -o tsv 2>/dev/null || echo ""
}

find_device_compliance_policy() {
	local name="$1"
	local encoded_name
	encoded_name=$(python3 -c "import urllib.parse; print(urllib.parse.quote(\"$name\"))")
	az rest --method GET \
		--url "${GRAPH}/deviceManagement/deviceCompliancePolicies?\$filter=displayName+eq+'${encoded_name}'" \
		--query "value[0].id" -o tsv 2>/dev/null || echo ""
}

find_device_config_policy() {
	local name="$1"
	local encoded_name
	encoded_name=$(python3 -c "import urllib.parse; print(urllib.parse.quote(\"$name\"))")
	az rest --method GET \
		--url "${GRAPH}/deviceManagement/deviceConfigurations?\$filter=displayName+eq+'${encoded_name}'" \
		--query "value[0].id" -o tsv 2>/dev/null || echo ""
}

assign_config_policy() {
	local id="$1"
	shift
	az rest --method POST \
		--url "${GRAPH}/deviceManagement/configurationPolicies/${id}/assign" \
		--headers "Content-Type=application/json" \
		--body "{\"assignments\": $(build_assignments "$@")}" >/dev/null
}

assign_device_config_policy() {
	local id="$1"
	shift
	az rest --method POST \
		--url "${GRAPH}/deviceManagement/deviceConfigurations/${id}/assign" \
		--headers "Content-Type=application/json" \
		--body "{\"assignments\": $(build_assignments "$@")}" >/dev/null
}

assign_device_compliance_policy() {
	local id="$1"
	shift
	az rest --method POST \
		--url "${GRAPH}/deviceManagement/deviceCompliancePolicies/${id}/assign" \
		--headers "Content-Type=application/json" \
		--body "{\"assignments\": $(build_assignments "$@")}" >/dev/null
}

# ---------------------------------------------------------------------------
# 1. BitLocker Configuration Policy  →  AVD hosts
# ---------------------------------------------------------------------------

echo "==> 1. BitLocker Configuration Policy"
BITLOCKER_ID=$(find_device_config_policy "CMMC - BitLocker Encryption")

if [[ -n "$BITLOCKER_ID" ]]; then
	echo "    Already exists (ID: $BITLOCKER_ID) — skipping."
else
	BITLOCKER_BODY=$(
		cat <<EOF
{
  "@odata.type": "#microsoft.graph.windows10EndpointProtectionConfiguration",
  "displayName": "CMMC - BitLocker Encryption",
  "description": "Enforces BitLocker ${ENCRYPTION_METHOD} encryption on OS and fixed drives.",
  "bitLockerEncryptDevice": true,
  "bitLockerAllowStandardUserEncryption": true,
  "bitLockerDisableWarningForOtherDiskEncryption": true,
  "bitLockerSystemDrivePolicy": {
    "encryptionMethod": "${ENCRYPTION_METHOD}",
    "startupAuthenticationRequired": false,
    "startupAuthenticationBlockWithoutTpmChip": false,
    "startupAuthenticationTpmUsage": "blocked",
    "startupAuthenticationTpmPinUsage": "blocked",
    "startupAuthenticationTpmKeyUsage": "blocked",
    "startupAuthenticationTpmPinAndKeyUsage": "blocked",
    "prebootRecoveryEnableMessageAndUrl": false,
    "recoveryOptions": null
  },
  "bitLockerFixedDrivePolicy": {
    "encryptionMethod": "${ENCRYPTION_METHOD}",
    "requireEncryptionForWriteAccess": false,
    "recoveryOptions": {
      "blockDataRecoveryAgent": false,
      "recoveryPasswordUsage": "allowed",
      "recoveryKeyUsage": "allowed",
      "hideRecoveryOptions": true,
      "enableRecoveryInformationSaveToStore": true,
      "recoveryInformationToStore": "passwordAndKey",
      "enableBitLockerAfterRecoveryInformationToStore": true
    }
  },
  "bitLockerRemovableDrivePolicy": {
    "blockCrossOrganizationWriteAccess": false,
    "encryptionMethod": "aesCbc128",
    "requireEncryptionForWriteAccess": false
  }
}
EOF
	)
	if BITLOCKER_ID=$(az rest --method POST \
		--url "${GRAPH}/deviceManagement/deviceConfigurations" \
		--headers "Content-Type=application/json" \
		--body "$BITLOCKER_BODY" \
		--query "id" -o tsv); then
		echo "    Created (ID: $BITLOCKER_ID)"
		assign_device_config_policy "$BITLOCKER_ID" "$AVD_HOST_GROUP_ID" || echo "    WARNING: Assignment failed."
		echo "    Assigned to AVD hosts."
	else
		echo "    ERROR: Creation failed (see above)."
		POLICY_ERRORS+=("CMMC - BitLocker Encryption")
		BITLOCKER_ID="<failed>"
	fi
fi

# ---------------------------------------------------------------------------
# 2. Windows Defender Configuration Policy  →  CMMC baseline groups
# ---------------------------------------------------------------------------

echo "==> 2. Windows Defender Configuration Policy"
DEFENDER_ID=$(find_config_policy "CMMC - Windows Defender Antivirus")

if [[ -n "$DEFENDER_ID" ]]; then
	echo "    Already exists (ID: $DEFENDER_ID) — skipping."
else
	DEFENDER_BODY=$(
		cat <<'EOF'
{
  "name": "CMMC - Windows Defender Antivirus",
  "description": "Configures Windows Defender for CMMC compliance.",
  "platforms": "windows10",
  "technologies": "mdm",
  "settings": [
    {"settingInstance":{"@odata.type":"#microsoft.graph.deviceManagementConfigurationChoiceSettingInstance","settingDefinitionId":"device_vendor_msft_policy_config_defender_allowrealtimemonitoring","choiceSettingValue":{"value":"device_vendor_msft_policy_config_defender_allowrealtimemonitoring_1","children":[]}}},
    {"settingInstance":{"@odata.type":"#microsoft.graph.deviceManagementConfigurationChoiceSettingInstance","settingDefinitionId":"device_vendor_msft_policy_config_defender_allowcloudprotection","choiceSettingValue":{"value":"device_vendor_msft_policy_config_defender_allowcloudprotection_1","children":[]}}},
    {"settingInstance":{"@odata.type":"#microsoft.graph.deviceManagementConfigurationChoiceSettingInstance","settingDefinitionId":"device_vendor_msft_policy_config_defender_allowbehaviormonitoring","choiceSettingValue":{"value":"device_vendor_msft_policy_config_defender_allowbehaviormonitoring_1","children":[]}}}
  ]
}
EOF
	)
	if DEFENDER_ID=$(az rest --method POST \
		--url "${GRAPH}/deviceManagement/configurationPolicies" \
		--headers "Content-Type=application/json" \
		--body "$DEFENDER_BODY" \
		--query "id" -o tsv); then
		echo "    Created (ID: $DEFENDER_ID)"
		assign_config_policy "$DEFENDER_ID" "${GROUP_IDS[@]}" || echo "    WARNING: Assignment failed."
		echo "    Assigned to ${#GROUP_IDS[@]} group(s)."
	else
		echo "    ERROR: Creation failed (see above)."
		POLICY_ERRORS+=("CMMC - Windows Defender Antivirus")
		DEFENDER_ID="<failed>"
	fi
fi

# ---------------------------------------------------------------------------
# 3. Windows Firewall Configuration Policy  →  CMMC baseline groups
# ---------------------------------------------------------------------------

echo "==> 3. Windows Firewall Configuration Policy"
FIREWALL_ID=$(find_config_policy "CMMC - Windows Firewall")

if [[ -n "$FIREWALL_ID" ]]; then
	echo "    Already exists (ID: $FIREWALL_ID) — skipping."
else
	FIREWALL_BODY=$(
		cat <<'EOF'
{
  "name": "CMMC - Windows Firewall",
  "description": "Enables Windows Firewall on all profiles for CMMC compliance.",
  "platforms": "windows10",
  "technologies": "mdm",
  "settings": [
    {"settingInstance":{"@odata.type":"#microsoft.graph.deviceManagementConfigurationChoiceSettingInstance","settingDefinitionId":"vendor_msft_firewall_mdmstore_domainprofile_enablefirewall","choiceSettingValue":{"value":"vendor_msft_firewall_mdmstore_domainprofile_enablefirewall_true","children":[]}}},
    {"settingInstance":{"@odata.type":"#microsoft.graph.deviceManagementConfigurationChoiceSettingInstance","settingDefinitionId":"vendor_msft_firewall_mdmstore_privateprofile_enablefirewall","choiceSettingValue":{"value":"vendor_msft_firewall_mdmstore_privateprofile_enablefirewall_true","children":[]}}},
    {"settingInstance":{"@odata.type":"#microsoft.graph.deviceManagementConfigurationChoiceSettingInstance","settingDefinitionId":"vendor_msft_firewall_mdmstore_publicprofile_enablefirewall","choiceSettingValue":{"value":"vendor_msft_firewall_mdmstore_publicprofile_enablefirewall_true","children":[]}}}
  ]
}
EOF
	)
	if FIREWALL_ID=$(az rest --method POST \
		--url "${GRAPH}/deviceManagement/configurationPolicies" \
		--headers "Content-Type=application/json" \
		--body "$FIREWALL_BODY" \
		--query "id" -o tsv); then
		echo "    Created (ID: $FIREWALL_ID)"
		assign_config_policy "$FIREWALL_ID" "${GROUP_IDS[@]}" || echo "    WARNING: Assignment failed."
		echo "    Assigned to ${#GROUP_IDS[@]} group(s)."
	else
		echo "    ERROR: Creation failed (see above)."
		POLICY_ERRORS+=("CMMC - Windows Firewall")
		FIREWALL_ID="<failed>"
	fi
fi

# ---------------------------------------------------------------------------
# 4. Device Compliance Policy  →  CMMC baseline groups
# ---------------------------------------------------------------------------

echo "==> 4. Windows Device Compliance Policy"
COMPLIANCE_ID=$(find_device_compliance_policy "CMMC - Windows Device Compliance")

if [[ -n "$COMPLIANCE_ID" ]]; then
	echo "    Already exists (ID: $COMPLIANCE_ID) — skipping."
else
	COMPLIANCE_BODY=$(
		cat <<EOF
{
  "@odata.type": "#microsoft.graph.windows10CompliancePolicy",
  "displayName": "CMMC - Windows Device Compliance",
  "description": "Enforces CMMC compliance requirements on Windows devices.",
  "antivirusRequired": true,
  "defenderEnabled": true,
  "firewallEnabled": true,
  "bitLockerEnabled": true,
  "scheduledActionsForRule": [{"ruleName":"MarkDeviceNonCompliant","scheduledActionConfigurations":[{"actionType":"block","gracePeriodHours":${GRACE_PERIOD_HOURS}}]}]
}
EOF
	)
	if COMPLIANCE_ID=$(az rest --method POST \
		--url "${GRAPH}/deviceManagement/deviceCompliancePolicies" \
		--headers "Content-Type=application/json" \
		--body "$COMPLIANCE_BODY" \
		--query "id" -o tsv); then
		echo "    Created (ID: $COMPLIANCE_ID)"
		assign_device_compliance_policy "$COMPLIANCE_ID" "${GROUP_IDS[@]}" || echo "    WARNING: Assignment failed."
		echo "    Assigned to ${#GROUP_IDS[@]} group(s)."
	else
		echo "    ERROR: Creation failed (see above)."
		POLICY_ERRORS+=("CMMC - Windows Device Compliance")
		COMPLIANCE_ID="<failed>"
	fi
fi

# ---------------------------------------------------------------------------
# 5. Configure device and resource redirection  →  AVD hosts
# ---------------------------------------------------------------------------

echo "==> 5. Configure device and resource redirection"
RDP_REDIR_ID=$(find_config_policy "Configure device and resource redirection")

if [[ -n "$RDP_REDIR_ID" ]]; then
	echo "    Already exists (ID: $RDP_REDIR_ID) — skipping."
else
	RDP_REDIR_BODY=$(
		cat <<'EOF'
{
  "name": "Configure device and resource redirection",
  "description": "",
  "platforms": "windows10",
  "technologies": "mdm",
  "settings": [
    {"id":"0","settingInstance":{"@odata.type":"#microsoft.graph.deviceManagementConfigurationChoiceSettingInstance","settingDefinitionId":"device_vendor_msft_policy_config_admx_terminalserver_ts_time_zone","choiceSettingValue":{"value":"device_vendor_msft_policy_config_admx_terminalserver_ts_time_zone_1","children":[]}}},
    {"id":"1","settingInstance":{"@odata.type":"#microsoft.graph.deviceManagementConfigurationChoiceSettingInstance","settingDefinitionId":"device_vendor_msft_policy_config_admx_terminalserver_ts_client_clipboard","choiceSettingValue":{"value":"device_vendor_msft_policy_config_admx_terminalserver_ts_client_clipboard_1","children":[]}}},
    {"id":"2","settingInstance":{"@odata.type":"#microsoft.graph.deviceManagementConfigurationChoiceSettingInstance","settingDefinitionId":"device_vendor_msft_policy_config_admx_terminalserver_ts_client_com","choiceSettingValue":{"value":"device_vendor_msft_policy_config_admx_terminalserver_ts_client_com_1","children":[]}}},
    {"id":"3","settingInstance":{"@odata.type":"#microsoft.graph.deviceManagementConfigurationChoiceSettingInstance","settingDefinitionId":"device_vendor_msft_policy_config_remotedesktopservices_donotallowdriveredirection","choiceSettingValue":{"value":"device_vendor_msft_policy_config_remotedesktopservices_donotallowdriveredirection_1","children":[]}}},
    {"id":"4","settingInstance":{"@odata.type":"#microsoft.graph.deviceManagementConfigurationChoiceSettingInstance","settingDefinitionId":"device_vendor_msft_policy_config_admx_terminalserver_ts_client_lpt","choiceSettingValue":{"value":"device_vendor_msft_policy_config_admx_terminalserver_ts_client_lpt_1","children":[]}}},
    {"id":"5","settingInstance":{"@odata.type":"#microsoft.graph.deviceManagementConfigurationChoiceSettingInstance","settingDefinitionId":"device_vendor_msft_policy_config_admx_terminalserver_ts_smart_card","choiceSettingValue":{"value":"device_vendor_msft_policy_config_admx_terminalserver_ts_smart_card_1","children":[]}}},
    {"id":"6","settingInstance":{"@odata.type":"#microsoft.graph.deviceManagementConfigurationChoiceSettingInstance","settingDefinitionId":"device_vendor_msft_policy_config_admx_terminalserver_ts_client_pnp","choiceSettingValue":{"value":"device_vendor_msft_policy_config_admx_terminalserver_ts_client_pnp_1","children":[]}}}
  ]
}
EOF
	)
	if RDP_REDIR_ID=$(az rest --method POST \
		--url "${GRAPH}/deviceManagement/configurationPolicies" \
		--headers "Content-Type=application/json" \
		--body "$RDP_REDIR_BODY" \
		--query "id" -o tsv); then
		echo "    Created (ID: $RDP_REDIR_ID)"
		assign_config_policy "$RDP_REDIR_ID" "$AVD_HOST_GROUP_ID" || echo "    WARNING: Assignment failed."
		echo "    Assigned to AVD hosts."
	else
		echo "    ERROR: Creation failed (see above)."
		POLICY_ERRORS+=("Configure device and resource redirection")
		RDP_REDIR_ID="<failed>"
	fi
fi

# ---------------------------------------------------------------------------
# 6. Configure GPU acceleration for Azure Virtual Desktop  →  GPU VMs (optional)
# ---------------------------------------------------------------------------

echo "==> 6. Configure GPU acceleration for Azure Virtual Desktop"
GPU_ACCEL_ID=""
if [[ -z "$GPU_VM_GROUP_ID" ]]; then
	echo "    Skipped (--gpu-vm-group-id not set)."
else
	GPU_ACCEL_ID=$(find_config_policy "Configure GPU acceleration for Azure Virtual Desktop")
	if [[ -n "$GPU_ACCEL_ID" ]]; then
		echo "    Already exists (ID: $GPU_ACCEL_ID) — skipping."
	else
		GPU_ACCEL_BODY=$(
			cat <<'EOF'
{
  "name": "Configure GPU acceleration for Azure Virtual Desktop",
  "description": "Azure Virtual Desktop supports GPU acceleration in rendering and encoding for improved app performance and scalability.",
  "platforms": "windows10",
  "technologies": "mdm",
  "settings": [
    {"id":"0","settingInstance":{"@odata.type":"#microsoft.graph.deviceManagementConfigurationChoiceSettingInstance","settingDefinitionId":"device_vendor_msft_policy_config_admx_terminalserver_ts_server_avc_hw_encode_preferred","choiceSettingValue":{"value":"device_vendor_msft_policy_config_admx_terminalserver_ts_server_avc_hw_encode_preferred_1","children":[]}}},
    {"id":"1","settingInstance":{"@odata.type":"#microsoft.graph.deviceManagementConfigurationChoiceSettingInstance","settingDefinitionId":"device_vendor_msft_policy_config_admx_terminalserver_ts_server_avc444_mode_preferred","choiceSettingValue":{"value":"device_vendor_msft_policy_config_admx_terminalserver_ts_server_avc444_mode_preferred_1","children":[]}}},
    {"id":"2","settingInstance":{"@odata.type":"#microsoft.graph.deviceManagementConfigurationChoiceSettingInstance","settingDefinitionId":"device_vendor_msft_policy_config_admx_terminalserver_ts_dx_use_full_hwgpu","choiceSettingValue":{"value":"device_vendor_msft_policy_config_admx_terminalserver_ts_dx_use_full_hwgpu_1","children":[]}}}
  ]
}
EOF
		)
		if GPU_ACCEL_ID=$(az rest --method POST \
			--url "${GRAPH}/deviceManagement/configurationPolicies" \
			--headers "Content-Type=application/json" \
			--body "$GPU_ACCEL_BODY" \
			--query "id" -o tsv); then
			echo "    Created (ID: $GPU_ACCEL_ID)"
			assign_config_policy "$GPU_ACCEL_ID" "$GPU_VM_GROUP_ID" || echo "    WARNING: Assignment failed."
			echo "    Assigned to GPU VMs."
		else
			echo "    ERROR: Creation failed (see above)."
			POLICY_ERRORS+=("Configure GPU acceleration for Azure Virtual Desktop")
			GPU_ACCEL_ID="<failed>"
		fi
	fi
fi

# ---------------------------------------------------------------------------
# 7. Configure OneDrive settings  →  AVD hosts
# ---------------------------------------------------------------------------

echo "==> 7. Configure OneDrive settings"
ONEDRIVE_ID=$(find_config_policy "Configure OneDrive settings")

if [[ -n "$ONEDRIVE_ID" ]]; then
	echo "    Already exists (ID: $ONEDRIVE_ID) — skipping."
else
	ONEDRIVE_BODY=$(
		cat <<EOF
{
  "name": "Configure OneDrive settings",
  "description": "",
  "platforms": "windows10",
  "technologies": "mdm",
  "settings": [
    {"id":"0","settingInstance":{"@odata.type":"#microsoft.graph.deviceManagementConfigurationChoiceSettingInstance","settingDefinitionId":"device_vendor_msft_policy_config_onedrivengscv2~policy~onedrivengsc_allowtenantlist","choiceSettingValue":{"value":"device_vendor_msft_policy_config_onedrivengscv2~policy~onedrivengsc_allowtenantlist_1","children":[{"@odata.type":"#microsoft.graph.deviceManagementConfigurationSimpleSettingCollectionInstance","settingDefinitionId":"device_vendor_msft_policy_config_onedrivengscv2~policy~onedrivengsc_allowtenantlist_allowtenantlistbox","simpleSettingCollectionValue":[{"@odata.type":"#microsoft.graph.deviceManagementConfigurationStringSettingValue","value":"${TENANT_ID}"}]}]}}},
    {"id":"1","settingInstance":{"@odata.type":"#microsoft.graph.deviceManagementConfigurationChoiceSettingInstance","settingDefinitionId":"device_vendor_msft_policy_config_onedrivengscv4~policy~onedrivengsc_enableodignorelistfromgpo","choiceSettingValue":{"value":"device_vendor_msft_policy_config_onedrivengscv4~policy~onedrivengsc_enableodignorelistfromgpo_1","children":[{"@odata.type":"#microsoft.graph.deviceManagementConfigurationSimpleSettingCollectionInstance","settingDefinitionId":"device_vendor_msft_policy_config_onedrivengscv4~policy~onedrivengsc_enableodignorelistfromgpo_enableodignorelistfromgpolistbox","simpleSettingCollectionValue":[{"@odata.type":"#microsoft.graph.deviceManagementConfigurationStringSettingValue","value":"*.mp3"},{"@odata.type":"#microsoft.graph.deviceManagementConfigurationStringSettingValue","value":"*.pst"}]}]}}},
    {"id":"2","settingInstance":{"@odata.type":"#microsoft.graph.deviceManagementConfigurationChoiceSettingInstance","settingDefinitionId":"device_vendor_msft_policy_config_onedrivengscv2~policy~onedrivengsc_blockexternalsync","choiceSettingValue":{"value":"device_vendor_msft_policy_config_onedrivengscv2~policy~onedrivengsc_blockexternalsync_1","children":[]}}},
    {"id":"3","settingInstance":{"@odata.type":"#microsoft.graph.deviceManagementConfigurationChoiceSettingInstance","settingDefinitionId":"device_vendor_msft_policy_config_onedrivengscv2~policy~onedrivengsc_kfmoptinwithwizard","choiceSettingValue":{"value":"device_vendor_msft_policy_config_onedrivengscv2~policy~onedrivengsc_kfmoptinwithwizard_1","children":[{"@odata.type":"#microsoft.graph.deviceManagementConfigurationSimpleSettingInstance","settingDefinitionId":"device_vendor_msft_policy_config_onedrivengscv2~policy~onedrivengsc_kfmoptinwithwizard_kfmoptinwithwizard_textbox","simpleSettingValue":{"@odata.type":"#microsoft.graph.deviceManagementConfigurationStringSettingValue","value":"${TENANT_ID}"}}]}}},
    {"id":"4","settingInstance":{"@odata.type":"#microsoft.graph.deviceManagementConfigurationChoiceSettingInstance","settingDefinitionId":"device_vendor_msft_policy_config_onedrivengscv3~policy~onedrivengsc_localmassdeletefiledeletethreshold","choiceSettingValue":{"value":"device_vendor_msft_policy_config_onedrivengscv3~policy~onedrivengsc_localmassdeletefiledeletethreshold_1","children":[{"@odata.type":"#microsoft.graph.deviceManagementConfigurationSimpleSettingInstance","settingDefinitionId":"device_vendor_msft_policy_config_onedrivengscv3~policy~onedrivengsc_localmassdeletefiledeletethreshold_lmdfiledeletethresholdbox","simpleSettingValue":{"@odata.type":"#microsoft.graph.deviceManagementConfigurationIntegerSettingValue","value":25}}]}}},
    {"id":"5","settingInstance":{"@odata.type":"#microsoft.graph.deviceManagementConfigurationChoiceSettingInstance","settingDefinitionId":"device_vendor_msft_policy_config_onedrivengscv2~policy~onedrivengsc_forcedlocalmassdeletedetection","choiceSettingValue":{"value":"device_vendor_msft_policy_config_onedrivengscv2~policy~onedrivengsc_forcedlocalmassdeletedetection_1","children":[]}}},
    {"id":"6","settingInstance":{"@odata.type":"#microsoft.graph.deviceManagementConfigurationChoiceSettingInstance","settingDefinitionId":"device_vendor_msft_policy_config_onedrivengscv2~policy~onedrivengsc_kfmoptinnowizard","choiceSettingValue":{"value":"device_vendor_msft_policy_config_onedrivengscv2~policy~onedrivengsc_kfmoptinnowizard_1","children":[{"@odata.type":"#microsoft.graph.deviceManagementConfigurationChoiceSettingInstance","settingDefinitionId":"device_vendor_msft_policy_config_onedrivengscv2~policy~onedrivengsc_kfmoptinnowizard_kfmoptinnowizard_dropdown","choiceSettingValue":{"value":"device_vendor_msft_policy_config_onedrivengscv2~policy~onedrivengsc_kfmoptinnowizard_kfmoptinnowizard_dropdown_0","children":[]}},{"@odata.type":"#microsoft.graph.deviceManagementConfigurationSimpleSettingInstance","settingDefinitionId":"device_vendor_msft_policy_config_onedrivengscv2~policy~onedrivengsc_kfmoptinnowizard_kfmoptinnowizard_textbox","simpleSettingValue":{"@odata.type":"#microsoft.graph.deviceManagementConfigurationStringSettingValue","value":"${TENANT_ID}"}}]}}},
    {"id":"7","settingInstance":{"@odata.type":"#microsoft.graph.deviceManagementConfigurationChoiceSettingInstance","settingDefinitionId":"device_vendor_msft_policy_config_onedrivengscv2~policy~onedrivengsc_silentaccountconfig","choiceSettingValue":{"value":"device_vendor_msft_policy_config_onedrivengscv2~policy~onedrivengsc_silentaccountconfig_1","children":[]}}}
  ]
}
EOF
	)
	if ONEDRIVE_ID=$(az rest --method POST \
		--url "${GRAPH}/deviceManagement/configurationPolicies" \
		--headers "Content-Type=application/json" \
		--body "$ONEDRIVE_BODY" \
		--query "id" -o tsv); then
		echo "    Created (ID: $ONEDRIVE_ID)"
		assign_config_policy "$ONEDRIVE_ID" "$AVD_HOST_GROUP_ID" || echo "    WARNING: Assignment failed."
		echo "    Assigned to AVD hosts."
	else
		echo "    ERROR: Creation failed (see above)."
		POLICY_ERRORS+=("Configure OneDrive settings")
		ONEDRIVE_ID="<failed>"
	fi
fi

# ---------------------------------------------------------------------------
# 8. Configure Windows NTP client  →  AVD hosts
# ---------------------------------------------------------------------------

echo "==> 8. Configure Windows NTP client"
NTP_ID=$(find_config_policy "Configure Windows NTP client")

if [[ -n "$NTP_ID" ]]; then
	echo "    Already exists (ID: $NTP_ID) — skipping."
else
	NTP_BODY=$(
		cat <<'EOF'
{
  "name": "Configure Windows NTP client",
  "description": "",
  "platforms": "windows10",
  "technologies": "mdm",
  "settings": [{"id":"0","settingInstance":{"@odata.type":"#microsoft.graph.deviceManagementConfigurationChoiceSettingInstance","settingDefinitionId":"device_vendor_msft_policy_config_admx_w32time_w32time_policy_configure_ntpclient","choiceSettingValue":{"value":"device_vendor_msft_policy_config_admx_w32time_w32time_policy_configure_ntpclient_1","children":[{"@odata.type":"#microsoft.graph.deviceManagementConfigurationSimpleSettingInstance","settingDefinitionId":"device_vendor_msft_policy_config_admx_w32time_w32time_policy_configure_ntpclient_w32time_crosssitesyncflags","simpleSettingValue":{"@odata.type":"#microsoft.graph.deviceManagementConfigurationIntegerSettingValue","value":2}},{"@odata.type":"#microsoft.graph.deviceManagementConfigurationSimpleSettingInstance","settingDefinitionId":"device_vendor_msft_policy_config_admx_w32time_w32time_policy_configure_ntpclient_w32time_ntpclienteventlogflags","simpleSettingValue":{"@odata.type":"#microsoft.graph.deviceManagementConfigurationIntegerSettingValue","value":0}},{"@odata.type":"#microsoft.graph.deviceManagementConfigurationSimpleSettingInstance","settingDefinitionId":"device_vendor_msft_policy_config_admx_w32time_w32time_policy_configure_ntpclient_w32time_ntpserver","simpleSettingValue":{"@odata.type":"#microsoft.graph.deviceManagementConfigurationStringSettingValue","value":"time.nist.gov0x01"}},{"@odata.type":"#microsoft.graph.deviceManagementConfigurationSimpleSettingInstance","settingDefinitionId":"device_vendor_msft_policy_config_admx_w32time_w32time_policy_configure_ntpclient_w32time_resolvepeerbackoffmaxtimes","simpleSettingValue":{"@odata.type":"#microsoft.graph.deviceManagementConfigurationIntegerSettingValue","value":7}},{"@odata.type":"#microsoft.graph.deviceManagementConfigurationSimpleSettingInstance","settingDefinitionId":"device_vendor_msft_policy_config_admx_w32time_w32time_policy_configure_ntpclient_w32time_resolvepeerbackoffminutes","simpleSettingValue":{"@odata.type":"#microsoft.graph.deviceManagementConfigurationIntegerSettingValue","value":15}},{"@odata.type":"#microsoft.graph.deviceManagementConfigurationSimpleSettingInstance","settingDefinitionId":"device_vendor_msft_policy_config_admx_w32time_w32time_policy_configure_ntpclient_w32time_specialpollinterval","simpleSettingValue":{"@odata.type":"#microsoft.graph.deviceManagementConfigurationIntegerSettingValue","value":3600}},{"@odata.type":"#microsoft.graph.deviceManagementConfigurationChoiceSettingInstance","settingDefinitionId":"device_vendor_msft_policy_config_admx_w32time_w32time_policy_configure_ntpclient_w32time_type","choiceSettingValue":{"value":"device_vendor_msft_policy_config_admx_w32time_w32time_policy_configure_ntpclient_w32time_type_ntp","children":[]}}]}}}]
}
EOF
	)
	if NTP_ID=$(az rest --method POST \
		--url "${GRAPH}/deviceManagement/configurationPolicies" \
		--headers "Content-Type=application/json" \
		--body "$NTP_BODY" \
		--query "id" -o tsv); then
		echo "    Created (ID: $NTP_ID)"
		assign_config_policy "$NTP_ID" "$AVD_HOST_GROUP_ID" || echo "    WARNING: Assignment failed."
		echo "    Assigned to AVD hosts."
	else
		echo "    ERROR: Creation failed (see above)."
		POLICY_ERRORS+=("Configure Windows NTP client")
		NTP_ID="<failed>"
	fi
fi

# ---------------------------------------------------------------------------
# 9. Disable password reveal  →  All Users
# ---------------------------------------------------------------------------

echo "==> 9. Disable password reveal"
PWD_REVEAL_ID=$(find_config_policy "Disable password reveal")

if [[ -n "$PWD_REVEAL_ID" ]]; then
	echo "    Already exists (ID: $PWD_REVEAL_ID) — skipping."
else
	PWD_REVEAL_BODY=$(
		cat <<'EOF'
{"name":"Disable password reveal","description":"Disables the password reveal button","platforms":"windows10","technologies":"mdm","settings":[{"id":"0","settingInstance":{"@odata.type":"#microsoft.graph.deviceManagementConfigurationChoiceSettingInstance","settingDefinitionId":"user_vendor_msft_policy_config_credentialsui_disablepasswordreveal","choiceSettingValue":{"value":"user_vendor_msft_policy_config_credentialsui_disablepasswordreveal_1","children":[]}}}]}
EOF
	)
	if PWD_REVEAL_ID=$(az rest --method POST \
		--url "${GRAPH}/deviceManagement/configurationPolicies" \
		--headers "Content-Type=application/json" \
		--body "$PWD_REVEAL_BODY" \
		--query "id" -o tsv); then
		echo "    Created (ID: $PWD_REVEAL_ID)"
		assign_config_policy "$PWD_REVEAL_ID" "$ALL_USERS_GROUP_ID" || echo "    WARNING: Assignment failed."
		echo "    Assigned to All Users."
	else
		echo "    ERROR: Creation failed (see above)."
		POLICY_ERRORS+=("Disable password reveal")
		PWD_REVEAL_ID="<failed>"
	fi
fi

# ---------------------------------------------------------------------------
# 10. Enable Azure Information Protection add-in  →  All Users
# ---------------------------------------------------------------------------

echo "==> 10. Enable Azure Information Protection add-in for sensitivity labeling"
AIP_ID=$(find_config_policy "Enable Azure Information Protection add-in for sensitivity labeling")

if [[ -n "$AIP_ID" ]]; then
	echo "    Already exists (ID: $AIP_ID) — skipping."
else
	AIP_BODY=$(
		cat <<'EOF'
{"name":"Enable Azure Information Protection add-in for sensitivity labeling","description":"Enables the policy that ensures Azure Information Protection add-in for sensitivity labeling is present","platforms":"windows10","technologies":"mdm","settings":[{"id":"0","settingInstance":{"@odata.type":"#microsoft.graph.deviceManagementConfigurationChoiceSettingInstance","settingDefinitionId":"user_vendor_msft_policy_config_office16v13~policy~l_microsoftofficesystem~l_securitysettings_l_aipexception","choiceSettingValue":{"value":"user_vendor_msft_policy_config_office16v13~policy~l_microsoftofficesystem~l_securitysettings_l_aipexception_1","children":[]}}},{"id":"1","settingInstance":{"@odata.type":"#microsoft.graph.deviceManagementConfigurationChoiceSettingInstance","settingDefinitionId":"user_vendor_msft_policy_config_office16v3~policy~l_microsoftofficesystem~l_securitysettings_l_useofficeforlabelling","choiceSettingValue":{"value":"user_vendor_msft_policy_config_office16v3~policy~l_microsoftofficesystem~l_securitysettings_l_useofficeforlabelling_0","children":[]}}}]}
EOF
	)
	if AIP_ID=$(az rest --method POST \
		--url "${GRAPH}/deviceManagement/configurationPolicies" \
		--headers "Content-Type=application/json" \
		--body "$AIP_BODY" \
		--query "id" -o tsv); then
		echo "    Created (ID: $AIP_ID)"
		assign_config_policy "$AIP_ID" "$ALL_USERS_GROUP_ID" || echo "    WARNING: Assignment failed."
		echo "    Assigned to All Users."
	else
		echo "    ERROR: Creation failed (see above)."
		POLICY_ERRORS+=("Enable Azure Information Protection add-in for sensitivity labeling")
		AIP_ID="<failed>"
	fi
fi

# ---------------------------------------------------------------------------
# 11. Enable interactive logon banner  →  AVD hosts
# ---------------------------------------------------------------------------

echo "==> 11. Enable interactive logon banner"
LOGON_BANNER_ID=$(find_config_policy "Enable interactive logon banner")

if [[ -n "$LOGON_BANNER_ID" ]]; then
	echo "    Already exists (ID: $LOGON_BANNER_ID) — skipping."
else
	LOGON_BANNER_TEXT="This system is the property of ${CUSTOMER_NAME} and is intended for authorized users only. Employees and users of ${CUSTOMER_NAME}'s Electronic Systems (including desktop computers laptop computers servers mobile devices email Internet access and business applications) should have no expectation of privacy with regard to use of these resources. All individuals' activities while using ${CUSTOMER_NAME}'s Electronic Systems may be monitored and audited. By signing on and using any of these Electronic Systems users acknowledge that all data messages documents etc. sent received or reviewed while using these Electronic Systems are property of ${CUSTOMER_NAME}. Additionally this system contains federal contract information and/or Controlled Unclassified Information (CUI). By using this system (which includes any device attached to this system) you consent to abide by ${CUSTOMER_NAME}'s policies regarding CUI. You further acknowledge that failure to abide by these terms and usage requirements may result in revoked or suspended access privileges."

	LOGON_BANNER_BODY=$(python3 -c "
import json, sys
name = 'Enable interactive logon banner'
text = sys.argv[1]
title = sys.argv[2]
body = {
  'name': name,
  'description': 'Displays interactive logon',
  'platforms': 'windows10',
  'technologies': 'mdm',
  'settings': [
    {'id':'0','settingInstance':{'@odata.type':'#microsoft.graph.deviceManagementConfigurationSimpleSettingCollectionInstance','settingDefinitionId':'device_vendor_msft_policy_config_localpoliciessecurityoptions_interactivelogon_messagetextforusersattemptingtologon','simpleSettingCollectionValue':[{'@odata.type':'#microsoft.graph.deviceManagementConfigurationStringSettingValue','value':text}]}},
    {'id':'1','settingInstance':{'@odata.type':'#microsoft.graph.deviceManagementConfigurationSimpleSettingInstance','settingDefinitionId':'device_vendor_msft_policy_config_localpoliciessecurityoptions_interactivelogon_messagetitleforusersattemptingtologon','simpleSettingValue':{'@odata.type':'#microsoft.graph.deviceManagementConfigurationStringSettingValue','value':title}}}
  ]
}
print(json.dumps(body))
" "$LOGON_BANNER_TEXT" "${CUSTOMER_NAME} Terms of Use")

	if LOGON_BANNER_ID=$(az rest --method POST \
		--url "${GRAPH}/deviceManagement/configurationPolicies" \
		--headers "Content-Type=application/json" \
		--body "$LOGON_BANNER_BODY" \
		--query "id" -o tsv); then
		echo "    Created (ID: $LOGON_BANNER_ID)"
		assign_config_policy "$LOGON_BANNER_ID" "$AVD_HOST_GROUP_ID" || echo "    WARNING: Assignment failed."
		echo "    Assigned to AVD hosts."
	else
		echo "    ERROR: Creation failed (see above)."
		POLICY_ERRORS+=("Enable interactive logon banner")
		LOGON_BANNER_ID="<failed>"
	fi
fi

# ---------------------------------------------------------------------------
# 12. Enable screen capture protection  →  AVD hosts
# ---------------------------------------------------------------------------

echo "==> 12. Enable screen capture protection"
SCREEN_CAPTURE_ID=$(find_config_policy "Enable screen capture protection")

if [[ -n "$SCREEN_CAPTURE_ID" ]]; then
	echo "    Already exists (ID: $SCREEN_CAPTURE_ID) — skipping."
else
	SCREEN_CAPTURE_BODY=$(
		cat <<'EOF'
{"name":"Enable screen capture protection","description":"Prevents users from capturing the screen for sharing","platforms":"windows10","technologies":"mdm","settings":[{"id":"0","settingInstance":{"@odata.type":"#microsoft.graph.deviceManagementConfigurationChoiceSettingInstance","settingDefinitionId":"device_vendor_msft_policy_config_terminalserver-avdv1~policy~avd_gp_node_avd_server_screen_capture_protection","choiceSettingValue":{"value":"device_vendor_msft_policy_config_terminalserver-avdv1~policy~avd_gp_node_avd_server_screen_capture_protection_1","children":[{"@odata.type":"#microsoft.graph.deviceManagementConfigurationChoiceSettingInstance","settingDefinitionId":"device_vendor_msft_policy_config_terminalserver-avdv1~policy~avd_gp_node_avd_server_screen_capture_protection_avd_server_screen_capture_protection_level","choiceSettingValue":{"value":"device_vendor_msft_policy_config_terminalserver-avdv1~policy~avd_gp_node_avd_server_screen_capture_protection_avd_server_screen_capture_protection_level_1","children":[]}}]}}}]}
EOF
	)
	if SCREEN_CAPTURE_ID=$(az rest --method POST \
		--url "${GRAPH}/deviceManagement/configurationPolicies" \
		--headers "Content-Type=application/json" \
		--body "$SCREEN_CAPTURE_BODY" \
		--query "id" -o tsv); then
		echo "    Created (ID: $SCREEN_CAPTURE_ID)"
		assign_config_policy "$SCREEN_CAPTURE_ID" "$AVD_HOST_GROUP_ID" || echo "    WARNING: Assignment failed."
		echo "    Assigned to AVD hosts."
	else
		echo "    ERROR: Creation failed (see above)."
		POLICY_ERRORS+=("Enable screen capture protection")
		SCREEN_CAPTURE_ID="<failed>"
	fi
fi

# ---------------------------------------------------------------------------
# 13. Set lock screen inactivity timer  →  All Users
# ---------------------------------------------------------------------------

echo "==> 13. Set lock screen inactivity timer"
LOCK_SCREEN_ID=$(find_device_config_policy "Set lock screen inactivity timer")

if [[ -n "$LOCK_SCREEN_ID" ]]; then
	echo "    Already exists (ID: $LOCK_SCREEN_ID) — skipping."
else
	LOCK_SCREEN_BODY=$(
		cat <<'EOF'
{"@odata.type":"#microsoft.graph.windows10EndpointProtectionConfiguration","displayName":"Set lock screen inactivity timer","machineInactivityLimit":15}
EOF
	)
	if LOCK_SCREEN_ID=$(az rest --method POST \
		--url "${GRAPH}/deviceManagement/deviceConfigurations" \
		--headers "Content-Type=application/json" \
		--body "$LOCK_SCREEN_BODY" \
		--query "id" -o tsv); then
		echo "    Created (ID: $LOCK_SCREEN_ID)"
		assign_device_config_policy "$LOCK_SCREEN_ID" "$ALL_USERS_GROUP_ID" || echo "    WARNING: Assignment failed."
		echo "    Assigned to All Users."
	else
		echo "    ERROR: Creation failed (see above)."
		POLICY_ERRORS+=("Set lock screen inactivity timer")
		LOCK_SCREEN_ID="<failed>"
	fi
fi

# ---------------------------------------------------------------------------
# 14. Set password policy  →  All Windows 10 and later Devices
# ---------------------------------------------------------------------------

echo "==> 14. Set password policy"
PASSWORD_POLICY_ID=$(find_device_config_policy "Set password policy")

if [[ -n "$PASSWORD_POLICY_ID" ]]; then
	echo "    Already exists (ID: $PASSWORD_POLICY_ID) — skipping."
else
	PASSWORD_POLICY_BODY=$(
		cat <<'EOF'
{"@odata.type":"#microsoft.graph.windows10GeneralConfiguration","displayName":"Set password policy","passwordRequired":true,"passwordRequiredType":"alphanumeric","passwordMinimumLength":10,"passwordMinimumCharacterSetCount":4,"passwordExpirationDays":90,"passwordPreviousPasswordBlockCount":10,"passwordSignInFailureCountBeforeFactoryReset":10,"passwordRequireWhenResumeFromIdleState":true}
EOF
	)
	if PASSWORD_POLICY_ID=$(az rest --method POST \
		--url "${GRAPH}/deviceManagement/deviceConfigurations" \
		--headers "Content-Type=application/json" \
		--body "$PASSWORD_POLICY_BODY" \
		--query "id" -o tsv); then
		echo "    Created (ID: $PASSWORD_POLICY_ID)"
		assign_device_config_policy "$PASSWORD_POLICY_ID" "$ALL_WINDOWS_DEVICES_GROUP_ID" || echo "    WARNING: Assignment failed."
		echo "    Assigned to All Windows devices."
	else
		echo "    ERROR: Creation failed (see above)."
		POLICY_ERRORS+=("Set password policy")
		PASSWORD_POLICY_ID="<failed>"
	fi
fi

# ---------------------------------------------------------------------------
# Summary
# ---------------------------------------------------------------------------

echo ""
if [[ ${#POLICY_ERRORS[@]} -gt 0 ]]; then
	echo "WARNING: ${#POLICY_ERRORS[@]} policy(s) failed to deploy:"
	for p in "${POLICY_ERRORS[@]}"; do
		echo "  - $p"
	done
	echo ""
fi
echo "Done."
echo ""
printf "%-55s %s\n" "Policy" "ID"
printf "%-55s %s\n" "------" "--"
printf "%-55s %s\n" "CMMC - BitLocker Encryption" "${BITLOCKER_ID:-<failed>}"
printf "%-55s %s\n" "CMMC - Windows Defender Antivirus" "${DEFENDER_ID:-<failed>}"
printf "%-55s %s\n" "CMMC - Windows Firewall" "${FIREWALL_ID:-<failed>}"
printf "%-55s %s\n" "CMMC - Windows Device Compliance" "${COMPLIANCE_ID:-<failed>}"
printf "%-55s %s\n" "Configure device and resource redirection" "${RDP_REDIR_ID:-<failed>}"
printf "%-55s %s\n" "Configure GPU acceleration for Azure Virtual Desktop" "${GPU_ACCEL_ID:-<skipped>}"
printf "%-55s %s\n" "Configure OneDrive settings" "${ONEDRIVE_ID:-<failed>}"
printf "%-55s %s\n" "Configure Windows NTP client" "${NTP_ID:-<failed>}"
printf "%-55s %s\n" "Disable password reveal" "${PWD_REVEAL_ID:-<failed>}"
printf "%-55s %s\n" "Enable AIP add-in for sensitivity labeling" "${AIP_ID:-<failed>}"
printf "%-55s %s\n" "Enable interactive logon banner" "${LOGON_BANNER_ID:-<failed>}"
printf "%-55s %s\n" "Enable screen capture protection" "${SCREEN_CAPTURE_ID:-<failed>}"
printf "%-55s %s\n" "Set lock screen inactivity timer" "${LOCK_SCREEN_ID:-<failed>}"
printf "%-55s %s\n" "Set password policy" "${PASSWORD_POLICY_ID:-<failed>}"
echo ""
echo "Verify at: https://intune.microsoft.us → Devices → Configuration / Compliance policies"
