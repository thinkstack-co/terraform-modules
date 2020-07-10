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
| vpn\_connection\_id | VPN connection id | `string` | n/a | yes |
| vpn\_route\_cidr\_block | CIDR block of the VPN subnets | `any` | n/a | yes |

## Outputs

| Name | Description |
|------|-------------|
| vpn\_connection\_route | n/a |
