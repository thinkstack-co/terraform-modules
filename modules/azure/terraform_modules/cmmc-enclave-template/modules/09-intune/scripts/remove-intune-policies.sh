#!/usr/bin/env bash
# remove-intune-policies.sh
#
# Deletes the CMMC Intune policies created by deploy-intune-policies.sh.
# Finds policies by display name and prompts for confirmation before deleting.
#
# Run from Azure Cloud Shell authenticated to the target tenant.
#
# Usage:
#   ./remove-intune-policies.sh

set -euo pipefail

GRAPH="https://graph.microsoft.us/beta"

CONFIG_POLICY_NAMES=(
  "CMMC - Windows Defender Antivirus"
  "CMMC - Windows Firewall"
  "Configure device and resource redirection"
  "Configure GPU acceleration for Azure Virtual Desktop"
  "Configure OneDrive settings"
  "Configure Windows NTP client"
  "Disable password reveal"
  "Enable Azure Information Protection add-in for sensitivity labeling"
  "Enable interactive logon banner"
  "Enable screen capture protection"
)

DEVICE_COMPLIANCE_POLICY_NAMES=(
  "CMMC - Windows Device Compliance"
)

DEVICE_CONFIG_POLICY_NAMES=(
  "CMMC - BitLocker Encryption"
  "Set lock screen inactivity timer"
  "Set password policy"
)

# ---------------------------------------------------------------------------
# Verify Azure Government environment
# ---------------------------------------------------------------------------

ENVIRONMENT=$(az account show --query "environmentName" -o tsv 2>/dev/null || true)
if [[ "$ENVIRONMENT" != "AzureUSGovernment" ]]; then
  echo "Error: Azure CLI is not targeting AzureUSGovernment (current: '${ENVIRONMENT}')." >&2
  echo "Run: az cloud set --name AzureUSGovernment && az login" >&2
  exit 1
fi

# ---------------------------------------------------------------------------
# Discover policies to delete
# ---------------------------------------------------------------------------

declare -A TO_DELETE_CONFIG
declare -A TO_DELETE_DEVICE_COMPLIANCE
declare -A TO_DELETE_DEVICE_CONFIG

echo "Searching for Intune policies..."
echo ""

for name in "${CONFIG_POLICY_NAMES[@]}"; do
  encoded=$(python3 -c "import urllib.parse; print(urllib.parse.quote(\"$name\"))")
  id=$(az rest --method GET \
    --url "${GRAPH}/deviceManagement/configurationPolicies?\$filter=name+eq+'${encoded}'" \
    --query "value[0].id" -o tsv 2>/dev/null || echo "")
  if [[ -n "$id" ]]; then
    TO_DELETE_CONFIG["$name"]="$id"
    echo "  [found] $name  ($id)"
  else
    echo "  [not found] $name"
  fi
done

for name in "${DEVICE_COMPLIANCE_POLICY_NAMES[@]}"; do
  encoded=$(python3 -c "import urllib.parse; print(urllib.parse.quote(\"$name\"))")
  id=$(az rest --method GET \
    --url "${GRAPH}/deviceManagement/deviceCompliancePolicies?\$filter=displayName+eq+'${encoded}'" \
    --query "value[0].id" -o tsv 2>/dev/null || echo "")
  if [[ -n "$id" ]]; then
    TO_DELETE_DEVICE_COMPLIANCE["$name"]="$id"
    echo "  [found] $name  ($id)"
  else
    echo "  [not found] $name"
  fi
done

for name in "${DEVICE_CONFIG_POLICY_NAMES[@]}"; do
  encoded=$(python3 -c "import urllib.parse; print(urllib.parse.quote(\"$name\"))")
  id=$(az rest --method GET \
    --url "${GRAPH}/deviceManagement/deviceConfigurations?\$filter=displayName+eq+'${encoded}'" \
    --query "value[0].id" -o tsv 2>/dev/null || echo "")
  if [[ -n "$id" ]]; then
    TO_DELETE_DEVICE_CONFIG["$name"]="$id"
    echo "  [found] $name  ($id)"
  else
    echo "  [not found] $name"
  fi
done

TOTAL=$(( ${#TO_DELETE_CONFIG[@]} + ${#TO_DELETE_DEVICE_COMPLIANCE[@]} + ${#TO_DELETE_DEVICE_CONFIG[@]} ))

if [[ $TOTAL -eq 0 ]]; then
  echo ""
  echo "No CMMC policies found. Nothing to delete."
  exit 0
fi

echo ""
echo "$TOTAL policy(s) will be deleted."
read -r -p "Confirm deletion? [y/N] " confirm
if [[ "$confirm" != "y" && "$confirm" != "Y" ]]; then
  echo "Aborted."
  exit 0
fi

echo ""

# ---------------------------------------------------------------------------
# Delete configuration policies
# ---------------------------------------------------------------------------

for name in "${!TO_DELETE_CONFIG[@]}"; do
  id="${TO_DELETE_CONFIG[$name]}"
  echo "Deleting configuration policy: $name ($id)"
  az rest --method DELETE \
    --url "${GRAPH}/deviceManagement/configurationPolicies/${id}" 2>/dev/null
  echo "  Deleted."
done

# ---------------------------------------------------------------------------
# Delete device compliance policies (legacy endpoint)
# ---------------------------------------------------------------------------

for name in "${!TO_DELETE_DEVICE_COMPLIANCE[@]}"; do
  id="${TO_DELETE_DEVICE_COMPLIANCE[$name]}"
  echo "Deleting device compliance policy: $name ($id)"
  az rest --method DELETE \
    --url "${GRAPH}/deviceManagement/deviceCompliancePolicies/${id}" 2>/dev/null
  echo "  Deleted."
done

# ---------------------------------------------------------------------------
# Delete device configuration policies (legacy endpoint)
# ---------------------------------------------------------------------------

for name in "${!TO_DELETE_DEVICE_CONFIG[@]}"; do
  id="${TO_DELETE_DEVICE_CONFIG[$name]}"
  echo "Deleting device configuration policy: $name ($id)"
  az rest --method DELETE \
    --url "${GRAPH}/deviceManagement/deviceConfigurations/${id}" 2>/dev/null
  echo "  Deleted."
done

echo ""
echo "Done. $TOTAL policy(s) deleted."
