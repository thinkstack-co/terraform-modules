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
- **Multiple Subnet Types**: Private and Public subnets (one /24 each), plus optional Database subnets
- **Service Subnets**: Optional GatewaySubnet, AzureApplicationGatewaySubnet, and AzureFirewallSubnet created in the last /24s of the VNet
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
  source = "github.com/thinkstack-co/terraform-modules//modules/azure/terraform_modules/core/resource_group"

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
  source = "github.com/thinkstack-co/terraform-modules//modules/azure/terraform_modules/networking/vnet"

  name                = "my-vnet"
  location            = "eastus"
  resource_group_name = module.resource_group.name
  vnet_address_space  = "10.100.0.0/16"

  private_subnets_list = ["10.100.1.0/24"]
  public_subnets_list  = ["10.100.2.0/24"]

  enable_vpn_subnet                 = true
  enable_application_gateway_subnet = true
  enable_firewall_subnet            = true

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
  source = "github.com/thinkstack-co/terraform-modules//modules/azure/terraform_modules/networking/vnet"

  # Resource Group (must exist)
  resource_group_name = "my-vnet-rg"
  location            = "eastus"

  # Virtual Network
  name               = "production-vnet"
  vnet_address_space = "10.100.0.0/16"
  dns_servers        = ["10.100.0.4", "10.100.0.5"]

  # Subnets (one per subnet group)
  private_subnets_list = ["10.100.1.0/24"]
  public_subnets_list  = ["10.100.2.0/24"]
  enable_db_subnets    = true
  db_subnets_list      = ["10.100.11.0/24"]

  enable_vpn_subnet                 = true
  enable_application_gateway_subnet = true
  enable_firewall_subnet            = true

  # Service Endpoints
  enable_service_endpoints = true
  service_endpoints        = ["Microsoft.Storage", "Microsoft.KeyVault", "Microsoft.Sql"]

  # NAT Gateway
  enable_nat_gateway = true

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
  source = "github.com/thinkstack-co/terraform-modules//modules/azure/terraform_modules/networking/vnet"

  # Use existing resource group
  resource_group_name = "existing-rg"
  location            = "eastus"

  name               = "my-vnet"
  vnet_address_space = "10.100.0.0/16"

  private_subnets_list = ["10.100.1.0/24"]
  public_subnets_list  = ["10.100.2.0/24"]
  enable_db_subnets    = true
  db_subnets_list      = ["10.100.11.0/24"]

  enable_vpn_subnet                 = true
  enable_application_gateway_subnet = true
  enable_firewall_subnet            = true

  enable_nat_gateway = true

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

- `name` - (Required) Name to be tagged on all resources as an identifier.
- `resource_group_name` - (Required) The name of an existing resource group in which to create the VNet.
- `location` - (Optional) The Azure region where resources will be created. Default is `eastus`.
- `vnet_address_space` - (Optional) The address space for the Virtual Network. Must be /16 in size. Default is `10.100.0.0/16`.
- `enable_vpn_subnet` - (Optional) Create a GatewaySubnet in the last /24 of the VNet. Default is `false`.
- `enable_application_gateway_subnet` - (Optional) Create AzureApplicationGatewaySubnet in the last /24s of the VNet. Default is `false`.
- `enable_firewall_subnet` - (Optional) Create AzureFirewallSubnet in the last /24s of the VNet. Default is `false`.
- `private_subnets_list` - (Optional) List of private subnets inside the VNet (exactly one /24).
- `public_subnets_list` - (Optional) List of public subnets inside the VNet (exactly one /24).
- `enable_db_subnets` - (Optional) Enable creation of database subnets. Default is `false`.
- `db_subnets_list` - (Optional) List of database subnets inside the VNet (exactly one /24 when enabled).
- `enable_nat_gateway` - (Optional) Enable NAT gateways in private subnets. Default is `true`.
- `enable_flow_logs` - (Optional) Enable VNet flow logs. Default is `true`.
- `tags` - (Optional) A mapping of tags to assign to resources.

<p align="right">(<a href="#readme-top">back to top</a>)</p>

