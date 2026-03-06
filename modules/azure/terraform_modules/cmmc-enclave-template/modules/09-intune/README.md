# Module: 09-intune

Deploys Intune device configuration and compliance policies via the `microsoft365` Terraform provider (MS Graph API).

## Resources Created

- BitLocker configuration policy (XTS-AES-128 OS + fixed drives, recovery options)
- Windows Defender configuration policy (real-time, cloud, behavior monitoring)
- Windows Firewall configuration policy (all profiles enabled)
- Device compliance policy (antivirus, Defender, firewall, BitLocker)
- Group assignments for all policies

## Provider Notes

This module uses the `hashicorp/microsoft365` provider which calls MS Graph Beta endpoints. The Settings Catalog policy payloads embed Graph API JSON directly. If you need to customize these policies:

1. Configure the policy manually in Intune at https://intune.microsoft.us
2. Export the settings via Graph API: `GET /beta/deviceManagement/configurationPolicies/{id}/settings`
3. Replace the `settings` JSON in `main.tf`

## Usage

```hcl
module "intune" {
  source = "github.com/NetworkCoverage/cmmc-enclave-template//modules/09-intune?ref=v1.0.0"

  tenant_id        = var.tenant_id
  target_group_ids = [module.entra.sspr_group_id]
}
```

## Inputs

| Name | Type | Default | Description |
|---|---|---|---|
| `tenant_id` | string | required | Entra ID tenant ID |
| `target_group_ids` | list(string) | required | Groups to assign policies to |
| `bitlocker_encryption_method` | string | `xtsAes128` | `xtsAes128` or `xtsAes256` |
| `compliance_grace_period_hours` | number | `0` | Grace period before blocking |
| `tags` | map(string) | `{}` | Reserved (not used by provider) |

## Outputs

| Name | Description |
|---|---|
| `bitlocker_policy_id` | BitLocker policy ID |
| `defender_policy_id` | Defender policy ID |
| `firewall_policy_id` | Firewall policy ID |
| `compliance_policy_id` | Compliance policy ID |
