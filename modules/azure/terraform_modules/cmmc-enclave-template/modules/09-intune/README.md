# Module: 09-intune

Deploys Intune device configuration and compliance policies via the `microsoft/msgraph` Terraform provider (MS Graph API).

## Resources Created

**Settings Catalog policies** (`deviceManagement/configurationPolicies`)

| Policy | Assignment target |
|---|---|
| CMMC - BitLocker Encryption | AVD hosts |
| CMMC - Windows Defender Antivirus | `target_group_ids` |
| CMMC - Windows Firewall | `target_group_ids` |
| Configure device and resource redirection | AVD hosts |
| Configure GPU acceleration for Azure Virtual Desktop | GPU VMs (skipped if `gpu_vm_group_id` is null) |
| Configure OneDrive settings | AVD hosts |
| Configure Windows NTP client | AVD hosts |
| Disable password reveal | All users |
| Enable Azure Information Protection add-in for sensitivity labeling | All users |
| Enable interactive logon banner | AVD hosts |
| Enable screen capture protection | AVD hosts |

**Legacy device configuration policies** (`deviceManagement/deviceConfigurations`)

| Policy | Type | Assignment target |
|---|---|---|
| Set lock screen inactivity timer (15 min) | `windows10EndpointProtectionConfiguration` | All users |
| Set password policy (10-char, alphanumeric, 90-day expiry) | `windows10GeneralConfiguration` | All Windows devices |

**Device compliance policy** (`deviceManagement/compliancePolicies`)

| Policy | Assignment target |
|---|---|
| CMMC - Windows Device Compliance (antivirus, Defender, firewall, BitLocker) | `target_group_ids` |

## Azure Government Status

> **This module is currently disabled for Azure Government deployments.**
>
> `microsoft/msgraph ~> 0.3.0` returns `InvalidCloudInstance` when authenticating via OIDC against Azure Government endpoints. Comment out `module "intune"` in the customer repo `main.tf` until a Gov-compatible provider version is available. Track provider support at the [msgraph provider releases](https://github.com/microsoft/terraform-provider-msgraph/releases).

## Cloud Shell Alternative

Since this module cannot be used in Azure Government, deploy the same policies via `az rest` from Azure Cloud Shell using the scripts in `scripts/`.

See the full runbook: [docs/intune-cloud-shell.md](../../docs/intune-cloud-shell.md)

Quick start:

```bash
# Set these two values for the customer
CUSTOMER_PREFIX="owi"           # customer_name used in Terraform (e.g. "owi")
CUSTOMER_DISPLAY_NAME="Overwatch Imaging"

TENANT_ID=$(az account show --query tenantId -o tsv)

./scripts/deploy-intune-policies.sh \
  --tenant-id "$TENANT_ID" \
  --customer-name "$CUSTOMER_DISPLAY_NAME" \
  --avd-host-group-id "$(az ad group show --group "$CUSTOMER_PREFIX - All Azure Virtual Desktop Hosts" --query id -o tsv)" \
  --all-users-group-id "$(az ad group show --group "$CUSTOMER_PREFIX - All Users" --query id -o tsv)" \
  --all-windows-devices-group-id "$(az ad group show --group "$CUSTOMER_PREFIX - All Windows 10 and Later Devices" --query id -o tsv)" \
  --group-id "$(az ad group show --group "$CUSTOMER_PREFIX - Self Service Password Reset Enabled" --query id -o tsv)"
```

Optionally add the GPU acceleration policy:

```bash
  --gpu-vm-group-id "$(az ad group show --group "$CUSTOMER_PREFIX - GPU-optimized Azure VMs" --query id -o tsv)"
```

`--group-id` is repeatable — pass it multiple times to target additional CMMC baseline groups.

To remove all policies:

```bash
./scripts/remove-intune-policies.sh
```

## Provider Notes

This module uses the `microsoft/msgraph` provider (`~> 0.3.0`), which calls MS Graph Beta endpoints via generic `msgraph_resource` and `msgraph_resource_action` resources. The Settings Catalog policy payloads embed Graph API JSON directly in the `body` attribute. Policy IDs are extracted via `response_export_values = ["id"]`.

Assignments use a single `msgraph_resource_action` per policy (targeting the `/assign` action), which replaces all assignments in one call — consistent with the Graph API's replace-all semantics.

If you need to customize these policies:

1. Configure the policy manually in Intune at <https://intune.microsoft.us>
2. Export the settings via Graph API: `GET /beta/deviceManagement/configurationPolicies/{id}/settings`
3. Replace the `settings` JSON in `main.tf`

## Usage

```hcl
module "intune" {
  source = "github.com/thinkstack-co/terraform-modules//modules/azure/terraform_modules/cmmc-enclave-template/modules/09-intune?ref=v2.9.2"

  tenant_id                    = var.tenant_id
  customer_name                = var.customer_name
  avd_host_group_id            = module.entra.avd_hosts_group_id
  all_users_group_id           = module.entra.all_users_group_id
  all_windows_devices_group_id = module.entra.all_windows_devices_group_id
  gpu_vm_group_id              = module.entra.gpu_vms_group_id   # set null to skip GPU policy
  target_group_ids             = [module.entra.sspr_group_id]
}
```

## Inputs

| Name | Type | Default | Description |
|---|---|---|---|
| `tenant_id` | string | required | Entra ID tenant ID (used in OneDrive KFM settings) |
| `customer_name` | string | required | Customer name used in the interactive logon banner |
| `avd_host_group_id` | string | required | Group ID for AVD-targeted policies and BitLocker |
| `all_users_group_id` | string | required | Group ID for user-targeted policies |
| `all_windows_devices_group_id` | string | required | Group ID for device-targeted policies |
| `target_group_ids` | list(string) | required | Group IDs for CMMC baseline policies (Defender, Firewall, Compliance) |
| `gpu_vm_group_id` | string | `null` | Group ID for the GPU acceleration policy; omit to skip |
| `bitlocker_encryption_method` | string | `xtsAes128` | `xtsAes128` or `xtsAes256` |
| `compliance_grace_period_hours` | number | `0` | Grace period in hours before non-compliant devices are blocked |
| `tags` | map(string) | `{}` | Reserved (not used by provider) |

## Outputs

| Name | Description |
|---|---|
| `bitlocker_policy_id` | CMMC - BitLocker Encryption |
| `defender_policy_id` | CMMC - Windows Defender Antivirus |
| `firewall_policy_id` | CMMC - Windows Firewall |
| `compliance_policy_id` | CMMC - Windows Device Compliance |
| `rdp_redirection_policy_id` | Configure device and resource redirection |
| `gpu_acceleration_policy_id` | Configure GPU acceleration (null if `gpu_vm_group_id` not set) |
| `onedrive_policy_id` | Configure OneDrive settings |
| `ntp_policy_id` | Configure Windows NTP client |
| `password_reveal_policy_id` | Disable password reveal |
| `aip_policy_id` | Enable AIP add-in for sensitivity labeling |
| `logon_banner_policy_id` | Enable interactive logon banner |
| `screen_capture_policy_id` | Enable screen capture protection |
| `lock_screen_policy_id` | Set lock screen inactivity timer |
| `password_policy_id` | Set password policy |
