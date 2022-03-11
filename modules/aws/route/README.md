## Requirements

| Name | Version |
|------|---------|
| terraform | >= 0.15.0 |

## Providers

| Name | Version |
|------|---------|
| aws | n/a |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| destination\_cidr\_block | (Optional) The destination CIDR block. | `string` | n/a | yes |
| destination\_ipv6\_cidr\_block | (Optional) The destination IPv6 CIDR block. | `string` | `null` | no |
| egress\_only\_gateway\_id | (Optional) An ID of a VPC Egress Only Internet Gateway. | `string` | `""` | no |
| gateway\_id | (Optional) An ID of a VPC internet gateway or a virtual private gateway. | `string` | `""` | no |
| nat\_gateway\_id | (Optional) An ID of a VPC NAT gateway. | `string` | `""` | no |
| network\_interface\_id | (Optional) An ID of a network interface. | `list` | `[]` | no |
| route\_table\_id | (Required) The ID of the routing table. | `list` | n/a | yes |
| vpc\_peering\_connection\_id | (Optional) An ID of a VPC peering connection. | `string` | `""` | no |

## Outputs

No output.