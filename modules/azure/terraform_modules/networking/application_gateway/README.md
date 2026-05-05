# Azure Application Gateway Terraform Module

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

<h3 align="center">Azure Application Gateway Module</h3>
  <p align="center">
    This module provisions an Azure Application Gateway with a single frontend, listener, backend pool, and routing rule.
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

This Terraform module creates a basic Azure Application Gateway with a single backend pool, listener, and routing rule.

The module supports:

- Standard_v2 or WAF_v2 SKU
- Dedicated gateway subnet configuration
- Public frontend IP
- Backend pool IP addresses
- Basic or path-based routing rule configuration
- HTTPS listener with SSL certificate
- Optional WAF policy attachment
- Resource tagging

<p align="right">(<a href="#readme-top">back to top</a>)</p>

<!-- USAGE EXAMPLES -->

## Usage

### Basic Example

```hcl
module "resource_group" {
  source = "github.com/thinkstack-co/terraform-modules//modules/azure/terraform_modules/core/resource_group"

  name     = "rg-appgw"
  location = "eastus"
}

module "public_ip" {
  source = "github.com/thinkstack-co/terraform-modules//modules/azure/terraform_modules/networking/public_ip"

  name                = "pip-appgw"
  resource_group_name = module.resource_group.name
  location            = "eastus"
}

module "application_gateway" {
  source = "github.com/thinkstack-co/terraform-modules//modules/azure/terraform_modules/networking/application_gateway"

  name                = "appgw-basic"
  resource_group_name = module.resource_group.name
  location            = "eastus"

  gateway_subnet_id     = azurerm_subnet.appgw.id
  frontend_public_ip_id = module.public_ip.id

  backend_pool_ip_addresses = ["10.0.2.10", "10.0.2.11"]

  tags = {
    terraform   = "true"
    created_by  = "Terraform"
    environment = "dev"
  }
}
```

### HTTPS + WAF + Path-Based Routing Example

