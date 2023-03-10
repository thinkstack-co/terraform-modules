
<!-- Blank module readme template: Do a search and replace with your text editor for the following: `module_name`, `module_description` -->
<!-- Improved compatibility of back to top link: See: https://github.com/othneildrew/Best-README-Template/pull/73 -->
<a name="readme-top"></a>


<!-- PROJECT SHIELDS -->
<!--
*** I'm using markdown "reference style" links for readability.
*** Reference links are enclosed in brackets [ ] instead of parentheses ( ).
*** See the bottom of this document for the declaration of the reference variables
*** for contributors-url, forks-url, etc. This is an optional, concise syntax you may use.
*** https://www.markdownguide.org/basic-syntax/#reference-style-links
-->
[![Contributors][contributors-shield]][contributors-url]
[![Forks][forks-shield]][forks-url]
[![Stargazers][stars-shield]][stars-url]
[![Issues][issues-shield]][issues-url]
[![MIT License][license-shield]][license-url]
[![LinkedIn][linkedin-shield]][linkedin-url]


<!-- PROJECT LOGO -->
<br />
<div align="center">
  <a href="https://github.com/thinkstack-co/terraform-modules">
    <img src="/images/terraform_modules_logo.webp" alt="Logo" width="300" height="300">
  </a>

<h3 align="center">VPN Module</h3>
  <p align="center">
    This module creates a VPN tunnel to another endpoint utilizing best practices for security and encryption.
    <br />
    <a href="https://github.com/thinkstack-co/terraform-modules"><strong>Explore the docs »</strong></a>
    <br />
    <br />
    <a href="https://www.thinkstack.co/">Think|Stack</a>
    ·
    <a href="https://github.com/thinkstack-co/terraform-modules/issues">Report Bug</a>
    ·
    <a href="https://github.com/thinkstack-co/terraform-modules/issues">Request Feature</a>
  </p>
</div>


<!-- TABLE OF CONTENTS -->
<details>
  <summary>Table of Contents</summary>
  <ol>
    <li><a href="#usage">Usage</a></li>
    <li><a href="#requirements">Requirements</a></li>
    <li><a href="#providers">Providers</a></li>
    <li><a href="#modules">Modules</a></li>
    <li><a href="#Resources">Resources</a></li>
    <li><a href="#inputs">Inputs</a></li>
    <li><a href="#outputs">Outputs</a></li>
    <li><a href="#license">License</a></li>
    <li><a href="#contact">Contact</a></li>
    <li><a href="#acknowledgments">Acknowledgments</a></li>
  </ol>
</details>


<!-- USAGE EXAMPLES -->
## Usage
### Transit Gateway Attachment
```
module "hq_meraki_comcast" {
    source                            = "github.com/thinkstack-co/terraform-modules//modules/aws/vpn"

    enable_transit_gateway_attachment = true
    transit_gateway_id                = module.transit_gateway.id
    customer_gw_name                  = ["hq_meraki_comcast"]
    ip_address                        = ["8.8.8.8"]
    name                              = "hq_meraki_comcast"
    vpc_id                            = module.sdwan_vpc.vpc_id
}
```

### VPN Gateway Attachment
```
module "hq_meraki_comcast" {
    source                            = "github.com/thinkstack-co/terraform-modules//modules/aws/vpn"

    enable_transit_gateway_attachment = false
    customer_gw_name                  = ["hq_meraki_comcast"]
    ip_address                        = ["8.8.8.8"]
    name                              = "hq_meraki_comcast"
    vpc_id                            = module.sdwan_vpc.vpc_id
}
```

