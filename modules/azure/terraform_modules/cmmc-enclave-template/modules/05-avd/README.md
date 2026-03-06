# Module: 05-avd

Deploys Azure Virtual Desktop host pools, application groups, workspaces, a scaling plan, RBAC assignments, and Log Analytics diagnostics.

## Resources Created

- Management host pool (Pooled, DepthFirst, 2 max sessions)
- Customer host pool (configurable type/load balancer)
- Registration tokens for both host pools (2-hour expiry)
- Desktop application groups for both host pools
- Workspaces for both host pools
- Scaling plan with weekday schedule (attached to customer host pool)
- RBAC: Desktop Virtualization User + Power On Off Contributor
- Diagnostic settings for host pools and workspace

## Important Note on Registration Tokens

Registration tokens expire 2 hours after `terraform apply`. Session host VMs must be created within this window. To refresh tokens without affecting other resources:

```bash
terraform apply -target=module.avd.azurerm_virtual_desktop_host_pool_registration_info.customer
```

## Usage

```hcl
module "avd" {
  source = "github.com/NetworkCoverage/cmmc-enclave-template//modules/05-avd?ref=v1.0.0"

  resource_group_name        = azurerm_resource_group.avd.name
  location                   = var.location
  customer_name              = var.customer_name
  log_analytics_workspace_id = module.mgmt_vnet.log_analytics_workspace_id
  avd_users_group_id         = module.entra.group_ids["service_desk"]
  tags                       = local.common_tags
}
```

## Inputs

| Name | Type | Default | Description |
|---|---|---|---|
| `resource_group_name` | string | required | Resource group name |
| `location` | string | required | Azure Government region |
| `customer_name` | string | required | Short customer name |
| `log_analytics_workspace_id` | string | required | Log Analytics workspace ID |
| `avd_users_group_id` | string | required | Entra group for AVD users |
| `customer_host_pool_type` | string | `Pooled` | `Pooled` or `Personal` |
| `customer_max_sessions` | number | `10` | Max sessions per host |
| `customer_load_balancer_type` | string | `BreadthFirst` | Load balancing algorithm |
| `tags` | map(string) | `{}` | Resource tags |

## Outputs

| Name | Description |
|---|---|
| `mgmt_host_pool_id` | Management host pool resource ID |
| `customer_host_pool_id` | Customer host pool resource ID |
| `mgmt_registration_token` | Management pool registration token (sensitive) |
| `customer_registration_token` | Customer pool registration token (sensitive) |
| `mgmt_workspace_id` | Management workspace resource ID |
| `customer_workspace_id` | Customer workspace resource ID |