<!-- REQUIREMENTS -->
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
| [azurerm_virtual_network](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/virtual_network) | resource | [Azure Documentation](https://docs.microsoft.com/en-us/azure/virtual-network/virtual-networks-overview) |
| [azurerm_subnet](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/subnet) | resource | [Azure Documentation](https://docs.microsoft.com/en-us/azure/virtual-network/virtual-network-manage-subnet) |
| [azurerm_network_security_group](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/network_security_group) | resource | [Azure Documentation](https://docs.microsoft.com/en-us/azure/virtual-network/network-security-groups-overview) |
| [azurerm_nat_gateway](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/nat_gateway) | resource | [Azure Documentation](https://docs.microsoft.com/en-us/azure/virtual-network/nat-gateway/nat-overview) |
| [azurerm_route_table](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/route_table) | resource | [Azure Documentation](https://docs.microsoft.com/en-us/azure/virtual-network/virtual-networks-udr-overview) |
| [azurerm_network_watcher_flow_log](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/network_watcher_flow_log) | resource | [Azure Documentation](https://docs.microsoft.com/en-us/azure/network-watcher/network-watcher-nsg-flow-logging-overview) |

<p align="right">(<a href="#readme-top">back to top</a>)</p>

## Outputs

| Name | Description |
| --- | --- |
| vnet_id | The ID of the Virtual Network |
| vnet_name | The name of the Virtual Network |
| vnet_address_space | The address space of the Virtual Network |
| private_subnet_ids | List of IDs of private subnets |
| public_subnet_ids | List of IDs of public subnets |
| db_subnet_ids | List of IDs of database subnets |
| vpn_gateway_subnet_id | ID of the VPN GatewaySubnet |
| vpn_gateway_subnet_name | Name of the VPN GatewaySubnet |
| vpn_gateway_subnet_address_prefix | Address prefix of the VPN GatewaySubnet |
| application_gateway_subnet_id | ID of the AzureApplicationGatewaySubnet |
| application_gateway_subnet_name | Name of the AzureApplicationGatewaySubnet |
| application_gateway_subnet_address_prefix | Address prefix of the AzureApplicationGatewaySubnet |
| firewall_subnet_id | ID of the AzureFirewallSubnet |
| firewall_subnet_name | Name of the AzureFirewallSubnet |
| firewall_subnet_address_prefix | Address prefix of the AzureFirewallSubnet |
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
│                    (10.100.0.0/16)                          │
│                                                              │
│  ┌────────────────┐               ┌──────────────────────┐ │
│  │ Public Subnets │               │ Private Subnets      │ │
│  │ 10.100.2.0/24  │               │ 10.100.1.0/24        │ │
│  └────────┬───────┘               └────────┬────────────┘ │
│           │                                │               │
│           │                      ┌────────▼───────┐        │
│           │                      │  NAT Gateway   │        │
│           │                      │  (per subnet)  │        │
│           │                      └────────┬───────┘        │
│           │                                │               │
│  ┌────────▼────────────┐                   │               │
│  │ DB Subnets (opt)    │                   │               │
│  │ 10.100.11.0/24 │                        │               │
│  └────────────────────┘                   │               │
│                                                              │
└─────────────────────────────────────────────────────────────┘
                           │
                           ▼
                    Internet Gateway
```

### Default IP Address Allocation Scheme

The module uses a standardized IP allocation scheme within the default `10.100.0.0/16` VNet to prevent overlaps:

| Subnet Type | IP Range | Purpose |
| --- | --- | --- |
| **Private** | `10.100.1.0/24` | Application servers, workloads |
| **Database** | `10.100.11.0/24` (optional) | Database servers |
| **Public** | `10.100.2.0/24` | Load balancers, public endpoints |

This allocation scheme:

- Provides clear separation between subnet types
- Leaves room for expansion within each category
- Prevents IP address overlap
- Follows a logical numbering pattern for easy identification

<p align="right">(<a href="#readme-top">back to top</a>)</p>

## Notes

- **Storage Account Naming**: The storage account for flow logs uses a timestamp in the name to ensure uniqueness. The lifecycle policy ignores changes to prevent recreation.
- **Network Watcher**: Azure typically has one Network Watcher per region per subscription. Consider using an existing one instead of creating a new one.
- **NAT Gateway Costs**: NAT Gateways incur costs. Use `single_nat_gateway = true` for development environments to reduce costs.
- **Service Endpoints**: Service endpoints are free but only work for Azure services. For on-premises connectivity, consider Azure Private Link.
- **Traffic Analytics**: Requires a Log Analytics workspace and incurs additional costs.
- **CIDR Rules**: VNet CIDR must be /16 and all subnets must be /24.

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
