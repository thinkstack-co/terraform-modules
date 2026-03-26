# Module: 01-entra

Creates Entra ID security groups, PIM eligibility schedules, subscription-level RBAC assignments, named locations, and conditional access policies for a CMMC GCC High enclave.

## Resources Created

**PIM-eligible groups** (role-assignable; `IsAssignableToRole = true`)

| Group | Roles |
|---|---|
| Service Desk PIM Eligible Role Assignments | User Admin, Intune Admin, Exchange Admin, SharePoint Admin, Groups Admin, Global Reader |
| Compliance PIM Eligible Role Assignments | User Admin, Auth Admin, Cloud App Security Admin, Security Admin, Groups Admin, Global Reader |
| Security Operations PIM Eligible Role Assignments | Security Operator, User Admin, Auth Admin, Intune Admin, Exchange Admin, Global Reader |
| Escalation Engineers PIM Eligible Role Assignments | Security Admin, Intune Admin, Auth Admin, Global Reader |
| Security Engineering PIM Eligible Role Assignments | Cloud App Admin, Cloud App Security Admin, Security Admin, Global Reader |
| Global Admin PIM Eligible Role Assignments | Global Administrator |

**RBAC groups** (subscription-level role assignments)

| Group | Role |
|---|---|
| Owner RBAC Role Assignments | Owner (with role assignment condition blocking privileged role grants) |
| Contributor RBAC Role Assignments | Contributor |
| Billing Reader RBAC Role Assignments | Billing Reader |

**Static group**

- `{customer_name} - Multifactor Authentication Exempt` — excluded from the Require MFA CA policy

**Dynamic groups**

| Group | Membership Rule |
|---|---|
| `{customer_name} - Self Service Password Reset Enabled` | `companyName = customer_name OR msp_company_name` AND `accountEnabled` |
| `{customer_name} - All Users` | `accountEnabled = true` |
| `{license_name} Licensed Users` | `companyName = customer_name` AND `accountEnabled` |
| `{customer_name} - All Windows 10 and Later Devices` | Windows devices, OS 10.0.1x / 10.0.2x, accountEnabled |
| `{customer_name} - All Azure Virtual Desktop Hosts` | Devices starting with `{customer_name}-mgmt-avd`, `{customer_name}-prod-avd`, or `{customer_name}-cad-avd`, accountEnabled |
| `{customer_name} - GPU-optimized Azure VMs` | Devices starting with `{customer_name}-cad-avd`, accountEnabled |

**Named locations**

- `{customer_name} - United States` — country-based, used to scope MFA and block non-US policies
- `{customer_name} - Secure Enclave` — IP-based trusted location built from `var.secure_enclave_ips`

**Conditional Access policies**

| Policy | State | Description |
|---|---|---|
| Require MFA for All Users | enabled | MFA required for all US sign-ins; excludes MFA exempt group and `var.mfa_exempt_group_ids` |
| Block Sign-ins Outside United States | enabled | Blocks all sign-ins from outside the US named location |
| Block Legacy Authentication | enabled | Blocks Exchange ActiveSync and other legacy clients |
| Block access outside Zero Trust Network | report-only | Blocks all apps from outside the Secure Enclave IP named location |
| Block non-AVD cloud apps on ZTNA unless using AVD | report-only | Blocks non-AVD apps from non-AVD devices outside ZTNA |
| Enforce periodic reauthentication for AVD cloud apps | report-only | 1-hour sign-in frequency for AVD app IDs |

## Requirements

- Entra ID P2 or Microsoft Entra Governance license (for PIM)
- `azuread` provider authenticated with `Directory.ReadWrite.All`, `Policy.ReadWrite.ConditionalAccess`, and `RoleManagement.ReadWrite.Directory`
- `azurerm` provider authenticated with Owner or User Access Administrator on the target subscription

## Usage

```hcl
module "entra" {
  source = "github.com/thinkstack-co/terraform-modules//modules/azure/terraform_modules/cmmc-enclave-template/modules/01-entra?ref=v2.9.2"

  tenant_id                   = var.tenant_id
  subscription_id             = var.subscription_id
  customer_name               = var.customer_name
  license_name                = ["Microsoft 365 GCC High"]
  appgate_oidc_application_id = var.appgate_app_id
  secure_enclave_ips          = var.secure_enclave_ips
  admin_upns                  = var.admin_upns
  excluded_user_ids           = var.break_glass_user_ids
  tags                        = local.common_tags
}
```

## Inputs

| Name | Type | Default | Description |
|---|---|---|---|
| `tenant_id` | string | required | Entra ID tenant ID |
| `subscription_id` | string | required | Azure subscription ID for RBAC assignments |
| `customer_name` | string | required | Customer name used in group and policy display names |
| `license_name` | list(string) | required | License name(s) for the Licensed Users dynamic group |
| `secure_enclave_ips` | list(string) | required | IPv4 addresses for the Secure Enclave trusted named location |
| `admin_upns` | list(string) | `[]` | UPNs to add as initial members of the Global Admin PIM group |
| `mfa_exempt_group_ids` | list(string) | `[]` | Additional group IDs excluded from the Require MFA CA policy |
| `excluded_user_ids` | list(string) | `[]` | User object IDs excluded from ZTNA CA policies (e.g., break-glass accounts) |
| `msp_company_name` | string | `"Network Coverage"` | MSP company name included in the SSPR dynamic group rule |
| `tags` | map(string) | `{}` | Tags applied to resources |

## Outputs

| Name | Description |
|---|---|
| `group_ids` | Map of PIM group key → object ID |
| `rbac_group_ids` | Map of RBAC group key → object ID |
| `sspr_group_id` | Object ID of the SSPR dynamic group |
| `mfa_exempt_group_id` | Object ID of the MFA Exempt group |
| `all_users_group_id` | Object ID of the All Users dynamic group |
| `licensed_users_group_id` | Object ID of the Licensed Users dynamic group |
| `all_windows_devices_group_id` | Object ID of the All Windows 10+ Devices dynamic group |
| `avd_hosts_group_id` | Object ID of the All Azure Virtual Desktop Hosts dynamic group |
| `gpu_vms_group_id` | Object ID of the GPU-optimized Azure VMs dynamic group |
| `secure_enclave_location_id` | ID of the Secure Enclave named location |
| `ca_policy_ids` | Map of CA policy key → policy ID (`require_mfa`, `block_non_us`, `block_legacy_auth`, `block_outside_ztna`, `block_non_avd_outside_ztna`, `avd_reauthentication`) |
