# Module: 03-prod-vnet

Deploys the production virtual network with customer subnets, bidirectional VNet peering to the management VNet, and a route table that forces traffic through the management Azure Firewall.

## Resources Created

- Production VNet with configurable number of /24 subnets
- Bidirectional VNet peering to management VNet
- Route table routing 0.0.0.0/0 through management firewall
- Log Analytics workspace + VNet diagnostic settings

## Usage

```hcl
module "prod_vnet" {
  source = "github.com/NetworkCoverage/cmmc-enclave-template//modules/03-prod-vnet?ref=v1.0.0"

  resource_group_name      = azurerm_resource_group.prod.name
  location                 = var.location
  customer_name            = var.customer_name
  mgmt_vnet_id             = module.mgmt_vnet.vnet_id
  mgmt_vnet_name           = module.mgmt_vnet.vnet_name
  mgmt_resource_group_name = azurerm_resource_group.mgmt.name
  firewall_private_ip      = module.mgmt_vnet.firewall_private_ip
  tags                     = local.common_tags
}
```

## Inputs

| Name | Type | Default | Description |
|---|---|---|---|
| `resource_group_name` | string | required | Resource group name |
| `location` | string | required | Azure Government region |
| `customer_name` | string | required | Short customer name |
| `prod_vnet_cidr` | string | `172.17.0.0/16` | Production VNet address space |
| `subnet_count` | number | `2` | Number of /24 customer subnets |
| `mgmt_vnet_id` | string | required | Management VNet resource ID |
| `mgmt_vnet_name` | string | required | Management VNet name |
| `mgmt_resource_group_name` | string | required | Management VNet resource group |
| `firewall_private_ip` | string | required | Firewall private IP for routing |
| `log_retention_days` | number | `30` | Log retention in days |
| `tags` | map(string) | `{}` | Resource tags |

## Outputs

| Name | Description |
|---|---|
| `vnet_id` | Production VNet resource ID |
| `vnet_name` | Production VNet name |
| `subnet_ids` | List of subnet resource IDs |
| `subnet_names` | List of subnet names |
