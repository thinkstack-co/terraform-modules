# Azure Virtual Desktop (AVD) Host Pool + Workspace ARM Template Terraform Module

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

<h3 align="center">Azure Virtual Desktop ARM Template Module</h3>
  <p align="center">
    This module deploys an Azure Virtual Desktop (AVD) host pool, desktop application group, workspace, and Log Analytics workspace by running an ARM template deployment.
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

This Terraform module deploys an **Azure Virtual Desktop (AVD)** control-plane set by executing the included ARM template (`avd_hostpool_workspace.json`) using an Azure Resource Group template deployment.

The ARM template creates:

- A **Log Analytics Workspace** (named `<hostpoolName>-log`)
- An **AVD Host Pool**
- A **Desktop Application Group (DAG)**
- An **AVD Workspace**
- **Diagnostic Settings** for the above resources to send logs to Log Analytics

The template also supports a management/shared mode via `is_management_host_pool`, which adjusts naming and tagging behavior inside the ARM template.

<p align="right">(<a href="#readme-top">back to top</a>)</p>

<!-- USAGE EXAMPLES -->

## Usage

### Basic Example

```hcl
module "avd_hostpool_workspace" {
  source = "github.com/thinkstack-co/terraform-modules//modules/azure/arm_templates/avd_hostpool_workspace"

  resource_group_name = azurerm_resource_group.rg.name

  deployment_name = "acme-avd-core"

  is_management_host_pool = false
  customer_short_name     = "acme"
  location_short_name     = "eu1"

  hostpool_name = "acme-eu1-avd-hp-1"
  hostpool_type = "Pooled"

  preferred_app_group_type = "Desktop"
  max_session_limit        = 25
  load_balancer_type       = "BreadthFirst"

  personal_desktop_assignment_type = ""

  custom_rdp_property = "enablerdsaadauth:i:1;"
}
```

### Management Host Pool Example

```hcl
module "avd_hostpool_workspace_mgmt" {
  source = "github.com/thinkstack-co/terraform-modules//modules/azure/arm_templates/avd_hostpool_workspace"

  resource_group_name = azurerm_resource_group.rg.name

  is_management_host_pool = true
  customer_short_name     = ""  # allowed when is_management_host_pool = true
  location_short_name     = "eu1"

  hostpool_name = "shared-eu1-avd-hp-1"
  hostpool_type = "Pooled"
}
```

<p align="right">(<a href="#readme-top">back to top</a>)</p>

<!-- REQUIREMENTS -->

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

| Name                                           | Type     |
| ---------------------------------------------- | -------- |
| azurerm_resource_group_template_deployment.avd | resource |

<p align="right">(<a href="#readme-top">back to top</a>)</p>

<!-- INPUTS -->

## Inputs

