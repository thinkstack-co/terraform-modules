# Azure Blob Storage Terraform Module

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

<h3 align="center">Azure Blob Storage Module</h3>
  <p align="center">
    This module provisions an Azure Storage Account and optional Blob containers with configurable access settings.
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

This Terraform module creates an Azure Storage Account with Blob storage enabled and optional Blob containers.

The module supports:

- Storage account configuration (tier, replication, access tier)
- TLS and HTTPS enforcement
- Public network access controls
- Advanced storage settings (HNS, SFTP, NFS, encryption)
- Managed identity
- Blob properties configuration (versioning, change feed, retention)
- Static website hosting
- Custom domain mapping
- Routing configuration
- Optional storage account network rules
- Optional private endpoint with Private DNS zone integration
- Optional Blob container creation with access settings
- Resource tagging

<p align="right">(<a href="#readme-top">back to top</a>)</p>

<!-- USAGE EXAMPLES -->

## Usage

### Basic Example

```hcl
module "blob_storage" {
  source = "github.com/thinkstack-co/terraform-modules//modules/azure/terraform_modules/storage/blob_storage"

  # Required settings
  storage_account_name = "mystorageacctdev"
  resource_group_name  = "rg-storage"
  location             = "eastus"

  # Optional containers
  containers = {
    logs = {
      access_type = "private"
    }
    public = {
      access_type = "blob"
    }
  }

  # Tags
  tags = {
    terraform   = "true"
    created_by  = "Terraform"
    environment = "dev"
  }
}
```

### Complete Example (All Features)

```hcl
module "blob_storage_complete" {
  source = "github.com/thinkstack-co/terraform-modules//modules/azure/terraform_modules/storage/blob_storage"

  storage_account_name = "mystorageacctfull"
  resource_group_name  = "rg-storage"
  location             = "eastus"

  account_tier             = "Standard"
  account_replication_type = "ZRS"
  account_kind             = "StorageV2"
  access_tier              = "Hot"

  min_tls_version               = "TLS1_2"
  enable_https_traffic_only     = true
  public_network_access_enabled = false
  allow_nested_items_to_be_public = false

  enable_hns                       = true
  enable_sftp                      = true
  enable_nfs_v3                    = false
  enable_infrastructure_encryption = true
  enable_cross_tenant_replication  = false
  enable_shared_key_access         = false
  default_to_oauth_authentication  = true

  enable_identity = true
  identity_type   = "SystemAssigned"

  enable_blob_properties            = true
  blob_versioning_enabled           = true
  blob_change_feed_enabled          = true
  blob_last_access_time_enabled     = true
  blob_default_service_version      = "2020-06-12"
  blob_delete_retention_days        = 30
  blob_container_delete_retention_days = 30

  enable_static_website             = true
  static_website_index_document     = "index.html"
  static_website_error_404_document = "404.html"

  enable_custom_domain        = true
  custom_domain_name          = "storage.example.com"
  custom_domain_use_subdomain = false

  enable_routing                      = true
  routing_choice                      = "MicrosoftRouting"
  routing_publish_internet_endpoints  = false
  routing_publish_microsoft_endpoints = true

  enable_network_rules                   = true
  network_rules_default_action           = "Deny"
  network_rules_bypass                   = ["AzureServices"]
  network_rules_ip_rules                 = ["203.0.113.10"]
  network_rules_virtual_network_subnet_ids = [azurerm_subnet.private.id]

  enable_private_endpoint              = true
  private_endpoint_subnet_id           = azurerm_subnet.private.id
  private_dns_zone_id                  = azurerm_private_dns_zone.blob.id

  containers = {
    logs = {
      access_type = "private"
    }
    public = {
      access_type = "blob"
    }
  }

  tags = {
    terraform   = "true"
    created_by  = "Terraform"
    environment = "production"
  }
}
```

### Private Endpoint with Network Rules

```hcl
module "blob_storage_private_endpoint" {
  source = "github.com/thinkstack-co/terraform-modules//modules/azure/terraform_modules/storage/blob_storage"

  storage_account_name = "mystorageacctpe"
  resource_group_name  = "rg-storage"
  location             = "eastus"

  public_network_access_enabled   = false
  allow_nested_items_to_be_public = false

  enable_network_rules                   = true
  network_rules_default_action           = "Deny"
  network_rules_bypass                   = ["AzureServices"]
  network_rules_virtual_network_subnet_ids = [azurerm_subnet.private.id]

  enable_private_endpoint     = true
  private_endpoint_subnet_id  = azurerm_subnet.private.id
  private_dns_zone_id         = azurerm_private_dns_zone.blob.id

  containers = {
    data = {
      access_type = "private"
    }
  }
}
```

### Private Storage Account with No Public Access

