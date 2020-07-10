## Requirements

| Name | Version |
|------|---------|
| terraform | >= 0.12.0 |

## Providers

| Name | Version |
|------|---------|
| aws | n/a |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| availability\_zone | Availability zone in which to apply the VPN | `string` | `""` | no |
| bgp\_asn | BGP ASN used for dynamic routing between the customer gateway and AWS gateway | `number` | `65000` | no |
| customer\_gw\_name | (Required) List of names to use for the customer gateways | `list` | n/a | yes |
| ip\_address | Customer gateway external IP address | `list` | n/a | yes |
| name | Name to be used on all the resources as identifier | `string` | `"vpn_terraform"` | no |
| static\_routes\_only | Flag to determine whether or not dynamic or static routing is enabled | `bool` | `true` | no |
| tags | Tags assigned to all created resources | `map` | `{}` | no |
| vpc\_id | VPC ID | `any` | n/a | yes |
| vpn\_type | Type of VPN tunnel. Currently only supports ipsec.1 | `string` | `"ipsec.1"` | no |

## Outputs

| Name | Description |
|------|-------------|
| customer\_gateway\_bgp\_asn | n/a |
| customer\_gateway\_id | n/a |
| customer\_gateway\_ip\_address | n/a |
| customer\_gateway\_type | n/a |
| vpn\_connection\_id | n/a |
| vpn\_connection\_tunnel1\_address | n/a |
| vpn\_connection\_tunnel2\_address | n/a |
| vpn\_gateway\_id | n/a |