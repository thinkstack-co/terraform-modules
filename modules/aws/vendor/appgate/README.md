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

<h3 align="center">Appgate SDP AWS Gateway Module</h3>
  <p align="center">
    This module deploys a complete Appgate SDP Zero Trust Network Access (ZTNA) gateway into a customer's existing AWS environment in a single module call. It covers the full NetCov "Appgate - AWS Gateway(s) Setup & Configuration" runbook.
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

```
module "appgate_gateway" {
    source = "github.com/thinkstack-co/terraform-modules//modules/aws/vendor/appgate"

    # Customer Environment
    client_abbreviation = "dcc"
    customer_name       = "Dubin Clark"
    vpc_id              = module.vpc.vpc_id
    subnet_id           = module.vpc.public_subnet_ids[0]
    key_pair_name       = "dcc-keypair"

    # Optional - Appgate Controller Registration
    manage_appgate_appliance = true
    appgate_site_id          = "site-id-from-controller"
    tunnel_destinations = [
        {
            address = "10.0.1.0"
            netmask = 24
        },
        {
            address = "10.0.2.0"
            netmask = 24
        }
    ]

    # Optional - Seed Provisioning
    appgate_seed_json = var.appgate_seed_json
    private_key_pem   = var.private_key_pem
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
| <a name="requirement_terraform"></a> [terraform](#requirement\_terraform) | >= 1.5.0 |
| <a name="requirement_aws"></a> [aws](#requirement\_aws) | >= 5.0 |
| <a name="requirement_appgatesdp"></a> [appgatesdp](#requirement\_appgatesdp) | >= 2.0 |

## Providers

| Name | Version |
|------|---------|
| <a name="provider_aws"></a> [aws](#provider\_aws) | >= 5.0 |
| <a name="provider_appgatesdp"></a> [appgatesdp](#provider\_appgatesdp) | >= 2.0 |

## Modules

No modules.

## Resources

| Name | Type |
|------|------|
| [aws_security_group.this](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/security_group) | resource |
| [aws_vpc_security_group_ingress_rule.https](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/vpc_security_group_ingress_rule) | resource |
| [aws_vpc_security_group_ingress_rule.dtls](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/vpc_security_group_ingress_rule) | resource |
| [aws_vpc_security_group_ingress_rule.dns](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/vpc_security_group_ingress_rule) | resource |
| [aws_vpc_security_group_ingress_rule.ssh_netcov](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/vpc_security_group_ingress_rule) | resource |
| [aws_vpc_security_group_ingress_rule.admin_netcov](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/vpc_security_group_ingress_rule) | resource |
| [aws_vpc_security_group_ingress_rule.ssh_engineer](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/vpc_security_group_ingress_rule) | resource |
| [aws_vpc_security_group_ingress_rule.admin_engineer](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/vpc_security_group_ingress_rule) | resource |
| [aws_vpc_security_group_egress_rule.all](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/vpc_security_group_egress_rule) | resource |
| [aws_network_interface.this](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/network_interface) | resource |
| [aws_network_interface_attachment.this](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/network_interface_attachment) | resource |
| [aws_eip.this](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/eip) | resource |
| [aws_eip_association.this](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/eip_association) | resource |
| [aws_instance.this](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/instance) | resource |
| [appgatesdp_appliance.this](https://registry.terraform.io/providers/appgate/appgatesdp/latest/docs/resources/appliance) | resource |
| [terraform_data.seed](https://registry.terraform.io/providers/hashicorp/terraform/latest/docs/resources/terraform_data) | resource |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_client_abbreviation"></a> [client\_abbreviation](#input\_client\_abbreviation) | Client abbreviation for naming (e.g., 'nc', 'dcc'). Must be 2-10 alphanumeric characters starting with a letter. | `string` | n/a | yes |
| <a name="input_customer_name"></a> [customer\_name](#input\_customer\_name) | Full customer name for Appgate labels (e.g., 'Dubin Clark') | `string` | n/a | yes |
| <a name="input_vpc_id"></a> [vpc\_id](#input\_vpc\_id) | VPC ID from the customer's VPC module | `string` | n/a | yes |
| <a name="input_subnet_id"></a> [subnet\_id](#input\_subnet\_id) | Public subnet ID for the gateway | `string` | n/a | yes |
| <a name="input_key_pair_name"></a> [key\_pair\_name](#input\_key\_pair\_name) | Existing AWS key pair name in the customer environment | `string` | n/a | yes |
| <a name="input_gateway_index"></a> [gateway\_index](#input\_gateway\_index) | Gateway number (1 = AGGW01, 2 = AGGW02, etc.). Must be 1-99. | `number` | `1` | no |
| <a name="input_vpc_identifier"></a> [vpc\_identifier](#input\_vpc\_identifier) | VPC label for SG naming (e.g., 'vpc01') | `string` | `"vpc01"` | no |
| <a name="input_subnet_index"></a> [subnet\_index](#input\_subnet\_index) | Subnet number for ENI naming | `number` | `1` | no |
| <a name="input_netcov_appgate_ip"></a> [netcov\_appgate\_ip](#input\_netcov\_appgate\_ip) | NetCov management IPv4 address for SSH + 8443. The /32 CIDR suffix is appended automatically. | `string` | `"3.138.92.59"` | no |
| <a name="input_additional_admin_cidrs"></a> [additional\_admin\_cidrs](#input\_additional\_admin\_cidrs) | Engineer IPs for SSH + 8443. Key = name, value = x.x.x.x/32 | `map(string)` | `{ "netcov_1" = "3.138.92.59/32", "netcov_2" = "3.83.5.218/32", "netcov_3" = "50.18.17.253/32" }` | no |
| <a name="input_instance_type"></a> [instance\_type](#input\_instance\_type) | Instance type per Appgate sizing guide. t3.medium for <500 users. | `string` | `"t3.medium"` | no |
| <a name="input_ami_id"></a> [ami\_id](#input\_ami\_id) | Explicit AMI ID. Null = auto-discover latest Appgate SDP BYOL. | `string` | `null` | no |
| <a name="input_root_volume_size"></a> [root\_volume\_size](#input\_root\_volume\_size) | Root volume GiB | `number` | `100` | no |
| <a name="input_root_volume_iops"></a> [root\_volume\_iops](#input\_root\_volume\_iops) | gp3 IOPS | `number` | `3000` | no |
| <a name="input_root_volume_throughput"></a> [root\_volume\_throughput](#input\_root\_volume\_throughput) | gp3 throughput MiB/s | `number` | `125` | no |
| <a name="input_kms_key_id"></a> [kms\_key\_id](#input\_kms\_key\_id) | KMS key for EBS encryption. Null = default aws/ebs. | `string` | `null` | no |
| <a name="input_map_migrated_value"></a> [map\_migrated\_value](#input\_map\_migrated\_value) | MAP tracking tag | `string` | `"d-server-03jpm34ivsp1f1"` | no |
| <a name="input_additional_tags"></a> [additional\_tags](#input\_additional\_tags) | Extra tags applied to all resources | `map(string)` | `{}` | no |
| <a name="input_manage_appgate_appliance"></a> [manage\_appgate\_appliance](#input\_manage\_appgate\_appliance) | Register this gateway in the Appgate controller | `bool` | `false` | no |
| <a name="input_appgate_site_id"></a> [appgate\_site\_id](#input\_appgate\_site\_id) | Appgate Site ID for this gateway | `string` | `null` | no |
| <a name="input_tunnel_destinations"></a> [tunnel\_destinations](#input\_tunnel\_destinations) | Subnets reachable through the gateway tunnel | `list(object({ address = string, netmask = number }))` | `[]` | no |
| <a name="input_appgate_tags"></a> [appgate\_tags](#input\_appgate\_tags) | Appgate appliance tags | `list(string)` | `["autoscale"]` | no |
| <a name="input_appgate_seed_json"></a> [appgate\_seed\_json](#input\_appgate\_seed\_json) | Seed JSON from Appgate controller. Null = skip auto-seeding. | `string` | `null` | no |
| <a name="input_private_key_pem"></a> [private\_key\_pem](#input\_private\_key\_pem) | PEM key for SSH seed provisioning. Must match key_pair_name. | `string` | `null` | no |

## Outputs

| Name | Description |
|------|-------------|
| <a name="output_instance_id"></a> [instance\_id](#output\_instance\_id) | EC2 instance ID |
| <a name="output_instance_name"></a> [instance\_name](#output\_instance\_name) | Instance Name tag |
| <a name="output_public_ip"></a> [public\_ip](#output\_public\_ip) | Elastic IP — Appgate appliance hostname |
| <a name="output_private_ip"></a> [private\_ip](#output\_private\_ip) | Private IP of the gateway ENI |
| <a name="output_security_group_id"></a> [security\_group\_id](#output\_security\_group\_id) | Appgate security group ID |
| <a name="output_network_interface_id"></a> [network\_interface\_id](#output\_network\_interface\_id) | ENI ID |
| <a name="output_elastic_ip_allocation_id"></a> [elastic\_ip\_allocation\_id](#output\_elastic\_ip\_allocation\_id) | EIP allocation ID |
| <a name="output_ami_id"></a> [ami\_id](#output\_ami\_id) | AMI used |
| <a name="output_appgate_appliance_id"></a> [appgate\_appliance\_id](#output\_appgate\_appliance\_id) | Appgate appliance ID (null if not managed) |
| <a name="output_it_glue_config"></a> [it\_glue\_config](#output\_it\_glue\_config) | IT Glue configuration entry data |
<!-- END_TF_DOCS -->

<!-- LICENSE -->
## License

Distributed under the MIT License. See `LICENSE.txt` for more information.

<p align="right">(<a href="#readme-top">back to top</a>)</p>

<!-- CONTACT -->
## Contact

Think|Stack - [![LinkedIn][linkedin-shield]][linkedin-url] - <info@thinkstack.co>

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
