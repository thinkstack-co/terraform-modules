# Azure Public IP Terraform Module

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
    <img src="/images/terraform_modules_logo.webp" alt="Logo" width="300" height="300">
  </a>

<h3 align="center">Azure Public IP Module</h3>
  <p align="center">
    This module creates an Azure Public IP address (the closest equivalent to an AWS Elastic IP).
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
    <li><a href="#notes">Notes</a></li>
    <li><a href="#license">License</a></li>
    <li><a href="#contact">Contact</a></li>
    <li><a href="#acknowledgments">Acknowledgments</a></li>
  </ol>
</details>

## Overview

This Terraform module provisions an Azure Public IP address using `azurerm_public_ip`.

In AWS, an Elastic IP is a static public IPv4 address that can be associated to certain resources. In Azure, the closest equivalent is a **Standard** SKU Public IP with **Static** allocation.

<p align="right">(<a href="#readme-top">back to top</a>)</p>

## Usage

### Basic Example

```hcl
module "resource_group" {
  source = "github.com/thinkstack-co/terraform-modules//modules/azure/terraform_modules/resource_group"

  name     = "rg-network"
  location = "eastus"
}

module "public_ip" {
  source = "github.com/thinkstack-co/terraform-modules//modules/azure/terraform_modules/public_ip"

  name                = "pip-nat-01"
  resource_group_name = module.resource_group.name
  location            = "eastus"

  tags = {
    terraform   = "true"
    created_by  = "Terraform"
    environment = "dev"
  }
}
```

### Example with DNS Label (FQDN)

```hcl
module "public_ip" {
  source = "github.com/thinkstack-co/terraform-modules//modules/azure/terraform_modules/public_ip"

  name                = "pip-app-01"
  resource_group_name = "rg-network"
  location            = "eastus"

  domain_name_label = "myapp-eastus-01"
}
```

<p align="right">(<a href="#readme-top">back to top</a>)</p>

## Requirements

| Name | Version |
|------|---------|
| terraform | >= 1.0.0 |
| azurerm | >= 3.0.0 |

## Providers

| Name | Version |
|------|---------|
| azurerm | >= 3.0.0 |

## Resources

| Name | Type | Documentation |
|------|------|--------------|
| [azurerm_public_ip](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/public_ip) | resource | [Azure Documentation](https://learn.microsoft.com/azure/virtual-network/ip-services/public-ip-addresses) |

<p align="right">(<a href="#readme-top">back to top</a>)</p>

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| name | Name of the Public IP resource | `string` | n/a | yes |
| resource_group_name | The name of an existing resource group | `string` | n/a | yes |
| location | The Azure region where resources will be created | `string` | `"eastus"` | no |
| sku | The SKU of the Public IP (Basic or Standard) | `string` | `"Standard"` | no |
| allocation_method | Allocation method (Static or Dynamic). Standard requires Static | `string` | `"Static"` | no |
| domain_name_label | Label for a DNS name to generate an FQDN | `string` | `null` | no |
| ip_version | The IP version (IPv4 or IPv6) | `string` | `"IPv4"` | no |
| zones | List of availability zones (empty means regional) | `list(string)` | `[]` | no |
| tags | A mapping of tags to assign to the resource | `map(string)` | `{ terraform = "true", created_by = "ThinkStack", environment = "prod", priority = "high" }` | no |

## Outputs

| Name | Description |
|------|-------------|
| id | The ID of the Public IP |
| name | The name of the Public IP |
| ip_address | The allocated public IP address |
| fqdn | The DNS FQDN assigned to the Public IP (if domain_name_label is set) |

<p align="right">(<a href="#readme-top">back to top</a>)</p>

## Notes

- **Azure vs AWS**: Azure Public IPs can be attached to different resources (e.g., NAT Gateway, Load Balancer frontend, Firewall). The module creates the IP only; association is done by the consuming module.
- **Standard SKU**: For production and for most "EIP-like" use cases, prefer `sku = "Standard"` with `allocation_method = "Static"`.

<p align="right">(<a href="#readme-top">back to top</a>)</p>

## License

Distributed under the MIT License. See `LICENSE.txt` for more information.

<p align="right">(<a href="#readme-top">back to top</a>)</p>

## Contact

Think|Stack - [![LinkedIn][linkedin-shield]][linkedin-url] - [info@thinkstack.co](mailto:info@thinkstack.co)

Project Link: [https://github.com/thinkstack-co/terraform-modules](https://github.com/thinkstack-co/terraform-modules)

<p align="right">(<a href="#readme-top">back to top</a>)</p>

## Acknowledgments

- [Wesley Bey](https://github.com/beywesley)
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
