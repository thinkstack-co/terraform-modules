# Module: 09-intune

Deploys Intune device configuration and compliance policies via the `microsoft/msgraph` Terraform provider (MS Graph API).

## Resources Created

- BitLocker configuration policy (XTS-AES-128 OS + fixed drives, recovery options)
- Windows Defender configuration policy (real-time, cloud, behavior monitoring)
- Windows Firewall configuration policy (all profiles enabled)
- Device compliance policy (antivirus, Defender, firewall, BitLocker)
- Group assignments for all policies

## Azure Government Status

> **This module is currently disabled for Azure Government deployments.**
>
> `microsoft/msgraph ~> 0.3.0` returns `InvalidCloudInstance` when authenticating via OIDC against Azure Government endpoints. Comment out `module "intune"` in the customer repo `main.tf` until a Gov-compatible provider version is available. Track provider support at the [msgraph provider releases](https://github.com/microsoft/terraform-provider-msgraph/releases).

## Cloud Shell Alternative

Since this module cannot be used in Azure Government, deploy the same policies via `az rest` from Azure Cloud Shell using the scripts in `scripts/`.

See the full runbook: [docs/intune-cloud-shell.md](../../docs/intune-cloud-shell.md)

Quick start:

```bash
GROUP_ID=$(az ad group list --display-name "<customer>-avd-users" --query "[0].id" -o tsv)
./scripts/deploy-intune-policies.sh --group-id "$GROUP_ID"
```

To remove policies:

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

  tenant_id        = var.tenant_id
  target_group_ids = [module.entra.sspr_group_id]
}
```

## Inputs

| Name | Type | Default | Description |
| --- | --- | --- | --- |
| `tenant_id` | string | required | Entra ID tenant ID |
| `target_group_ids` | list(string) | required | Groups to assign policies to |
| `bitlocker_encryption_method` | string | `xtsAes128` | `xtsAes128` or `xtsAes256` |
| `compliance_grace_period_hours` | number | `0` | Grace period before blocking |
| `tags` | map(string) | `{}` | Reserved (not used by provider) |

## Outputs

| Name | Description |
| --- | --- |
| `bitlocker_policy_id` | BitLocker policy ID |
| `defender_policy_id` | Defender policy ID |
| `firewall_policy_id` | Firewall policy ID |
| `compliance_policy_id` | Compliance policy ID |
