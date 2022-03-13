## Requirements

No requirements.

## Providers

| Name | Version |
|------|---------|
| aws | n/a |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| appliance\_mdoe\_support | (Optional) Whether Appliance Mode support is enabled. If enabled, a traffic flow between a source and destination uses the same Availability Zone for the VPC attachment for the lifetime of that flow. | `string` | `"disable"` | no |
| dns\_support | (Optional) Whether DNS support is enabled. | `string` | `"enable"` | no |
| ipv6\_support | (Optional) Whether IPv6 support is enabled. | `string` | `"disable"` | no |
| name | (Required) The name of the transit gateway attachment | `string` | n/a | yes |
| subnet\_ids | (Required) Identifiers of EC2 Subnets. | `list` | n/a | yes |
| tags | (Optional) Map of tags for the EC2 Transit Gateway. | `map` | <pre>{<br>  "environment": "prod",<br>  "project": "core_infrastructure",<br>  "terraform": "true"<br>}</pre> | no |
| transit\_gateway\_default\_route\_table\_association | (Optional) Boolean whether the VPC Attachment should be associated with the EC2 Transit Gateway association default route table. This cannot be configured or perform drift detection with Resource Access Manager shared EC2 Transit Gateways. | `bool` | `true` | no |
| transit\_gateway\_default\_route\_table\_propagation | (Optional) Boolean whether the VPC Attachment should be associated with the EC2 Transit Gateway association default route table. This cannot be configured or perform drift detection with Resource Access Manager shared EC2 Transit Gateways. | `bool` | `true` | no |
| transit\_gateway\_id | (Optional) Boolean whether the VPC Attachment should propagate routes with the EC2 Transit Gateway propagation default route table. This cannot be configured or perform drift detection with Resource Access Manager shared EC2 Transit Gateways. | `bool` | `true` | no |
| vpc\_id | (Required) Identifier of EC2 VPC. | `any` | n/a | yes |

## Outputs

| Name | Description |
|------|-------------|
| transit\_gateway\_attachment\_id | n/a |
| transit\_gateway\_attachment\_vpc\_owner\_id | n/a |