_For more examples, please refer to the [Documentation](https://github.com/thinkstack-co/terraform-modules)_

<p align="right">(<a href="#readme-top">back to top</a>)</p>

<!-- terraform-docs output will be input automatically below-->
<!-- terraform-docs markdown table --output-file README.md --output-mode inject .-->
<!-- BEGIN_TF_DOCS -->
## Requirements

| Name | Version |
|------|---------|
| <a name="requirement_terraform"></a> [terraform](#requirement\_terraform) | >= 1.0.0 |
| <a name="requirement_aws"></a> [aws](#requirement\_aws) | >= 4.0.0 |

## Providers

| Name | Version |
|------|---------|
| <a name="provider_aws"></a> [aws](#provider\_aws) | >= 4.0.0 |

## Modules

No modules.

## Resources

| Name | Type |
|------|------|
| [aws_customer_gateway.customer_gateway](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/customer_gateway) | resource |
| [aws_vpn_connection.vpn_connection_transit_gateway_attachment](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/vpn_connection) | resource |
| [aws_vpn_connection.vpn_connection_vpn_gateway_attachment](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/vpn_connection) | resource |
| [aws_vpn_gateway.vpn_gateway](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/vpn_gateway) | resource |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_amazon_side_asn"></a> [amazon\_side\_asn](#input\_amazon\_side\_asn) | (Optional) The Autonomous System Number (ASN) for the Amazon side of the gateway. If you don't specify an ASN, the virtual private gateway is created with the default ASN. | `number` | `null` | no |
| <a name="input_availability_zone"></a> [availability\_zone](#input\_availability\_zone) | (Optional) The Availability Zone for the virtual private gateway. | `string` | `null` | no |
| <a name="input_bgp_asn"></a> [bgp\_asn](#input\_bgp\_asn) | (Required) The gateway's Border Gateway Protocol (BGP) Autonomous System Number (ASN). | `number` | `65000` | no |
| <a name="input_certificate_arn"></a> [certificate\_arn](#input\_certificate\_arn) | (Optional) The Amazon Resource Name (ARN) for the customer gateway certificate. | `string` | `null` | no |
| <a name="input_customer_gw_name"></a> [customer\_gw\_name](#input\_customer\_gw\_name) | (Required) List of names to use for the customer gateways | `list(any)` | n/a | yes |
| <a name="input_enable_transit_gateway_attachment"></a> [enable\_transit\_gateway\_attachment](#input\_enable\_transit\_gateway\_attachment) | (Required) A boolean flag to enable/disable the use of a transit gateway attachment rather than VPN gateway attachment. Defaults false. | `bool` | `false` | no |
| <a name="input_ip_address"></a> [ip\_address](#input\_ip\_address) | (Required) The IPv4 address for the customer gateway device's outside interface. | `list(string)` | n/a | yes |
| <a name="input_name"></a> [name](#input\_name) | (Required) Name to be used on all the resources as identifier | `string` | n/a | yes |
| <a name="input_static_routes_only"></a> [static\_routes\_only](#input\_static\_routes\_only) | (Optional, Default true) Whether the VPN connection uses static routes exclusively. Static routes must be used for devices that don't support BGP. | `bool` | `true` | no |
| <a name="input_tags"></a> [tags](#input\_tags) | (Optional) A map of tags to assign to the resource. If configured with a provider default\_tags configuration block present, tags with matching keys will overwrite those defined at the provider-level. | `map(any)` | <pre>{<br>  "terraform": "true"<br>}</pre> | no |
| <a name="input_transit_gateway_id"></a> [transit\_gateway\_id](#input\_transit\_gateway\_id) | (Optional) The ID of the EC2 Transit Gateway. | `string` | `null` | no |
| <a name="input_tunnel_ike_versions"></a> [tunnel\_ike\_versions](#input\_tunnel\_ike\_versions) | (Optional) The IKE versions that are permitted for the first VPN tunnel. Valid values are ikev1 \| ikev2. | `list(string)` | <pre>[<br>  "ikev2"<br>]</pre> | no |
| <a name="input_tunnel_phase1_dh_group_numbers"></a> [tunnel\_phase1\_dh\_group\_numbers](#input\_tunnel\_phase1\_dh\_group\_numbers) | (Optional) List of one or more Diffie-Hellman group numbers that are permitted for the first VPN tunnel for phase 1 IKE negotiations. Valid values are 2 \| 14 \| 15 \| 16 \| 17 \| 18 \| 19 \| 20 \| 21 \| 22 \| 23 \| 24. | `list(string)` | <pre>[<br>  "14",<br>  "15",<br>  "16",<br>  "17",<br>  "18",<br>  "19",<br>  "20",<br>  "21",<br>  "22",<br>  "23",<br>  "24"<br>]</pre> | no |
| <a name="input_tunnel_phase1_encryption_algorithms"></a> [tunnel\_phase1\_encryption\_algorithms](#input\_tunnel\_phase1\_encryption\_algorithms) | (Optional) List of one or more encryption algorithms that are permitted for the first VPN tunnel for phase 1 IKE negotiations. Valid values are AES128 \| AES256 \| AES128-GCM-16 \| AES256-GCM-16. | `list(string)` | <pre>[<br>  "AES256",<br>  "AES256-GCM-16"<br>]</pre> | no |
| <a name="input_tunnel_phase1_integrity_algorithms"></a> [tunnel\_phase1\_integrity\_algorithms](#input\_tunnel\_phase1\_integrity\_algorithms) | (Optional) One or more integrity algorithms that are permitted for the first VPN tunnel for phase 1 IKE negotiations. Valid values are SHA1 \| SHA2-256 \| SHA2-384 \| SHA2-512. | `list(string)` | <pre>[<br>  "SHA2-256",<br>  "SHA2-384",<br>  "SHA2-512"<br>]</pre> | no |
| <a name="input_tunnel_phase2_dh_group_numbers"></a> [tunnel\_phase2\_dh\_group\_numbers](#input\_tunnel\_phase2\_dh\_group\_numbers) | (Optional) List of one or more Diffie-Hellman group numbers that are permitted for the first VPN tunnel for phase 2 IKE negotiations. Valid values are 2 \| 5 \| 14 \| 15 \| 16 \| 17 \| 18 \| 19 \| 20 \| 21 \| 22 \| 23 \| 24. | `list(string)` | <pre>[<br>  "14",<br>  "15",<br>  "16",<br>  "17",<br>  "18",<br>  "19",<br>  "20",<br>  "21",<br>  "22",<br>  "23",<br>  "24"<br>]</pre> | no |
| <a name="input_tunnel_phase2_encryption_algorithms"></a> [tunnel\_phase2\_encryption\_algorithms](#input\_tunnel\_phase2\_encryption\_algorithms) | (Optional) List of one or more encryption algorithms that are permitted for the first VPN tunnel for phase 2 IKE negotiations. Valid values are AES128 \| AES256 \| AES128-GCM-16 \| AES256-GCM-16. | `list(string)` | <pre>[<br>  "AES256",<br>  "AES256-GCM-16"<br>]</pre> | no |
| <a name="input_tunnel_phase2_integrity_algorithms"></a> [tunnel\_phase2\_integrity\_algorithms](#input\_tunnel\_phase2\_integrity\_algorithms) | (Optional) List of one or more integrity algorithms that are permitted for the first VPN tunnel for phase 2 IKE negotiations. Valid values are SHA1 \| SHA2-256 \| SHA2-384 \| SHA2-512. | `list(string)` | <pre>[<br>  "SHA2-256",<br>  "SHA2-384",<br>  "SHA2-512"<br>]</pre> | no |
| <a name="input_tunnel_startup_action"></a> [tunnel\_startup\_action](#input\_tunnel\_startup\_action) | (Optional, Default add) The action to take when the establishing the tunnel for the first VPN connection. By default, your customer gateway device must initiate the IKE negotiation and bring up the tunnel. Specify start for AWS to initiate the IKE negotiation. Valid values are add \| start. | `string` | `"add"` | no |
| <a name="input_vpc_id"></a> [vpc\_id](#input\_vpc\_id) | (Required) The VPC ID to create in. | `string` | n/a | yes |
| <a name="input_vpn_type"></a> [vpn\_type](#input\_vpn\_type) | (Required) The type of customer gateway. The only type AWS supports at this time is ipsec.1 | `string` | `"ipsec.1"` | no |

## Outputs

| Name | Description |
|------|-------------|
| <a name="output_customer_gateway_id"></a> [customer\_gateway\_id](#output\_customer\_gateway\_id) | n/a |
| <a name="output_customer_gateway_type"></a> [customer\_gateway\_type](#output\_customer\_gateway\_type) | n/a |
| <a name="output_vpn_gateway_id"></a> [vpn\_gateway\_id](#output\_vpn\_gateway\_id) | n/a |
<!-- END_TF_DOCS -->

<!-- LICENSE -->
## License

Distributed under the MIT License. See `LICENSE.txt` for more information.

<p align="right">(<a href="#readme-top">back to top</a>)</p>



<!-- CONTACT -->
## Contact

Think|Stack - [![LinkedIn][linkedin-shield]][linkedin-url] - info@thinkstack.co

Project Link: [https://github.com/thinkstack-co/terraform-modules](https://github.com/thinkstack-co/terraform-modules)

<p align="right">(<a href="#readme-top">back to top</a>)</p>



<!-- ACKNOWLEDGMENTS -->
## Acknowledgments

* [Zachary Hill](https://zacharyhill.co)
* [Jake Jones](https://github.com/jakeasarus)

<p align="right">(<a href="#readme-top">back to top</a>)</p>


<!-- MARKDOWN LINKS & IMAGES -->
<!-- https://www.markdownguide.org/basic-syntax/#reference-style-links -->
[contributors-shield]: https://img.shields.io/github/contributors/thinkstack-co/terraform-modules.svg?style=for-the-badge
[contributors-url]: https://github.com/thinkstack-co/terraform-modules/graphs/contributors
[forks-shield]: https://img.shields.io/github/forks/thinkstack-co/terraform-modules.svg?style=for-the-badge
[forks-url]: https://github.com/thinkstack-co/terraform-modules/network/members
[stars-shield]: https://img.shields.io/github/stars/thinkstack-co/terraform-modules.svg?style=for-the-badge
[stars-url]: https://github.com/thinkstack-co/terraform-modules/stargazers
[issues-shield]: https://img.shields.io/github/issues/thinkstack-co/terraform-modules.svg?style=for-the-badge
[issues-url]: https://github.com/thinkstack-co/terraform-modules/issues
[license-shield]: https://img.shields.io/github/license/thinkstack-co/terraform-modules.svg?style=for-the-badge
[license-url]: https://github.com/thinkstack-co/terraform-modules/blob/master/LICENSE.txt
[linkedin-shield]: https://img.shields.io/badge/-LinkedIn-black.svg?style=for-the-badge&logo=linkedin&colorB=555
[linkedin-url]: https://www.linkedin.com/company/thinkstack/
[product-screenshot]: /images/screenshot.webp
[Terraform.io]: https://img.shields.io/badge/Terraform-7B42BC?style=for-the-badge&logo=terraform
[Terraform-url]: https://terraform.io