| Name                                                                        | Description                                                                       | Type     | Default                    |  Required   |
| --------------------------------------------------------------------------- | --------------------------------------------------------------------------------- | -------- | -------------------------- | :---------: |
| [deployment_name](#input_deployment_name)                                   | Name of the ARM template deployment in the resource group                         | `string` | `"avd-hostpool-workspace"` |     no      |
| [resource_group_name](#input_resource_group_name)                           | Name of the resource group where AVD resources will be created                    | `string` | n/a                        |     yes     |
| [is_management_host_pool](#input_is_management_host_pool)                   | Whether the host pool is a management/shared host pool                            | `bool`   | `false`                    |     no      |
| [customer_short_name](#input_customer_short_name)                           | (Required when is_management_host_pool = false) Customer short name               | `string` | `""`                       | conditional |
| [location_short_name](#input_location_short_name)                           | Short name for the Azure region used in naming                                    | `string` | n/a                        |     yes     |
| [hostpool_name](#input_hostpool_name)                                       | Host pool name to create                                                          | `string` | n/a                        |     yes     |
| [hostpool_friendly_name](#input_hostpool_friendly_name)                     | Friendly name for the host pool                                                   | `string` | `""`                       |     no      |
| [hostpool_description](#input_hostpool_description)                         | Description for the host pool                                                     | `string` | `""`                       |     no      |
| [preferred_app_group_type](#input_preferred_app_group_type)                 | Preferred app group type (`Desktop` or `RemoteApp`)                               | `string` | `"Desktop"`                |     no      |
| [hostpool_type](#input_hostpool_type)                                       | Host pool type (`Personal` or `Pooled`)                                           | `string` | n/a                        |     yes     |
| [personal_desktop_assignment_type](#input_personal_desktop_assignment_type) | Personal assignment type (`Automatic` or `Direct`) when hostpool_type is Personal | `string` | `""`                       |     no      |
| [max_session_limit](#input_max_session_limit)                               | Max sessions when hostpool_type is Pooled                                         | `number` | `99999`                    |     no      |
| [load_balancer_type](#input_load_balancer_type)                             | Load balancer algorithm (`BreadthFirst` or `DepthFirst`)                          | `string` | `"BreadthFirst"`           |     no      |
| [custom_rdp_property](#input_custom_rdp_property)                           | Custom RDP properties for the host pool                                           | `string` | (see variables.tf)         |     no      |

### Input Details

#### <a name="input_deployment_name"></a>`deployment_name`

Name of the ARM template deployment in the resource group.

#### <a name="input_resource_group_name"></a>`resource_group_name`

Name of the resource group where the ARM template will be deployed.

#### <a name="input_is_management_host_pool"></a>`is_management_host_pool`

If `true`, the ARM template uses management/shared naming and tagging behavior.

#### <a name="input_customer_short_name"></a>`customer_short_name`

Customer short name used for naming/tagging. Required when `is_management_host_pool = false`.

#### <a name="input_location_short_name"></a>`location_short_name`

Short Azure region identifier used in naming.

#### <a name="input_hostpool_name"></a>`hostpool_name`

Name of the AVD host pool.

#### <a name="input_hostpool_friendly_name"></a>`hostpool_friendly_name`

Friendly name shown for the host pool.

#### <a name="input_hostpool_description"></a>`hostpool_description`

Description for the host pool.

#### <a name="input_preferred_app_group_type"></a>`preferred_app_group_type`

Preferred app group type (`Desktop` or `RemoteApp`).

#### <a name="input_hostpool_type"></a>`hostpool_type`

Host pool type (`Personal` or `Pooled`).

#### <a name="input_personal_desktop_assignment_type"></a>`personal_desktop_assignment_type`

Personal assignment type (`Automatic` or `Direct`) when `hostpool_type = Personal`.

#### <a name="input_max_session_limit"></a>`max_session_limit`

Maximum sessions allowed when `hostpool_type = Pooled`.

#### <a name="input_load_balancer_type"></a>`load_balancer_type`

Load balancing algorithm (`BreadthFirst` or `DepthFirst`) when `hostpool_type = Pooled`.

#### <a name="input_custom_rdp_property"></a>`custom_rdp_property`

Custom RDP properties passed into the host pool configuration.

## Outputs

| Name                           | Description                                                                   |
| ------------------------------ | ----------------------------------------------------------------------------- |
| hostpool_name                  | Name of the AVD host pool (from ARM template output)                          |
| hostpool_id                    | Resource ID of the AVD host pool (from ARM template output)                   |
| log_analytics_workspace_name   | Name of the Log Analytics workspace (from ARM template output)                |
| log_analytics_workspace_id     | Resource ID of the Log Analytics workspace (from ARM template output)         |
| desktop_application_group_name | Name of the Desktop Application Group (DAG) (from ARM template output)        |
| desktop_application_group_id   | Resource ID of the Desktop Application Group (DAG) (from ARM template output) |
| workspace_name                 | Name of the AVD workspace (from ARM template output)                          |
| workspace_id                   | Resource ID of the AVD workspace (from ARM template output)                   |
| deployment_id                  | Resource ID of the ARM template deployment                                    |
| deployment_output_content      | Raw output content JSON from the ARM template deployment                      |

<p align="right">(<a href="#readme-top">back to top</a>)</p>

<!-- LICENSE -->

## License

Distributed under the MIT License. See `LICENSE.txt` for more information.

<p align="right">(<a href="#readme-top">back to top</a>)</p>

<!-- CONTACT -->

## Contact

Think|Stack - [![LinkedIn][linkedin-shield]][linkedin-url] - [info@thinkstack.co](mailto:info@thinkstack.co)

Project Link: [https://github.com/thinkstack-co/terraform-modules](https://github.com/thinkstack-co/terraform-modules)

<p align="right">(<a href="#readme-top">back to top</a>)</p>

<!-- ACKNOWLEDGMENTS -->

## Acknowledgments

- [Wesley Bey](https://github.com/beywesley)

[contributors-shield]: https://img.shields.io/github/contributors/thinkstack-co/terraform-modules.svg?style=for-the-badge
[contributors-url]: https://github.com/thinkstack-co/terraform-modules/graphs/contributors
[forks-shield]: https://img.shields.io/github/forks/thinkstack-co/terraform-modules.svg?style=for-the-badge
[forks-url]: https://github.com/thinkstack-co/terraform-modules/network/members
[stars-shield]: https://img.shields.io/github/stars/thinkstack-co/terraform-modules.svg?style=for-the-badge
[stars-url]: https://github.com/thinkstack-co/terraform-modules/stargazers
[issues-shield]: https://img.shields.io/github/issues/thinkstack-co/terraform-modules.svg?style=for-the-badge
[issues-url]: https://github.com/thinkstack-co/terraform-modules/issues
[license-shield]: https://img.shields.io/github/license/thinkstack-co/terraform-modules.svg?style=for-the-badge
[license-url]: https://github.com/thinkstack-co/terraform-modules/blob/main/LICENSE.txt
[linkedin-shield]: https://img.shields.io/badge/LinkedIn-%230077B5.svg?style=for-the-badge&logo=linkedin&logoColor=white
[linkedin-url]: https://www.linkedin.com/company/thinkstack-co/