```hcl
module "blob_storage_private" {
  source = "github.com/thinkstack-co/terraform-modules//modules/azure/terraform_modules/storage/blob_storage"

  # Required settings
  storage_account_name = "mystorageacctprod"
  resource_group_name  = "rg-storage"
  location             = "eastus"

  # Security settings
  public_network_access_enabled   = false
  allow_nested_items_to_be_public = false

  # Containers
  containers = {
    backups = {
      access_type = "private"
    }
  }

  # Tags
  tags = {
    terraform   = "true"
    created_by  = "Terraform"
    environment = "production"
  }
}
```

### Argument Reference

- `storage_account_name` - (Required) The globally unique name of the storage account.
- `resource_group_name` - (Required) The name of the resource group in which to create the storage account.
- `location` - (Optional) The Azure region where resources will be created. Default is `eastus`.
- `account_tier` - (Optional) The storage account tier. Valid values are `Standard` or `Premium`.
- `account_replication_type` - (Optional) The replication type (LRS, GRS, RAGRS, ZRS, GZRS, RAGZRS).
- `account_kind` - (Optional) The storage account kind. Default is `StorageV2`.
- `access_tier` - (Optional) The access tier for BlobStorage or StorageV2 accounts (`Hot` or `Cool`).
- `min_tls_version` - (Optional) The minimum TLS version. Default is `TLS1_2`.
- `enable_https_traffic_only` - (Optional) Enforce HTTPS-only traffic. Default is `true`.
- `public_network_access_enabled` - (Optional) Enable public network access. Default is `true`.
- `allow_nested_items_to_be_public` - (Optional) Allow public access to nested items. Default is `false`.
- `enable_hns` - (Optional) Enable hierarchical namespace (Data Lake Gen2). Default is `false`.
- `enable_sftp` - (Optional) Enable SFTP (requires HNS). Default is `false`.
- `enable_nfs_v3` - (Optional) Enable NFS v3 (requires HNS). Default is `false`.
- `enable_infrastructure_encryption` - (Optional) Enable infrastructure encryption. Default is `false`.
- `enable_cross_tenant_replication` - (Optional) Enable cross-tenant replication. Default is `true`.
- `enable_shared_key_access` - (Optional) Enable shared key access. Default is `true`.
- `default_to_oauth_authentication` - (Optional) Default to OAuth authentication. Default is `false`.
- `enable_identity` - (Optional) Enable managed identity. Default is `false`.
- `identity_type` - (Optional) Managed identity type. Default is `SystemAssigned`.
- `identity_ids` - (Optional) List of user-assigned identity IDs. Default is `[]`.
- `enable_blob_properties` - (Optional) Enable blob properties configuration. Default is `false`.
- `blob_versioning_enabled` - (Optional) Enable blob versioning. Default is `false`.
- `blob_change_feed_enabled` - (Optional) Enable blob change feed. Default is `false`.
- `blob_last_access_time_enabled` - (Optional) Enable last access time tracking. Default is `false`.
- `blob_default_service_version` - (Optional) Default service version. Default is `null`.
- `blob_delete_retention_days` - (Optional) Delete retention in days (1-365). Default is `null`.
- `blob_container_delete_retention_days` - (Optional) Container delete retention in days (1-365). Default is `null`.
- `enable_static_website` - (Optional) Enable static website hosting. Default is `false`.
- `static_website_index_document` - (Optional) Static website index document. Default is `index.html`.
- `static_website_error_404_document` - (Optional) Static website error document. Default is `404.html`.
- `enable_custom_domain` - (Optional) Enable custom domain mapping. Default is `false`.
- `custom_domain_name` - (Optional) Custom domain name. Default is `null`.
- `custom_domain_use_subdomain` - (Optional) Use subdomain for custom domain. Default is `false`.
- `enable_routing` - (Optional) Enable routing configuration. Default is `false`.
- `routing_choice` - (Optional) Routing choice (MicrosoftRouting or InternetRouting). Default is `MicrosoftRouting`.
- `routing_publish_internet_endpoints` - (Optional) Publish internet endpoints. Default is `false`.
- `routing_publish_microsoft_endpoints` - (Optional) Publish Microsoft endpoints. Default is `false`.
- `enable_network_rules` - (Optional) Enable storage account network rules. Default is `false`.
- `network_rules_default_action` - (Optional) Default action for network rules (`Allow` or `Deny`).
- `network_rules_bypass` - (Optional) Services that bypass network rules.
- `network_rules_ip_rules` - (Optional) List of public IPs or CIDRs to allow.
- `network_rules_virtual_network_subnet_ids` - (Optional) List of subnet IDs to allow.
- `network_rules_private_link_access` - (Optional) Private link access list.
- `enable_private_endpoint` - (Optional) Enable a private endpoint. Default is `false`.
- `private_endpoint_name` - (Optional) Name of the private endpoint.
- `private_endpoint_subnet_id` - (Optional) Subnet ID for the private endpoint (required when enabled).
- `private_endpoint_resource_group_name` - (Optional) Resource group name for the private endpoint.
- `private_endpoint_location` - (Optional) Location for the private endpoint.
- `private_dns_zone_id` - (Optional) Private DNS zone ID for blob private endpoint integration.
- `containers` - (Optional) Map of container names to access settings (private, blob, container).
- `tags` - (Optional) A map of tags to assign to resources.

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

