## Requirements

No requirements.

## Providers

| Name | Version |
|------|---------|
| aws | n/a |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| amazon\_side\_asn | (Optional) Private Autonomous System Number (ASN) for the Amazon side of a BGP session. | `string` | `"64512"` | no |
| auto\_accept\_shared\_attachments | (Optional) Whether resource attachment requests are automatically accepted. | `string` | `"disable"` | no |
| default\_route\_table\_association | (Optional) Whether resource attachments are automatically associated with the default association route table. | `string` | `"enable"` | no |
| default\_route\_table\_propagation | (Optional) Whether resource attachments automatically propagate routes to the default propagation route table. | `string` | `"64512"` | no |
| description | (Optional) Description of the EC2 Transit Gateway. | `string` | `"Transit gateway to allow access across VPCs or accounts."` | no |
| dns\_support | (Optional) Whether DNS support is enabled. | `string` | `"enable"` | no |
| tags | (Optional) Map of tags for the EC2 Transit Gateway. | `map` | <pre>{<br>  "environment": "prod",<br>  "project": "core_infrastructure",<br>  "terraform": "true"<br>}</pre> | no |
| vpn\_ecmp\_support | (Optional) Whether VPN Equal Cost Multipath Protocol support is enabled. | `string` | `"enable"` | no |

## Outputs

| Name | Description |
|------|-------------|
| transit\_gateway\_arn | n/a |
| transit\_gateway\_id | n/a |
| transit\_gateway\_propagation\_default\_route\_table\_id | n/a |
| transit\_gateway\_route\_table\_id | n/a |

 jakejones@Jacobs-MBP  ~/OneDrive - Think Stack/github/terraform-modules/modules/aws/transit_gateway   dev_transit_gateway_module  cd ..
 jakejones@Jacobs-MBP  ~/OneDrive - Think Stack/github/terraform-modules/modules/aws   dev_transit_gateway_module ±  cd transit_gateway_attachment
 jakejones@Jacobs-MBP  ~/OneDrive - Think Stack/github/terraform-modules/modules/aws/transit_gateway_attachment   dev_transit_gateway_module ±  terraform-docs markdown ./
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