# Azure Virtual Network (VNet) Terraform Module

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

<h3 align="center">Azure Virtual Network Module</h3>
  <p align="center">
    This module creates a comprehensive Azure Virtual Network (VNet) infrastructure with multiple subnet types, NAT Gateways, route tables, and optional flow logging capabilities.
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
    <li><a href="#architecture">Architecture</a></li>
    <li><a href="#notes">Notes</a></li>
    <li><a href="#license">License</a></li>
    <li><a href="#contact">Contact</a></li>
    <li><a href="#acknowledgments">Acknowledgments</a></li>
  </ol>
</details>

## Overview

This Terraform module creates a comprehensive Azure Virtual Network (VNet) infrastructure that mirrors the structure and functionality of the AWS VPC module. It provides enterprise-grade networking capabilities for Azure cloud deployments.

The module supports:
- **Virtual Network**: Configurable address space with custom DNS servers
- **Multiple Subnet Types**: Private, Public, DMZ, Database, Management, and Workspaces subnets
- **NAT Gateway**: Optional NAT Gateway for outbound internet connectivity from private subnets
- **Route Tables**: Separate route tables for each subnet type with automatic associations
- **Service Endpoints**: Optional Azure service endpoints for private connectivity
- **Network Security Groups**: Pre-configured NSG for service endpoint security
- **Flow Logs**: Optional VNet flow logs with storage account and Network Watcher integration
- **Traffic Analytics**: Optional traffic analytics with Log Analytics workspace integration

**Note**: This module requires an existing resource group. Use the separate resource group module to create and manage resource groups.

<p align="right">(<a href="#readme-top">back to top</a>)</p>

<!-- USAGE EXAMPLES -->
## Usage

### Basic Example

```hcl
# First, create the resource group
module "resource_group" {
  source = "github.com/thinkstack-co/terraform-modules//modules/azure/resource_group"

  name     = "my-resource-group"
  location = "eastus"
  tags = {
    terraform   = "true"
    created_by  = "Terraform"
    environment = "dev"
  }
}

# Then, create the VNet
module "vnet" {
  source = "github.com/thinkstack-co/terraform-modules//modules/azure/vnet"

  name                = "my-vnet"
  location            = "eastus"
  resource_group_name = module.resource_group.name
  vnet_address_space  = "10.0.0.0/16"

  private_subnets_list = ["10.0.1.0/24", "10.0.2.0/24"]
  public_subnets_list  = ["10.0.201.0/24", "10.0.202.0/24"]

  enable_nat_gateway = true
  enable_flow_logs   = false

  tags = {
    terraform   = "true"
    created_by  = "Terraform"
    environment = "dev"
  }
}
```

### Complete Example with All Features

```hcl
module "vnet" {
  source = "github.com/thinkstack-co/terraform-modules//modules/azure/vnet"

  # Resource Group (must exist)
  resource_group_name = "my-vnet-rg"
  location            = "eastus"

  # Virtual Network
  name               = "production-vnet"
  vnet_address_space = "10.100.0.0/16"
  dns_servers        = ["10.100.0.4", "10.100.0.5"]

  # Subnets
  private_subnets_list    = ["10.100.1.0/24", "10.100.2.0/24", "10.100.3.0/24"]
  public_subnets_list     = ["10.100.201.0/24", "10.100.202.0/24", "10.100.203.0/24"]
  dmz_subnets_list        = ["10.100.101.0/24", "10.100.102.0/24", "10.100.103.0/24"]
  db_subnets_list         = ["10.100.11.0/24", "10.100.12.0/24", "10.100.13.0/24"]
  mgmt_subnets_list       = ["10.100.61.0/24", "10.100.62.0/24", "10.100.63.0/24"]
  workspaces_subnets_list = ["10.100.21.0/24", "10.100.22.0/24", "10.100.23.0/24"]

  # Service Endpoints
  enable_service_endpoints = true
  service_endpoints        = ["Microsoft.Storage", "Microsoft.KeyVault", "Microsoft.Sql"]

  # NAT Gateway
  enable_nat_gateway         = true
  single_nat_gateway         = false
  enable_dmz_nat             = false
  nat_gateway_idle_timeout   = 10
  nat_gateway_zones          = ["1", "2", "3"]

  # Flow Logs
  enable_flow_logs                     = true
  create_network_watcher               = true
  flow_logs_storage_account_tier       = "Standard"
  flow_logs_storage_replication_type   = "LRS"
  flow_logs_retention_days             = 90

  # Traffic Analytics
  enable_traffic_analytics          = true
  log_analytics_workspace_id        = "/subscriptions/xxx/resourceGroups/xxx/providers/Microsoft.OperationalInsights/workspaces/xxx"
  log_analytics_workspace_resource_id = "/subscriptions/xxx/resourceGroups/xxx/providers/Microsoft.OperationalInsights/workspaces/xxx"
  traffic_analytics_interval        = 60

  tags = {
    terraform   = "true"
    created_by  = "ThinkStack"
    environment = "production"
    priority    = "high"
  }
}
```

