# Usage
    module "transit_gateway" {
        source = "github.com/thinkstack-co/terraform-modules//modules/aws/transit_gateway"

        name = "sdwan_tgw"
    }

<!-- BEGIN_TF_DOCS -->
## Requirements

| Name | Version |
|------|---------|
| <a name="requirement_terraform"></a> [terraform](#requirement\_terraform) | >= 1.0.0 |

## Providers

| Name | Version |
|------|---------|
| <a name="provider_aws"></a> [aws](#provider\_aws) | n/a |

## Modules

No modules.

## Resources

| Name | Type |
|------|------|
| [aws_ec2_transit_gateway.transit_gateway](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/ec2_transit_gateway) | resource |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_amazon_side_asn"></a> [amazon\_side\_asn](#input\_amazon\_side\_asn) | (Optional) Private Autonomous System Number (ASN) for the Amazon side of a BGP session. | `string` | `"64525"` | no |
| <a name="input_auto_accept_shared_attachments"></a> [auto\_accept\_shared\_attachments](#input\_auto\_accept\_shared\_attachments) | (Optional) Whether resource attachment requests are automatically accepted. | `string` | `"disable"` | no |
| <a name="input_default_route_table_association"></a> [default\_route\_table\_association](#input\_default\_route\_table\_association) | (Optional) Whether resource attachments are automatically associated with the default association route table. | `string` | `"enable"` | no |
| <a name="input_default_route_table_propagation"></a> [default\_route\_table\_propagation](#input\_default\_route\_table\_propagation) | (Optional) Whether resource attachments automatically propagate routes to the default propagation route table. | `string` | `"enable"` | no |
| <a name="input_description"></a> [description](#input\_description) | (Optional) Description of the EC2 Transit Gateway. | `string` | `"Transit gateway to allow access across VPCs or accounts."` | no |
| <a name="input_dns_support"></a> [dns\_support](#input\_dns\_support) | (Optional) Whether DNS support is enabled. | `string` | `"enable"` | no |
| <a name="input_name"></a> [name](#input\_name) | (Required) The name of the transit gateway | `string` | n/a | yes |
| <a name="input_tags"></a> [tags](#input\_tags) | (Optional) Map of tags for the EC2 Transit Gateway. | `map` | <pre>{<br>  "environment": "prod",<br>  "project": "core_infrastructure",<br>  "terraform": "true"<br>}</pre> | no |
| <a name="input_transit_gateway_cidr_blocks"></a> [transit\_gateway\_cidr\_blocks](#input\_transit\_gateway\_cidr\_blocks) | (Optional) One or more IPv4 or IPv6 CIDR blocks for the transit gateway. Must be a size /24 CIDR block or larger for IPv4, or a size /64 CIDR block or larger for IPv6. | `list(string)` | `null` | no |
| <a name="input_vpn_ecmp_support"></a> [vpn\_ecmp\_support](#input\_vpn\_ecmp\_support) | (Optional) Whether VPN Equal Cost Multipath Protocol support is enabled. | `string` | `"enable"` | no |

## Outputs

| Name | Description |
|------|-------------|
| <a name="output_arn"></a> [arn](#output\_arn) | n/a |
| <a name="output_association_default_route_table_id"></a> [association\_default\_route\_table\_id](#output\_association\_default\_route\_table\_id) | n/a |
| <a name="output_id"></a> [id](#output\_id) | n/a |
| <a name="output_propagation_default_route_table_id"></a> [propagation\_default\_route\_table\_id](#output\_propagation\_default\_route\_table\_id) | n/a |
<!-- END_TF_DOCS -->