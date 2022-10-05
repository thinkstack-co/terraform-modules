# Usage
    module "transit_gateway_sdwan_connect_peer" {
        source                        = "github.com/thinkstack-co/terraform-modules//modules/aws/transit_gateway_connect_peer"

        bgp_asn                       = 64513
        inside_cidr_blocks            = "169.254.6.0/29"
        name                          = "sdwan_peer"
        peer_address                  = "10.100.1.10"
        transit_gateway_address       = "10.255.1.11"
        transit_gateway_attachment_id = module.transit_gateway_sdwan_connect.id
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
| [aws_ec2_transit_gateway_connect_peer.peer](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/ec2_transit_gateway_connect_peer) | resource |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_bgp_asn"></a> [bgp\_asn](#input\_bgp\_asn) | (Optional) The BGP ASN number assigned customer device. If not provided, it will use the same BGP ASN as is associated with Transit Gateway. | `number` | `64512` | no |
| <a name="input_inside_cidr_blocks"></a> [inside\_cidr\_blocks](#input\_inside\_cidr\_blocks) | (Required) The CIDR block that will be used for addressing within the tunnel. It must contain exactly one IPv4 CIDR block and up to one IPv6 CIDR block. The IPv4 CIDR block must be /29 size and must be within 169.254.0.0/16 range, with exception of: 169.254.0.0/29, 169.254.1.0/29, 169.254.2.0/29, 169.254.3.0/29, 169.254.4.0/29, 169.254.5.0/29, 169.254.169.248/29. The IPv6 CIDR block must be /125 size and must be within fd00::/8. The first IP from each CIDR block is assigned for customer gateway, the second and third is for Transit Gateway (An example: from range 169.254.100.0/29, .1 is assigned to customer gateway and .2 and .3 are assigned to Transit Gateway) | `string` | n/a | yes |
| <a name="input_name"></a> [name](#input\_name) | (Required) The name of the transit gateway | `string` | n/a | yes |
| <a name="input_peer_address"></a> [peer\_address](#input\_peer\_address) | (Required) The IP addressed assigned to customer device, which will be used as tunnel endpoint. It can be IPv4 or IPv6 address, but must be the same address family as transit\_gateway\_address | `string` | n/a | yes |
| <a name="input_tags"></a> [tags](#input\_tags) | (Optional) Key-value tags for the EC2 Transit Gateway Connect. If configured with a provider default\_tags configuration block present, tags with matching keys will overwrite those defined at the provider-level. | `map` | <pre>{<br>  "environment": "prod",<br>  "project": "core_infrastructure",<br>  "terraform": "true"<br>}</pre> | no |
| <a name="input_transit_gateway_address"></a> [transit\_gateway\_address](#input\_transit\_gateway\_address) | (Required) The IP address assigned to Transit Gateway, which will be used as tunnel endpoint. This address must be from associated Transit Gateway CIDR block. The address must be from the same address family as peer\_address. If not set explicitly, it will be selected from associated Transit Gateway CIDR blocks | `string` | n/a | yes |
| <a name="input_transit_gateway_attachment_id"></a> [transit\_gateway\_attachment\_id](#input\_transit\_gateway\_attachment\_id) | (Required) The Transit Gateway Connect | `string` | n/a | yes |

## Outputs

| Name | Description |
|------|-------------|
| <a name="output_id"></a> [id](#output\_id) | n/a |
<!-- END_TF_DOCS -->