### Example with Existing Resource Group and Network Watcher

```hcl
module "vnet" {
  source = "github.com/thinkstack-co/terraform-modules//modules/azure/vnet"

  # Use existing resource group
  resource_group_name = "existing-rg"
  location            = "eastus"

  name               = "my-vnet"
  vnet_address_space = "10.50.0.0/16"

  private_subnets_list = ["10.50.1.0/24", "10.50.2.0/24"]
  public_subnets_list  = ["10.50.201.0/24", "10.50.202.0/24"]

  enable_nat_gateway = true
  single_nat_gateway = true  # Use single NAT Gateway for cost savings

  # Use existing Network Watcher
  enable_flow_logs                    = true
  create_network_watcher              = false
  network_watcher_name                = "NetworkWatcher_eastus"
  network_watcher_resource_group_name = "NetworkWatcherRG"

  tags = {
    environment = "staging"
  }
}
```

### Argument Reference

* `name` - (Required) Name to be tagged on all resources as an identifier.
* `resource_group_name` - (Required) The name of an existing resource group in which to create the VNet.
* `location` - (Optional) The Azure region where resources will be created. Default is `eastus`.
* `vnet_address_space` - (Optional) The address space for the Virtual Network. Default is `10.11.0.0/16`.
* `private_subnets_list` - (Optional) List of private subnets inside the VNet.
* `public_subnets_list` - (Optional) List of public subnets inside the VNet.
* `enable_nat_gateway` - (Optional) Enable NAT gateways in private subnets. Default is `true`.
* `enable_flow_logs` - (Optional) Enable VNet flow logs. Default is `true`.
* `tags` - (Optional) A mapping of tags to assign to resources.

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
| [azurerm_virtual_network](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/virtual_network) | resource | [Azure Documentation](https://docs.microsoft.com/en-us/azure/virtual-network/virtual-networks-overview) |
| [azurerm_subnet](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/subnet) | resource | [Azure Documentation](https://docs.microsoft.com/en-us/azure/virtual-network/virtual-network-manage-subnet) |
| [azurerm_network_security_group](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/network_security_group) | resource | [Azure Documentation](https://docs.microsoft.com/en-us/azure/virtual-network/network-security-groups-overview) |
| [azurerm_nat_gateway](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/nat_gateway) | resource | [Azure Documentation](https://docs.microsoft.com/en-us/azure/virtual-network/nat-gateway/nat-overview) |
| [azurerm_route_table](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/route_table) | resource | [Azure Documentation](https://docs.microsoft.com/en-us/azure/virtual-network/virtual-networks-udr-overview) |
| [azurerm_network_watcher_flow_log](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/network_watcher_flow_log) | resource | [Azure Documentation](https://docs.microsoft.com/en-us/azure/network-watcher/network-watcher-nsg-flow-logging-overview) |

<p align="right">(<a href="#readme-top">back to top</a>)</p>

<!-- INPUTS -->
## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| name | Name to be tagged on all resources as an identifier | `string` | n/a | yes |
| resource_group_name | The name of an existing resource group | `string` | n/a | yes |
| location | The Azure region where resources will be created | `string` | `"eastus"` | no |
| vnet_address_space | The address space for the Virtual Network | `string` | `"10.11.0.0/16"` | no |
| dns_servers | List of DNS servers to use for the VNet | `list(string)` | `[]` | no |
| private_subnets_list | List of private subnets inside the VNet | `list(string)` | `["10.11.1.0/24", "10.11.2.0/24", "10.11.3.0/24"]` | no |
| public_subnets_list | List of public subnets inside the VNet | `list(string)` | `["10.11.201.0/24", "10.11.202.0/24", "10.11.203.0/24"]` | no |
| dmz_subnets_list | List of DMZ subnets inside the VNet | `list(string)` | `["10.11.101.0/24", "10.11.102.0/24", "10.11.103.0/24"]` | no |
| db_subnets_list | List of database subnets inside the VNet | `list(string)` | `["10.11.11.0/24", "10.11.12.0/24", "10.11.13.0/24"]` | no |
| mgmt_subnets_list | List of management subnets inside the VNet | `list(string)` | `["10.11.61.0/24", "10.11.62.0/24", "10.11.63.0/24"]` | no |
| workspaces_subnets_list | List of workspaces subnets inside the VNet | `list(string)` | `["10.11.21.0/24", "10.11.22.0/24", "10.11.23.0/24"]` | no |
| enable_service_endpoints | Enable service endpoints on private subnets | `bool` | `false` | no |
| service_endpoints | List of service endpoints to enable | `list(string)` | `["Microsoft.Storage", "Microsoft.KeyVault", "Microsoft.Sql"]` | no |
| enable_nat_gateway | Enable NAT gateways in private subnets | `bool` | `true` | no |
| single_nat_gateway | Use only a single shared NAT Gateway | `bool` | `false` | no |
| enable_dmz_nat | Enable NAT gateway for DMZ subnets | `bool` | `false` | no |
| nat_gateway_idle_timeout | Idle timeout in minutes for NAT Gateway | `number` | `4` | no |
| nat_gateway_zones | List of availability zones for NAT Gateway | `list(string)` | `[]` | no |
| enable_flow_logs | Enable VNet flow logs | `bool` | `true` | no |
| create_network_watcher | Create a new Network Watcher | `bool` | `false` | no |
| flow_logs_retention_days | Number of days to retain flow logs | `number` | `90` | no |
| enable_traffic_analytics | Enable traffic analytics for flow logs | `bool` | `false` | no |
| traffic_analytics_interval | Traffic analytics interval in minutes | `number` | `60` | no |
| tags | A mapping of tags to assign to resources | `map(string)` | `{ terraform = "true", created_by = "ThinkStack", environment = "prod", priority = "high" }` | no |

## Outputs

| Name | Description |
|------|-------------|
| vnet_id | The ID of the Virtual Network |
| vnet_name | The name of the Virtual Network |
| vnet_address_space | The address space of the Virtual Network |
| private_subnet_ids | List of IDs of private subnets |
| public_subnet_ids | List of IDs of public subnets |
| dmz_subnet_ids | List of IDs of DMZ subnets |
| db_subnet_ids | List of IDs of database subnets |
| mgmt_subnet_ids | List of IDs of management subnets |
| workspaces_subnet_ids | List of IDs of workspaces subnets |
| nat_gateway_ids | List of IDs of NAT Gateways |
| nat_gateway_public_ips | List of public IP addresses of NAT Gateways |
| public_route_table_id | ID of the public route table |
| private_route_table_ids | List of IDs of private route tables |
| service_endpoints_nsg_id | ID of the service endpoints NSG |
| flow_logs_storage_account_id | ID of the storage account for flow logs |
| resource_group_name | The name of the resource group |

<p align="right">(<a href="#readme-top">back to top</a>)</p>

## Architecture

This module creates a comprehensive Azure Virtual Network infrastructure with the following architecture:

```text
┌─────────────────────────────────────────────────────────────┐
│                      Virtual Network                         │
│                    (10.11.0.0/16)                           │
│                                                              │
│  ┌────────────────┐  ┌────────────────┐  ┌──────────────┐ │
│  │ Public Subnets │  │  DMZ Subnets   │  │ Private      │ │
│  │ 10.11.201.0/24 │  │ 10.11.101.0/24 │  │ Subnets      │ │
│  │ 10.11.202.0/24 │  │ 10.11.102.0/24 │  │ 10.11.1.0/24 │ │
│  │ 10.11.203.0/24 │  │ 10.11.103.0/24 │  │ 10.11.2.0/24 │ │
│  └────────┬───────┘  └────────┬───────┘  └──────┬───────┘ │
│           │                   │                  │          │
│           │                   │         ┌────────▼───────┐ │
│           │                   │         │  NAT Gateway   │ │
│           │                   │         │  (per subnet)  │ │
│           │                   │         └────────┬───────┘ │
│           │                   │                  │          │
│  ┌────────▼───────┐  ┌────────▼───────┐  ┌──────▼───────┐ │
│  │   DB Subnets   │  │  Mgmt Subnets  │  │ Workspaces   │ │
│  │ 10.11.11.0/24  │  │ 10.11.61.0/24  │  │ Subnets      │ │
│  │ 10.11.12.0/24  │  │ 10.11.62.0/24  │  │ 10.11.21.0/24│ │
│  │ 10.11.13.0/24  │  │ 10.11.63.0/24  │  │ 10.11.22.0/24│ │
│  └────────────────┘  └────────────────┘  └──────────────┘ │
│                                                              │
└─────────────────────────────────────────────────────────────┘
                           │
                           ▼
                    Internet Gateway
```

<p align="right">(<a href="#readme-top">back to top</a>)</p>

## Notes

- **Storage Account Naming**: The storage account for flow logs uses a timestamp in the name to ensure uniqueness. The lifecycle policy ignores changes to prevent recreation.
- **Network Watcher**: Azure typically has one Network Watcher per region per subscription. Consider using an existing one instead of creating a new one.
- **NAT Gateway Costs**: NAT Gateways incur costs. Use `single_nat_gateway = true` for development environments to reduce costs.
- **Service Endpoints**: Service endpoints are free but only work for Azure services. For on-premises connectivity, consider Azure Private Link.
- **Traffic Analytics**: Requires a Log Analytics workspace and incurs additional costs.

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
