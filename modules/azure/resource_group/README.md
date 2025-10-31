# Azure Resource Group Terraform Module

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

<h3 align="center">Azure Resource Group Module</h3>
  <p align="center">
    This module creates and manages Azure Resource Groups, which are logical containers for grouping related Azure resources.
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

This Terraform module creates and manages Azure Resource Groups. Resource groups are fundamental organizational units in Azure that act as logical containers for resources deployed within an Azure subscription. All Azure resources must belong to a resource group.

The module supports:
- Resource group creation with custom naming
- Location/region specification
- Resource tagging for organization and cost tracking
- Simple, reusable configuration

<p align="right">(<a href="#readme-top">back to top</a>)</p>

<!-- USAGE EXAMPLES -->
## Usage

### Basic Example

```hcl
module "resource_group" {
  source = "github.com/thinkstack-co/terraform-modules//modules/azure/resource_group"

  name     = "my-resource-group"
  location = "eastus"
  tags = {
    terraform   = "true"
    created_by  = "Terraform"
    environment = "production"
  }
}
```

### Multiple Resource Groups

```hcl
module "network_rg" {
  source = "github.com/thinkstack-co/terraform-modules//modules/azure/resource_group"

  name     = "network-resources-rg"
  location = "eastus"
  tags = {
    terraform   = "true"
    created_by  = "Terraform"
    environment = "production"
    purpose     = "networking"
  }
}

module "compute_rg" {
  source = "github.com/thinkstack-co/terraform-modules//modules/azure/resource_group"

  name     = "compute-resources-rg"
  location = "eastus"
  tags = {
    terraform   = "true"
    created_by  = "Terraform"
    environment = "production"
    purpose     = "compute"
  }
}
```

### With Different Regions

```hcl
module "eastus_rg" {
  source = "github.com/thinkstack-co/terraform-modules//modules/azure/resource_group"

  name     = "eastus-resources-rg"
  location = "eastus"
  tags = {
    terraform   = "true"
    environment = "production"
    region      = "east"
  }
}

module "westus_rg" {
  source = "github.com/thinkstack-co/terraform-modules//modules/azure/resource_group"

  name     = "westus-resources-rg"
  location = "westus2"
  tags = {
    terraform   = "true"
    environment = "production"
    region      = "west"
  }
}
```

### Argument Reference

* `name` - (Required) The name of the resource group. Must be unique within the Azure subscription.
* `location` - (Optional) The Azure region where the resource group will be created. Default is `eastus`.
* `tags` - (Optional) A mapping of tags to assign to the resource group.

<p align="right">(<a href="#readme-top">back to top</a>)</p>

<!-- REQUIREMENTS -->
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
| [azurerm_resource_group](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/resource_group) | resource | [Azure Documentation](https://docs.microsoft.com/en-us/azure/azure-resource-manager/management/manage-resource-groups-portal) |

<p align="right">(<a href="#readme-top">back to top</a>)</p>

<!-- INPUTS -->
## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| name | The name of the resource group. Must be unique within the Azure subscription | `string` | n/a | yes |
| location | The Azure region where the resource group will be created | `string` | `"eastus"` | no |
| tags | A mapping of tags to assign to the resource group | `map(string)` | `{ terraform = "true", created_by = "ThinkStack", environment = "prod", priority = "high" }` | no |

## Outputs

| Name | Description |
|------|-------------|
| id | The ID of the resource group |
| name | The name of the resource group |
| location | The location of the resource group |

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
