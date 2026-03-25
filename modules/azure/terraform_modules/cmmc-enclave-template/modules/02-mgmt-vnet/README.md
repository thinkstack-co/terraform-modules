# Module: 02-mgmt-vnet

Deploys the management virtual network including Azure Firewall Premium, Azure Bastion, route tables, and Log Analytics workspaces.

## Resources Created

- Management VNet (172.16.0.0/16 default) with 4 subnets
- Azure Firewall Premium with IDPS in Alert mode, DNS proxy, web category filtering
- 2 public IPs for Azure Firewall
- Azure Bastion (Standard, 2 scale units) with file copy and tunneling
- Route table routing 0.0.0.0/0 through firewall (applied to ZTNA + Mgmt-AVD subnets)
- 2 Log Analytics workspaces (VNet + Firewall), 30-day retention
- Diagnostic settings for VNet and Firewall

## Usage

```hcl
module "mgmt_vnet" {
  source = "github.com/thinkstack-co/terraform-modules//modules/azure/terraform_modules/cmmc-enclave-template/modules/02-mgmt-vnet?ref=v2.9.2"

  resource_group_name = azurerm_resource_group.mgmt.name
  location            = var.location
  tags                = local.common_tags
}
```

## Inputs

| Name | Type | Default | Description |
|---|---|---|---|
| `resource_group_name` | string | required | Resource group name |
| `location` | string | required | Azure Government region |
| `mgmt_vnet_cidr` | string | `172.16.0.0/16` | Management VNet address space |
| `firewall_subnet_cidr` | string | `172.16.0.0/26` | AzureFirewallSubnet CIDR |
| `bastion_subnet_cidr` | string | `172.16.0.64/26` | AzureBastionSubnet CIDR |
| `ztna_subnet_cidr` | string | `172.16.0.128/26` | ZTNA subnet CIDR |
| `mgmt_avd_subnet_cidr` | string | `172.16.0.192/26` | Management AVD subnet CIDR |
| `log_retention_days` | number | `30` | Log Analytics retention days |
| `appgate_controller_dns_label` | string | `null` | DNS label for firewall PIP[0] (controller FQDN). Set to `<customer>-ztna-ag-ctl` when deploying Appgate. |
| `appgate_gateway_dns_label` | string | `null` | DNS label for firewall PIP[1] (gateway FQDN). Set to `<customer>-ztna-ag-gw` when deploying Appgate. |
| `tags` | map(string) | `{}` | Resource tags |

## Outputs

| Name | Description |
|---|---|
| `vnet_id` | Management VNet resource ID |
| `vnet_name` | Management VNet name |
| `subnet_ids` | Map of subnet name → resource ID |
| `firewall_private_ip` | Firewall private IP (used for routing) |
| `firewall_public_ip` | Firewall PIP[0] public IP address |
| `firewall_public_ip_2` | Firewall PIP[1] public IP address (gateway DNAT destination) |
| `firewall_public_ip_ids` | List of firewall public IP resource IDs |
| `firewall_public_ip_fqdns` | FQDNs for both firewall PIPs. Index 0 = controller, 1 = gateway. Null if no DNS label set. |
| `firewall_policy_id` | Firewall policy ID (for adding rule collection groups) |
| `log_analytics_workspace_id` | Shared Log Analytics workspace ID |
| `log_analytics_workspace_key` | Shared Log Analytics workspace key (sensitive) |
| `firewall_log_analytics_workspace_id` | Firewall-specific Log Analytics workspace ID |