| Name                                                                                                                                      | Type     | Documentation                                                                                     |
| ----------------------------------------------------------------------------------------------------------------------------------------- | -------- | ------------------------------------------------------------------------------------------------- |
| [azurerm_storage_account.storage](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/storage_account)        | resource | [Azure Documentation](https://learn.microsoft.com/azure/storage/common/storage-account-overview)  |
| [azurerm_storage_container.containers](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/storage_container) | resource | [Azure Documentation](https://learn.microsoft.com/azure/storage/blobs/storage-blobs-introduction) |

<p align="right">(<a href="#readme-top">back to top</a>)</p>

<!-- INPUTS -->

## Inputs

| Name                                     | Description                                                           | Type                                                                           | Default                  | Required |
| ---------------------------------------- | --------------------------------------------------------------------- | ------------------------------------------------------------------------------ | ------------------------ | :------: |
| storage_account_name                     | The globally unique name of the storage account                       | `string`                                                                       | n/a                      |   yes    |
| resource_group_name                      | The name of the resource group in which to create the storage account | `string`                                                                       | n/a                      |   yes    |
| location                                 | The Azure region where resources will be created                      | `string`                                                                       | `"eastus"`               |    no    |
| account_tier                             | The storage account tier                                              | `string`                                                                       | `"Standard"`             |    no    |
| account_replication_type                 | The storage account replication type                                  | `string`                                                                       | `"LRS"`                  |    no    |
| account_kind                             | The storage account kind                                              | `string`                                                                       | `"StorageV2"`            |    no    |
| access_tier                              | The access tier for BlobStorage or StorageV2 accounts                 | `string`                                                                       | `"Hot"`                  |    no    |
| min_tls_version                          | The minimum TLS version                                               | `string`                                                                       | `"TLS1_2"`               |    no    |
| enable_https_traffic_only                | Enforce HTTPS-only traffic                                            | `bool`                                                                         | `true`                   |    no    |
| public_network_access_enabled            | Enable public network access                                          | `bool`                                                                         | `true`                   |    no    |
| allow_nested_items_to_be_public          | Allow public access to nested items                                   | `bool`                                                                         | `false`                  |    no    |
| enable_network_rules                     | Enable storage account network rules                                  | `bool`                                                                         | `false`                  |    no    |
| network_rules_default_action             | Default action for network rules                                      | `string`                                                                       | `"Deny"`                 |    no    |
| network_rules_bypass                     | Services that bypass network rules                                    | `list(string)`                                                                 | `["AzureServices"]`      |    no    |
| network_rules_ip_rules                   | List of public IPs or CIDRs to allow                                  | `list(string)`                                                                 | `[]`                     |    no    |
| network_rules_virtual_network_subnet_ids | List of subnet IDs to allow                                           | `list(string)`                                                                 | `[]`                     |    no    |
| network_rules_private_link_access        | Private link access list                                              | `list(object({ endpoint_resource_id = string, endpoint_tenant_id = string }))` | `[]`                     |    no    |
| enable_private_endpoint                  | Enable a private endpoint                                             | `bool`                                                                         | `false`                  |    no    |
| private_endpoint_name                    | Name of the private endpoint                                          | `string`                                                                       | `null`                   |    no    |
| private_endpoint_subnet_id               | Subnet ID for the private endpoint                                    | `string`                                                                       | `null`                   |    no    |
| private_endpoint_resource_group_name     | Resource group name for the private endpoint                          | `string`                                                                       | `null`                   |    no    |
| private_endpoint_location                | Location for the private endpoint                                     | `string`                                                                       | `null`                   |    no    |
| private_dns_zone_id                      | Private DNS zone ID for blob private endpoint integration             | `string`                                                                       | `null`                   |    no    |
| containers                               | Map of container names to access settings                             | `map(object({ access_type = string }))`                                        | `{}`                     |    no    |
| tags                                     | A mapping of tags to assign to the resources                          | `map(any)`                                                                     | `{ terraform = "true" }` |    no    |

## Outputs

| Name                        | Description                                                 |
| --------------------------- | ----------------------------------------------------------- |
| storage_account_id          | The ID of the storage account                               |
| storage_account_name        | The name of the storage account                             |
| primary_blob_endpoint       | The primary blob endpoint URL                               |
| primary_connection_string   | The primary connection string for the storage account       |
| primary_access_key          | The primary access key for the storage account              |
| container_ids               | Map of container names to container IDs                     |
| private_endpoint_id         | The ID of the private endpoint (if created)                 |
| private_endpoint_name       | The name of the private endpoint (if created)               |
| private_endpoint_private_ip | The private IP address of the private endpoint (if created) |
| private_dns_zone_group_id   | The ID of the private DNS zone group (if created)           |

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
