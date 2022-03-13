# Usage
    module "transit_gateway" {
        source = "github.com/thinkstack-co/terraform-modules//modules/aws/transit_gateway"

        name = "sdwan_tgw"
    }

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
| name | (Required) The name of the transit gateway | `string` | n/a | yes |
| tags | (Optional) Map of tags for the EC2 Transit Gateway. | `map` | <pre>{<br>  "environment": "prod",<br>  "project": "core_infrastructure",<br>  "terraform": "true"<br>}</pre> | no |
| vpn\_ecmp\_support | (Optional) Whether VPN Equal Cost Multipath Protocol support is enabled. | `string` | `"enable"` | no |

## Outputs

| Name | Description |
|------|-------------|
| arn | EC2 Transit Gateway Amazon Resource Name (ARN) |
| association_default_route_table_id | Identifier of the default association route table |
| id | EC2 Transit Gateway identifier |
| propagation\_default\_route\_table\_id | Identifier of the default propagation route table |