```hcl
module "application_gateway" {
  source = "github.com/thinkstack-co/terraform-modules//modules/azure/terraform_modules/networking/application_gateway"

  name                = "appgw-secure"
  resource_group_name = module.resource_group.name
  location            = "eastus"

  gateway_subnet_id     = azurerm_subnet.appgw.id
  frontend_public_ip_id = module.public_ip.id

  backend_pool_ip_addresses = ["10.0.2.10", "10.0.2.11"]

  enable_https_listener     = true
  https_listener_host_name  = "app.example.com"
  ssl_certificate_name      = "appgw-cert"
  ssl_certificate_data      = filebase64("./certs/appgw.pfx")
  ssl_certificate_password  = var.ssl_cert_password

  waf_policy_id = azurerm_web_application_firewall_policy.appgw.id

  enable_path_based_routing = true
  additional_backend_pools = {
    api = ["10.0.2.20", "10.0.2.21"]
  }
  additional_backend_http_settings = {
    api = {
      port                  = 8080
      protocol              = "Http"
      cookie_based_affinity = "Disabled"
      request_timeout       = 30
    }
  }
  path_rules = [
    {
      name                       = "api"
      paths                      = ["/api/*"]
      backend_address_pool_name  = "api"
      backend_http_settings_name = "api"
    }
  ]

  tags = {
    terraform   = "true"
    created_by  = "Terraform"
    environment = "prod"
  }
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

| Name                                                                                                                               | Type     | Documentation                                                                         |
| ---------------------------------------------------------------------------------------------------------------------------------- | -------- | ------------------------------------------------------------------------------------- |
| [azurerm_application_gateway](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/application_gateway) | resource | [Azure Documentation](https://learn.microsoft.com/azure/application-gateway/overview) |

<p align="right">(<a href="#readme-top">back to top</a>)</p>

## Inputs

| Name                                        | Description                                     | Type                | Default                                                                                      | Required |
| ------------------------------------------- | ----------------------------------------------- | ------------------- | -------------------------------------------------------------------------------------------- | :------: |
| name                                        | Name of the Application Gateway                 | `string`            | n/a                                                                                          |   yes    |
| resource_group_name                         | Resource group name for the Application Gateway | `string`            | n/a                                                                                          |   yes    |
| gateway_subnet_id                           | Subnet ID for the Application Gateway           | `string`            | n/a                                                                                          |   yes    |
| frontend_public_ip_id                       | Public IP ID for the frontend                   | `string`            | n/a                                                                                          |   yes    |
| backend_pool_ip_addresses                   | Backend pool IP addresses                       | `list(string)`      | n/a                                                                                          |   yes    |
| location                                    | Azure region where resources will be created    | `string`            | `"eastus"`                                                                                   |    no    |
| enable_http2                                | Enable HTTP/2                                   | `bool`              | `false`                                                                                      |    no    |
| sku_name                                    | SKU name (Standard_v2 or WAF_v2)                | `string`            | `"Standard_v2"`                                                                              |    no    |
| sku_tier                                    | SKU tier (Standard_v2 or WAF_v2)                | `string`            | `"Standard_v2"`                                                                              |    no    |
| sku_capacity                                | Instance capacity                               | `number`            | `2`                                                                                          |    no    |
| gateway_ip_configuration_name               | Gateway IP configuration name                   | `string`            | `"appgw-gateway-ip"`                                                                         |    no    |
| frontend_port_name                          | Frontend port name                              | `string`            | `"appgw-frontend-port"`                                                                      |    no    |
| frontend_port                               | Frontend port                                   | `number`            | `80`                                                                                         |    no    |
| enable_https_listener                       | Enable HTTPS listener                           | `bool`              | `false`                                                                                      |    no    |
| https_frontend_port_name                    | HTTPS frontend port name                        | `string`            | `"appgw-https-frontend-port"`                                                                |    no    |
| https_frontend_port                         | HTTPS frontend port                             | `number`            | `443`                                                                                        |    no    |
| frontend_ip_configuration_name              | Frontend IP configuration name                  | `string`            | `"appgw-frontend-ip"`                                                                        |    no    |
| backend_address_pool_name                   | Backend address pool name                       | `string`            | `"appgw-backend-pool"`                                                                       |    no    |
| additional_backend_pools                    | Additional backend pools                        | `map(list(string))` | `{}`                                                                                         |    no    |
| backend_http_settings_name                  | Backend HTTP settings name                      | `string`            | `"appgw-backend-http"`                                                                       |    no    |
| backend_http_settings_port                  | Backend HTTP port                               | `number`            | `80`                                                                                         |    no    |
| backend_http_settings_protocol              | Backend protocol (Http or Https)                | `string`            | `"Http"`                                                                                     |    no    |
| backend_http_settings_cookie_based_affinity | Cookie affinity (Enabled or Disabled)           | `string`            | `"Disabled"`                                                                                 |    no    |
| backend_http_settings_request_timeout       | Request timeout in seconds                      | `number`            | `30`                                                                                         |    no    |
| additional_backend_http_settings            | Additional backend HTTP settings                | `map(object)`       | `{}`                                                                                         |    no    |
| http_listener_name                          | HTTP listener name                              | `string`            | `"appgw-http-listener"`                                                                      |    no    |
| http_listener_protocol                      | Listener protocol (Http or Https)               | `string`            | `"Http"`                                                                                     |    no    |
| http_listener_host_name                     | Listener host name                              | `string`            | `null`                                                                                       |    no    |
| https_listener_name                         | HTTPS listener name                             | `string`            | `"appgw-https-listener"`                                                                     |    no    |
| https_listener_host_name                    | HTTPS listener host name                        | `string`            | `null`                                                                                       |    no    |
| ssl_certificate_name                        | SSL certificate name                            | `string`            | `"appgw-ssl-cert"`                                                                           |    no    |
| ssl_certificate_data                        | Base64-encoded PFX data                         | `string`            | `null`                                                                                       |    no    |
| ssl_certificate_password                    | SSL certificate password                        | `string`            | `null`                                                                                       |    no    |
| request_routing_rule_name                   | Routing rule name                               | `string`            | `"appgw-routing-rule"`                                                                       |    no    |
| request_routing_rule_type                   | Routing rule type (Basic or PathBasedRouting)   | `string`            | `"Basic"`                                                                                    |    no    |
| request_routing_rule_priority               | Routing rule priority                           | `number`            | `100`                                                                                        |    no    |
| enable_path_based_routing                   | Enable path-based routing                       | `bool`              | `false`                                                                                      |    no    |
| path_map_name                               | URL path map name                               | `string`            | `"appgw-path-map"`                                                                           |    no    |
| path_map_default_backend_pool_name          | Default backend pool name                       | `string`            | `"appgw-backend-pool"`                                                                       |    no    |
| path_map_default_backend_http_settings_name | Default backend HTTP settings name              | `string`            | `"appgw-backend-http"`                                                                       |    no    |
| path_rules                                  | Path rules for URL path maps                    | `list(object)`      | `[]`                                                                                         |    no    |
| waf_policy_id                               | WAF policy ID to attach                         | `string`            | `null`                                                                                       |    no    |
| tags                                        | A mapping of tags to assign to the resource     | `map(string)`       | `{ terraform = "true", created_by = "ThinkStack", environment = "prod", priority = "high" }` |    no    |

## Outputs

| Name                           | Description                               |
| ------------------------------ | ----------------------------------------- |
| id                             | The ID of the Application Gateway         |
| name                           | The name of the Application Gateway       |
| frontend_ip_configuration_name | The frontend IP configuration name        |
| frontend_port_name             | The frontend port name                    |
| backend_address_pool_name      | The backend address pool name             |
| backend_http_settings_name     | The backend HTTP settings name            |
| http_listener_name             | The HTTP listener name                    |
| https_listener_name            | The HTTPS listener name (if enabled)      |
| request_routing_rule_name      | The routing rule name                     |
| url_path_map_name              | The URL path map name (if enabled)        |
| waf_policy_id                  | The WAF policy ID attached to the gateway |

<p align="right">(<a href="#readme-top">back to top</a>)</p>

## Notes

- **Gateway Subnet**: Application Gateway requires a dedicated subnet. Do not place other workloads in the same subnet.
- **Backend Pool**: This module uses IP-based backend targets. Use internal IPs of your backend resources.
- **WAF**: For WAF_v2, attach a WAF policy separately if needed.

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
