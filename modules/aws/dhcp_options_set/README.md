# AWS DHCP Options Set Terraform Module

<a name="readme-top"></a>

<!-- PROJECT SHIELDS -->
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
    <img src="https://raw.githubusercontent.com/thinkstack-co/terraform-modules/main/images/thinkstack_logo.png" alt="ThinkStack Logo" width="300" height="100">
  </a>

<h3 align="center">AWS DHCP Options Set Module</h3>
  <p align="center">
    This module provisions and manages DHCP Options Sets in AWS VPCs.
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
    <li><a href="#overview">Overview</a></li>
    <li><a href="#usage">Usage</a></li>
    <li><a href="#requirements">Requirements</a></li>
    <li><a href="#providers">Providers</a></li>
    <li><a href="#resources">Resources</a></li>
    <li><a href="#inputs">Inputs</a></li>
    <li><a href="#outputs">Outputs</a></li>
    <li><a href="#license">License</a></li>
    <li><a href="#contact">Contact</a></li>
    <li><a href="#acknowledgments">Acknowledgments</a></li>
  </ol>
</details>

## Overview

This Terraform module creates and manages AWS DHCP Options Sets. DHCP Options Sets allow you to configure DNS settings, domain names, and NTP servers for your VPC, providing centralized network configuration for EC2 instances.

The module supports:
- Custom domain names
- DNS server configuration
- NTP server configuration
- Association with a specific VPC
- Resource tagging

<p align="right">(<a href="#readme-top">back to top</a>)</p>

<!-- USAGE EXAMPLES -->
## Usage

### Basic Example

```hcl
module "dhcp_options_set" {
  source = "github.com/thinkstack-co/terraform-modules//modules/aws/dhcp_options_set"

  domain_name         = "example.internal"
  domain_name_servers = ["10.0.0.2", "10.0.0.3"]
  vpc_id              = module.vpc.vpc_id
  tags                = {
    terraform   = "true"
    created_by  = "Terraform"
    environment = "production"
  }
}
```

### With NTP Servers

```hcl
module "dhcp_options_set" {
  source = "github.com/thinkstack-co/terraform-modules//modules/aws/dhcp_options_set"

  domain_name         = "corp.example.com"
  domain_name_servers = ["10.0.0.2", "10.0.0.3"]
  ntp_servers         = ["10.0.0.4", "10.0.0.5"]
  vpc_id              = module.vpc.vpc_id
  tags                = {
    terraform   = "true"
    created_by  = "Terraform"
    environment = "production"
    Name        = "corp_dhcp_options_set"
  }
}
```

### Argument Reference

* `domain_name` - (Optional) The domain name for the DHCP Options Set.
* `domain_name_servers` - (Optional) A list of DNS server IP addresses.
* `ntp_servers` - (Optional) A list of NTP server IP addresses.
* `vpc_id` - (Required) The ID of the VPC to associate the DHCP Options Set with.
* `enable_dhcp_options` - (Optional) Boolean to determine if DHCP options are enabled. Default is `true`.
* `tags` - (Optional) A map of tags to assign to the DHCP Options Set.

<p align="right">(<a href="#readme-top">back to top</a>)</p>

<!-- REQUIREMENTS -->
## Requirements

| Name | Version |
|------|---------|
| terraform | >= 1.0.0 |
| aws | >= 4.0.0 |

## Providers

| Name | Version |
|------|---------|
| aws | >= 4.0.0 |

## Resources

| Name | Type | Documentation |
|------|------|--------------|
| [aws_vpc_dhcp_options.dc_dns](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/vpc_dhcp_options) | resource | [AWS Documentation](https://docs.aws.amazon.com/vpc/latest/userguide/VPC_DHCP_Options.html) |
| [aws_vpc_dhcp_options_association.dc_dns](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/vpc_dhcp_options_association) | resource | [AWS Documentation](https://docs.aws.amazon.com/vpc/latest/userguide/VPC_DHCP_Options.html) |

<p align="right">(<a href="#readme-top">back to top</a>)</p>

<!-- INPUTS -->
## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| domain_name | Define the domain name for the DHCP Options Set | `string` | `null` | no |
| domain_name_servers | List of IP addresses for the DNS servers | `list(string)` | `["10.11.1.100", "10.11.2.100"]` | no |
| enable_dhcp_options | (Optional) boolean to determine if DHCP options are enabled | `bool` | `true` | no |
| ntp_servers | List of IP addresses for the NTP servers | `list(string)` | `["10.11.1.100", "10.11.2.100"]` | no |
| tags | (Optional) A mapping of tags to assign to the object | `map` | `{"Name": "prod_dhcp_options_set", "created_by": "ThinkStack", "description": "DHCP Option Set for the VPC", "environment": "prod", "terraform": "true"}` | no |
| vpc_id | ID of the VPC to attach the DHCP Options Set to | `string` | `null` | yes |

## Outputs

| Name | Description |
|------|-------------|
| dhcp_options_id | The ID of the DHCP Options Set |

<p align="right">(<a href="#readme-top">back to top</a>)</p>

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

* [Wesley Bey](https://github.com/beywesley)
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