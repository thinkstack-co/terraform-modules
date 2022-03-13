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
| destination\_cidr\_block | (Optional) The destination CIDR block. | `string` | n/a | yes |
| destination\_ipv6\_cidr\_block | (Optional) The destination IPv6 CIDR block. | `string` | `null` | no |
| route\_table\_id | (Required) The ID of the routing table. | `list` | n/a | yes |
| transit\_gateway\_id | (Required) Identifier of an EC2 Transit Gateway. | `string` | `""` | yes |

## Outputs

No output.