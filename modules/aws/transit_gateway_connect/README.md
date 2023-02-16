# Usage
    module "transit_gateway_sdwan_connect" {
        source                  = "github.com/thinkstack-co/terraform-modules//modules/aws/transit_gateway_connect"

        name                    = "tgw_sdwan_connect"
        transport_attachment_id = module.prod_vpc_attachment.id
        transit_gateway_id      = module.transit_gateway.id
    }

<!-- BEGIN_TF_DOCS -->
## Requirements

No requirements.

## Providers

| Name | Version |
|------|---------|
| <a name="provider_aws"></a> [aws](#provider\_aws) | n/a |

## Modules

No modules.

## Resources

| Name | Type |
|------|------|
| [aws_ec2_transit_gateway_connect.connect_attachment](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/ec2_transit_gateway_connect) | resource |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_name"></a> [name](#input\_name) | (Required) The name of the transit gateway | `string` | n/a | yes |
| <a name="input_protocol"></a> [protocol](#input\_protocol) | (Optional) The tunnel protocol. Valida values: gre. Default is gre. | `string` | `"gre"` | no |
| <a name="input_tags"></a> [tags](#input\_tags) | (Optional) Key-value tags for the EC2 Transit Gateway Connect. If configured with a provider default\_tags configuration block present, tags with matching keys will overwrite those defined at the provider-level. | `map` | <pre>{<br>  "environment": "prod",<br>  "project": "core_infrastructure",<br>  "terraform": "true"<br>}</pre> | no |
| <a name="input_transit_gateway_default_route_table_association"></a> [transit\_gateway\_default\_route\_table\_association](#input\_transit\_gateway\_default\_route\_table\_association) | (Optional) Boolean whether the Connect should be associated with the EC2 Transit Gateway association default route table. This cannot be configured or perform drift detection with Resource Access Manager shared EC2 Transit Gateways. Default value: true. | `bool` | `true` | no |
| <a name="input_transit_gateway_default_route_table_propagation"></a> [transit\_gateway\_default\_route\_table\_propagation](#input\_transit\_gateway\_default\_route\_table\_propagation) | (Optional) Boolean whether the Connect should propagate routes with the EC2 Transit Gateway propagation default route table. This cannot be configured or perform drift detection with Resource Access Manager shared EC2 Transit Gateways. Default value: true. | `bool` | `true` | no |
| <a name="input_transit_gateway_id"></a> [transit\_gateway\_id](#input\_transit\_gateway\_id) | (Required) Identifier of EC2 Transit Gateway. | `string` | n/a | yes |
| <a name="input_transport_attachment_id"></a> [transport\_attachment\_id](#input\_transport\_attachment\_id) | (Required) The underlaying VPC attachment | `string` | n/a | yes |

## Outputs

| Name | Description |
|------|-------------|
| <a name="output_id"></a> [id](#output\_id) | n/a |
<!-- END_TF_DOCS -->