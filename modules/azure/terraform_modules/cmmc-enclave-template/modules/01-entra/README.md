# Module: 01-entra

Creates Entra ID security groups, PIM eligibility schedules, subscription-level RBAC assignments, and conditional access policies for a CMMC GCC High enclave.

## Resources Created

- PIM-eligible groups: Service Desk, Compliance, Security Operations, Security Engineering, Escalation Engineers, Global Admin
- RBAC groups: Owner, Contributor, Billing Reader
- Dynamic SSPR group
- Directory role assignments for each PIM group
- Subscription-level RBAC assignments
- Conditional Access policies: Require MFA, Block non-US sign-ins, Block legacy auth
- Named location: United States

## Requirements

- Entra ID P2 or Microsoft Entra Governance license (for PIM)
- `azuread` provider authenticated with `Directory.ReadWrite.All` and `Policy.ReadWrite.ConditionalAccess` permissions

## Usage

```hcl
module "entra" {
  source = "github.com/thinkstack-co/terraform-modules//modules/azure/terraform_modules/cmmc-enclave-template/modules/01-entra?ref=v2.9.2"

  tenant_id       = var.tenant_id
  subscription_id = var.subscription_id
  customer_name   = var.customer_name
  admin_upns      = var.admin_upns
  tags            = local.common_tags
}
```

## Inputs

| Name | Type | Default | Description |
|---|---|---|---|
| `tenant_id` | string | required | Entra ID tenant ID |
| `subscription_id` | string | required | Azure subscription ID |
| `customer_name` | string | required | Short customer name for group naming |
| `admin_upns` | list(string) | `[]` | UPNs for initial Global Admin group members |
| `mfa_exempt_group_ids` | list(string) | `[]` | Groups excluded from MFA CA policy |
| `tags` | map(string) | `{}` | Resource tags |

## Outputs

| Name | Description |
|---|---|
| `group_ids` | Map of PIM group key → object ID |
| `rbac_group_ids` | Map of RBAC group key → object ID |
| `sspr_group_id` | Object ID of dynamic SSPR group |
| `ca_policy_ids` | Map of CA policy name → policy ID |
