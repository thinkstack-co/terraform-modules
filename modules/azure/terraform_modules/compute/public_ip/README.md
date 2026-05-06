# Azure Public IP Terraform Module (Compute Wrapper)

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
    This module is a compute wrapper for the networking/public_ip module to keep the public IP available in compute context.
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

This wrapper module delegates to `networking/public_ip` and exposes the same interface for compute-related use cases.

<p align="right">(<a href="#readme-top">back to top</a>)</p>

## Usage

```hcl
module "public_ip" {
  source = "github.com/thinkstack-co/terraform-modules//modules/azure/terraform_modules/compute/public_ip"

  name                = "pip-web-01"
  resource_group_name = "rg-network"
  location            = "eastus"
}
```

<p align="right">(<a href="#readme-top">back to top</a>)</p>

## Requirements

| Name      | Version  |
| --------- | -------- |
| terraform | >= 1.0.0 |
| azurerm   | >= 3.0.0 |

## Providers

| Name    | Version  |
| ------- | -------- |
| azurerm | >= 3.0.0 |

## Resources

| Name                                                                                                          | Type   | Documentation                     |
| ------------------------------------------------------------------------------------------------------------- | ------ | --------------------------------- |
| [module.public_ip](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/public_ip) | module | Delegates to networking/public_ip |

<p align="right">(<a href="#readme-top">back to top</a>)</p>

## Inputs

| Name                | Description                                                     | Type           | Default                                                                                      | Required |
| ------------------- | --------------------------------------------------------------- | -------------- | -------------------------------------------------------------------------------------------- | :------: |
| name                | Name of the Public IP resource                                  | `string`       | n/a                                                                                          |   yes    |
| resource_group_name | The name of an existing resource group                          | `string`       | n/a                                                                                          |   yes    |
| location            | The Azure region where resources will be created                | `string`       | `"eastus"`                                                                                   |    no    |
| sku                 | The SKU of the Public IP (Basic or Standard)                    | `string`       | `"Standard"`                                                                                 |    no    |
| allocation_method   | Allocation method (Static or Dynamic). Standard requires Static | `string`       | `"Static"`                                                                                   |    no    |
| domain_name_label   | Label for a DNS name to generate an FQDN                        | `string`       | `null`                                                                                       |    no    |
| ip_version          | The IP version (IPv4 or IPv6)                                   | `string`       | `"IPv4"`                                                                                     |    no    |
| zones               | List of availability zones (empty means regional)               | `list(string)` | `[]`                                                                                         |    no    |
| tags                | A mapping of tags to assign to the resource                     | `map(string)`  | `{ terraform = "true", created_by = "ThinkStack", environment = "prod", priority = "high" }` |    no    |

## Outputs

| Name       | Description                                                          |
| ---------- | -------------------------------------------------------------------- |
| id         | The ID of the Public IP                                              |
| name       | The name of the Public IP                                            |
| ip_address | The allocated public IP address                                      |
| fqdn       | The DNS FQDN assigned to the Public IP (if domain_name_label is set) |

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
