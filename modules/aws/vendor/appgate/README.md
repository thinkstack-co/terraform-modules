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

| Name                                                                        | Version  |
| --------------------------------------------------------------------------- | -------- |
| <a name="requirement_terraform"></a> [terraform](#requirement_terraform)    | >= 1.5.0 |
| <a name="requirement_aws"></a> [aws](#requirement_aws)                      | >= 5.0   |
| <a name="requirement_appgatesdp"></a> [appgatesdp](#requirement_appgatesdp) | >= 2.0   |

## Providers

| Name                                                                  | Version |
| --------------------------------------------------------------------- | ------- |
| <a name="provider_aws"></a> [aws](#provider_aws)                      | >= 5.0  |
| <a name="provider_appgatesdp"></a> [appgatesdp](#provider_appgatesdp) | >= 2.0  |

## Modules

No modules.

## Resources

| Name                                                                                                                                                              | Type     |
| ----------------------------------------------------------------------------------------------------------------------------------------------------------------- | -------- |
| [aws_security_group.this](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/security_group)                                             | resource |
| [aws_vpc_security_group_ingress_rule.https](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/vpc_security_group_ingress_rule)          | resource |
| [aws_vpc_security_group_ingress_rule.dtls](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/vpc_security_group_ingress_rule)           | resource |
| [aws_vpc_security_group_ingress_rule.dns](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/vpc_security_group_ingress_rule)            | resource |
| [aws_vpc_security_group_ingress_rule.ssh_netcov](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/vpc_security_group_ingress_rule)     | resource |
| [aws_vpc_security_group_ingress_rule.admin_netcov](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/vpc_security_group_ingress_rule)   | resource |
| [aws_vpc_security_group_ingress_rule.ssh_engineer](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/vpc_security_group_ingress_rule)   | resource |
| [aws_vpc_security_group_ingress_rule.admin_engineer](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/vpc_security_group_ingress_rule) | resource |
| [aws_vpc_security_group_egress_rule.all](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/vpc_security_group_egress_rule)              | resource |
| [aws_network_interface.this](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/network_interface)                                       | resource |
| [aws_network_interface_attachment.this](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/network_interface_attachment)                 | resource |
| [aws_eip.this](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/eip)                                                                   | resource |
| [aws_eip_association.this](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/eip_association)                                           | resource |
| [aws_instance.this](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/instance)                                                         | resource |
| [appgatesdp_appliance.this](https://registry.terraform.io/providers/appgate/appgatesdp/latest/docs/resources/appliance)                                           | resource |
| [terraform_data.seed](https://registry.terraform.io/providers/hashicorp/terraform/latest/docs/resources/terraform_data)                                           | resource |

## Inputs

| Name                                                                                                      | Description                                                                                                      | Type                                                   | Default                                                                                           | Required |
| --------------------------------------------------------------------------------------------------------- | ---------------------------------------------------------------------------------------------------------------- | ------------------------------------------------------ | ------------------------------------------------------------------------------------------------- | :------: |
| <a name="input_client_abbreviation"></a> [client_abbreviation](#input_client_abbreviation)                | Client abbreviation for naming (e.g., 'nc', 'dcc'). Must be 2-10 alphanumeric characters starting with a letter. | `string`                                               | n/a                                                                                               |   yes    |
| <a name="input_customer_name"></a> [customer_name](#input_customer_name)                                  | Full customer name for Appgate labels (e.g., 'Dubin Clark')                                                      | `string`                                               | n/a                                                                                               |   yes    |
| <a name="input_vpc_id"></a> [vpc_id](#input_vpc_id)                                                       | VPC ID from the customer's VPC module                                                                            | `string`                                               | n/a                                                                                               |   yes    |
| <a name="input_subnet_id"></a> [subnet_id](#input_subnet_id)                                              | Public subnet ID for the gateway                                                                                 | `string`                                               | n/a                                                                                               |   yes    |
| <a name="input_key_pair_name"></a> [key_pair_name](#input_key_pair_name)                                  | Existing AWS key pair name in the customer environment                                                           | `string`                                               | n/a                                                                                               |   yes    |
| <a name="input_gateway_index"></a> [gateway_index](#input_gateway_index)                                  | Gateway number (1 = AGGW01, 2 = AGGW02, etc.). Must be 1-99.                                                     | `number`                                               | `1`                                                                                               |    no    |
| <a name="input_vpc_identifier"></a> [vpc_identifier](#input_vpc_identifier)                               | VPC label for SG naming (e.g., 'vpc01')                                                                          | `string`                                               | `"vpc01"`                                                                                         |    no    |
| <a name="input_subnet_index"></a> [subnet_index](#input_subnet_index)                                     | Subnet number for ENI naming                                                                                     | `number`                                               | `1`                                                                                               |    no    |
| <a name="input_netcov_appgate_ip"></a> [netcov_appgate_ip](#input_netcov_appgate_ip)                      | NetCov management IPv4 address for SSH + 8443. The /32 CIDR suffix is appended automatically.                    | `string`                                               | `"3.138.92.59"`                                                                                   |    no    |
| <a name="input_additional_admin_cidrs"></a> [additional_admin_cidrs](#input_additional_admin_cidrs)       | Engineer IPs for SSH + 8443. Key = name, value = x.x.x.x/32                                                      | `map(string)`                                          | `{ "netcov_1" = "3.138.92.59/32", "netcov_2" = "3.83.5.218/32", "netcov_3" = "50.18.17.253/32" }` |    no    |
| <a name="input_instance_type"></a> [instance_type](#input_instance_type)                                  | Instance type per Appgate sizing guide. t3.medium for <500 users.                                                | `string`                                               | `"t3.medium"`                                                                                     |    no    |
| <a name="input_ami_id"></a> [ami_id](#input_ami_id)                                                       | Explicit AMI ID. Null = auto-discover latest Appgate SDP BYOL.                                                   | `string`                                               | `null`                                                                                            |    no    |
| <a name="input_root_volume_size"></a> [root_volume_size](#input_root_volume_size)                         | Root volume GiB                                                                                                  | `number`                                               | `100`                                                                                             |    no    |
| <a name="input_root_volume_iops"></a> [root_volume_iops](#input_root_volume_iops)                         | gp3 IOPS                                                                                                         | `number`                                               | `3000`                                                                                            |    no    |
| <a name="input_root_volume_throughput"></a> [root_volume_throughput](#input_root_volume_throughput)       | gp3 throughput MiB/s                                                                                             | `number`                                               | `125`                                                                                             |    no    |
| <a name="input_kms_key_id"></a> [kms_key_id](#input_kms_key_id)                                           | KMS key for EBS encryption. Null = default aws/ebs.                                                              | `string`                                               | `null`                                                                                            |    no    |
| <a name="input_map_migrated_value"></a> [map_migrated_value](#input_map_migrated_value)                   | MAP tracking tag                                                                                                 | `string`                                               | `"d-server-03jpm34ivsp1f1"`                                                                       |    no    |
| <a name="input_additional_tags"></a> [additional_tags](#input_additional_tags)                            | Extra tags applied to all resources                                                                              | `map(string)`                                          | `{}`                                                                                              |    no    |
| <a name="input_manage_appgate_appliance"></a> [manage_appgate_appliance](#input_manage_appgate_appliance) | Register this gateway in the Appgate controller                                                                  | `bool`                                                 | `false`                                                                                           |    no    |
| <a name="input_appgate_site_id"></a> [appgate_site_id](#input_appgate_site_id)                            | Appgate Site ID for this gateway                                                                                 | `string`                                               | `null`                                                                                            |    no    |
| <a name="input_tunnel_destinations"></a> [tunnel_destinations](#input_tunnel_destinations)                | Subnets reachable through the gateway tunnel                                                                     | `list(object({ address = string, netmask = number }))` | `[]`                                                                                              |    no    |
| <a name="input_appgate_tags"></a> [appgate_tags](#input_appgate_tags)                                     | Appgate appliance tags                                                                                           | `list(string)`                                         | `["autoscale"]`                                                                                   |    no    |
| <a name="input_appgate_seed_json"></a> [appgate_seed_json](#input_appgate_seed_json)                      | Seed JSON from Appgate controller. Null = skip auto-seeding.                                                     | `string`                                               | `null`                                                                                            |    no    |
| <a name="input_private_key_pem"></a> [private_key_pem](#input_private_key_pem)                            | PEM key for SSH seed provisioning. Must match key_pair_name.                                                     | `string`                                               | `null`                                                                                            |    no    |

## Outputs

| Name                                                                                                        | Description                                |
| ----------------------------------------------------------------------------------------------------------- | ------------------------------------------ |
| <a name="output_instance_id"></a> [instance_id](#output_instance_id)                                        | EC2 instance ID                            |
| <a name="output_instance_name"></a> [instance_name](#output_instance_name)                                  | Instance Name tag                          |
| <a name="output_public_ip"></a> [public_ip](#output_public_ip)                                              | Elastic IP — Appgate appliance hostname    |
| <a name="output_private_ip"></a> [private_ip](#output_private_ip)                                           | Private IP of the gateway ENI              |
| <a name="output_security_group_id"></a> [security_group_id](#output_security_group_id)                      | Appgate security group ID                  |
| <a name="output_network_interface_id"></a> [network_interface_id](#output_network_interface_id)             | ENI ID                                     |
| <a name="output_elastic_ip_allocation_id"></a> [elastic_ip_allocation_id](#output_elastic_ip_allocation_id) | EIP allocation ID                          |
| <a name="output_ami_id"></a> [ami_id](#output_ami_id)                                                       | AMI used                                   |
| <a name="output_appgate_appliance_id"></a> [appgate_appliance_id](#output_appgate_appliance_id)             | Appgate appliance ID (null if not managed) |
| <a name="output_it_glue_config"></a> [it_glue_config](#output_it_glue_config)                               | IT Glue configuration entry data           |

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

- [Zachary Hill](https://zacharyhill.co)
- [Jake Jones](https://github.com/jakeasarus)

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
