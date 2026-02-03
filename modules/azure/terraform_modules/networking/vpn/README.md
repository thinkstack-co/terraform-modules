# Azure VPN Terraform Module

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

<h3 align="center">Azure VPN Module</h3>
  <p align="center">
    This module provisions a complete Azure VPN gateway setup to connect to on-prem or vendor networks.
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

This module provisions a complete VPN stack in Azure, including a Virtual Network Gateway, a Local Network Gateway, a VPN connection, and a public IP.

The module supports:

- Route-based or policy-based VPN gateways
- Optional active-active configuration
- Optional BGP
- Standard VPN gateway SKUs
- Dedicated GatewaySubnet lookup from the VNet

<p align="right">(<a href="#readme-top">back to top</a>)</p>

<!-- USAGE EXAMPLES -->
## Usage

### Basic Example

```hcl
module "vpn" {
  source = "github.com/thinkstack-co/terraform-modules//modules/azure/terraform_modules/networking/vpn"

  name                = "vpn-gateway"
  resource_group_name = "rg-network"
  location            = "eastus"

  vnet_name = module.vnet.vnet_name

  local_network_gateway_name = "onprem-gw"
  local_gateway_address      = "203.0.113.10"
  local_address_space        = ["192.168.0.0/16"]
  shared_key                 = var.vpn_shared_key

  tags = {
    terraform   = "true"
    created_by  = "Terraform"
    environment = "prod"
  }
}
```

<p align="right">(<a href="#readme-top">back to top</a>)</p>

## Requirements

| Name | Version |
| --- | --- |
| terraform | >= 1.0.0 |
| azurerm | >= 3.0.0 |

## Providers

| Name | Version |
| --- | --- |
| azurerm | >= 3.0.0 |

## Resources

| Name | Type | Documentation |
| --- | --- | --- |
| [azurerm_public_ip](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/public_ip) | resource | [Azure Documentation](https://learn.microsoft.com/azure/virtual-network/ip-services/public-ip-addresses) |
| [azurerm_virtual_network_gateway](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/virtual_network_gateway) | resource | [Azure Documentation](https://learn.microsoft.com/azure/vpn-gateway/vpn-gateway-about-vpngateways) |
| [azurerm_local_network_gateway](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/local_network_gateway) | resource | [Azure Documentation](https://learn.microsoft.com/azure/vpn-gateway/vpn-gateway-howto-site-to-site-resource-manager-portal) |
| [azurerm_virtual_network_gateway_connection](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/virtual_network_gateway_connection) | resource | [Azure Documentation](https://learn.microsoft.com/azure/vpn-gateway/vpn-gateway-howto-site-to-site-resource-manager-portal) |
| [azurerm_subnet](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/subnet) | data source | [Azure Documentation](https://learn.microsoft.com/azure/virtual-network/virtual-network-manage-subnet) |

<p align="right">(<a href="#readme-top">back to top</a>)</p>

## Inputs

| Name | Description | Type | Default | Required |
| --- | --- | --- | --- | :---: |
| name | Name of the Virtual Network Gateway | `string` | n/a | yes |
| resource_group_name | Resource group name for the VPN resources | `string` | n/a | yes |
| location | Azure region for the VPN resources | `string` | `"eastus"` | no |
| vnet_name | VNet name where the GatewaySubnet exists | `string` | n/a | yes |
| local_network_gateway_name | Name of the local network gateway | `string` | n/a | yes |
| local_gateway_address | Public IP of the on-prem or vendor gateway | `string` | n/a | yes |
| local_address_space | Address spaces for the on-prem or vendor network | `list(string)` | n/a | yes |
| shared_key | Pre-shared key for the VPN connection | `string` | n/a | yes |
| vnet_resource_group_name | Resource group of the target VNet | `string` | `""` | no |
| public_ip_name | Public IP name for the VPN gateway | `string` | `"vpn-gateway-pip"` | no |
| ip_configuration_name | IP configuration name for the VPN gateway | `string` | `"vpn-ipconfig"` | no |
| vpn_type | VPN type (RouteBased or PolicyBased) | `string` | `"RouteBased"` | no |
| sku | VPN gateway SKU | `string` | `"VpnGw1"` | no |
| generation | VPN gateway generation (Generation1 or Generation2) | `string` | `"Generation1"` | no |
| active_active | Enable active-active VPN gateways | `bool` | `false` | no |
| enable_bgp | Enable BGP for the VPN gateway and connection | `bool` | `false` | no |
| connection_name | Name of the VPN connection | `string` | `"vpn-connection"` | no |
| connection_protocol | VPN connection protocol | `string` | `"IKEv2"` | no |
| tags | A mapping of tags to assign to the resources | `map(string)` | `{ terraform = "true", created_by = "ThinkStack", environment = "prod", priority = "high" }` | no |

## Outputs

| Name | Description |
| --- | --- |
| virtual_network_gateway_id | The ID of the Virtual Network Gateway |
| virtual_network_gateway_name | The name of the Virtual Network Gateway |
| public_ip_address | The public IP address of the VPN gateway |
| local_network_gateway_id | The ID of the local network gateway |
| vpn_connection_id | The ID of the VPN connection |

<p align="right">(<a href="#readme-top">back to top</a>)</p>

## Notes

- **GatewaySubnet**: The module expects a `GatewaySubnet` to exist in the VNet. Use the VNet module with `enable_vpn_subnet = true` to create it automatically.
- **Shared Key**: Keep the pre-shared key secure; treat it as sensitive.
- **Active-Active**: When enabled, ensure your SKU supports active-active.

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
