<!-- Blank module readme template: Do a search and replace with your text editor for the following: `module_name`, `module_description` -->
<!-- Improved compatibility of back to top link: See: https://github.com/othneildrew/Best-README-Template/pull/73 -->
<a name="readme-top"></a>


<!-- PROJECT SHIELDS -->
<!--
*** I'm using markdown "reference style" links for readability.
*** Reference links are enclosed in brackets [ ] instead of parentheses ( ).
*** See the bottom of this document for the declaration of the reference variables
*** for contributors-url, forks-url, etc. This is an optional, concise syntax you may use.
*** https://www.markdownguide.org/basic-syntax/#reference-style-links
-->
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

<h3 align="center">Azure Managed Disk Module</h3>
  <p align="center">
    This module creates and configures an Azure Managed Disk with optional attachment to a Virtual Machine. This is the Azure equivalent of an AWS EBS volume.
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
    <li><a href="#usage">Usage</a></li>
    <li><a href="#requirements">Requirements</a></li>
    <li><a href="#providers">Providers</a></li>
    <li><a href="#modules">Modules</a></li>
    <li><a href="#Resources">Resources</a></li>
    <li><a href="#inputs">Inputs</a></li>
    <li><a href="#outputs">Outputs</a></li>
    <li><a href="#license">License</a></li>
    <li><a href="#contact">Contact</a></li>
    <li><a href="#acknowledgments">Acknowledgments</a></li>
  </ol>
</details>


<!-- USAGE EXAMPLES -->
## Usage

### Basic Example - Create and Attach a Data Disk
```hcl
module "app_server_data_disk" {
  source = "github.com/thinkstack-co/terraform-modules//modules/azure/terraform_modules/compute/managed_disk"

  name                 = "app-server-data-disk"
  location             = "eastus"
  resource_group_name  = "my-resource-group"
  storage_account_type = "StandardSSD_LRS"
  disk_size_gb         = 128
  virtual_machine_id   = azurerm_windows_virtual_machine.app_server.id
  lun                  = 0
  caching              = "ReadWrite"

  tags = {
    Name        = "app-server-data-disk"
    terraform   = "true"
    environment = "prod"
    role        = "app_server"
  }
}
```

### Premium SSD with Zone
```hcl
module "db_server_data_disk" {
  source = "github.com/thinkstack-co/terraform-modules//modules/azure/terraform_modules/compute/managed_disk"

  name                 = "db-server-data-disk"
  location             = "eastus"
  resource_group_name  = "my-resource-group"
  storage_account_type = "Premium_LRS"
  disk_size_gb         = 512
  zone                 = "1"
  virtual_machine_id   = azurerm_windows_virtual_machine.db_server.id
  lun                  = 0
  caching              = "None"  # Recommended for database workloads

  tags = {
    Name        = "db-server-data-disk"
    terraform   = "true"
    environment = "prod"
    role        = "database"
  }
}
```

### Ultra SSD with Custom IOPS and Throughput
```hcl
module "high_performance_disk" {
  source = "github.com/thinkstack-co/terraform-modules//modules/azure/terraform_modules/compute/managed_disk"

  name                 = "high-perf-data-disk"
  location             = "eastus"
  resource_group_name  = "my-resource-group"
  storage_account_type = "UltraSSD_LRS"
  disk_size_gb         = 1024
  disk_iops_read_write = 50000
  disk_mbps_read_write = 1000
  zone                 = "1"
  virtual_machine_id   = azurerm_windows_virtual_machine.high_perf_server.id
  lun                  = 0
  caching              = "None"  # Ultra disks only support None caching

  tags = {
    Name        = "high-perf-data-disk"
    terraform   = "true"
    environment = "prod"
    role        = "high_performance"
  }
}
```

### Disk with Encryption Set
```hcl
module "encrypted_disk" {
  source = "github.com/thinkstack-co/terraform-modules//modules/azure/terraform_modules/compute/managed_disk"

  name                   = "encrypted-data-disk"
  location               = "eastus"
  resource_group_name    = "my-resource-group"
  storage_account_type   = "Premium_LRS"
  disk_size_gb           = 256
  disk_encryption_set_id = azurerm_disk_encryption_set.example.id
  virtual_machine_id     = azurerm_windows_virtual_machine.secure_server.id
  lun                    = 0

  tags = {
    Name        = "encrypted-data-disk"
    terraform   = "true"
    environment = "prod"
    compliance  = "pci"
  }
}
```

### Shared Disk (Multi-Attach)
```hcl
module "shared_disk" {
  source = "github.com/thinkstack-co/terraform-modules//modules/azure/terraform_modules/compute/managed_disk"

  name                 = "cluster-shared-disk"
  location             = "eastus"
  resource_group_name  = "my-resource-group"
  storage_account_type = "Premium_LRS"
  disk_size_gb         = 256
  max_shares           = 2  # Allow 2 VMs to attach simultaneously
  zone                 = "1"

  # For shared disks, attach separately to each VM
  virtual_machine_id = null  # Don't auto-attach

  tags = {
    Name        = "cluster-shared-disk"
    terraform   = "true"
    environment = "prod"
    role        = "cluster"
  }
}
```

### Create Disk from Snapshot
```hcl
module "restored_disk" {
  source = "github.com/thinkstack-co/terraform-modules//modules/azure/terraform_modules/compute/managed_disk"

  name                 = "restored-data-disk"
  location             = "eastus"
  resource_group_name  = "my-resource-group"
  storage_account_type = "StandardSSD_LRS"
  create_option        = "Copy"
  source_resource_id   = azurerm_snapshot.example.id
  virtual_machine_id   = azurerm_windows_virtual_machine.restored_server.id
  lun                  = 0

  tags = {
    Name            = "restored-data-disk"
    terraform       = "true"
    environment     = "prod"
    restored_from   = "snapshot"
  }
}
```

### Disk Without Attachment (Standalone)
```hcl
module "standalone_disk" {
  source = "github.com/thinkstack-co/terraform-modules//modules/azure/terraform_modules/compute/managed_disk"

  name                 = "backup-data-disk"
  location             = "eastus"
  resource_group_name  = "my-resource-group"
  storage_account_type = "Standard_LRS"
  disk_size_gb         = 1024

  # No attachment - disk will be created but not attached to any VM
  virtual_machine_id = null

  tags = {
    Name        = "backup-data-disk"
    terraform   = "true"
    environment = "prod"
    purpose     = "backup"
  }
}
```

_For more examples, please refer to the [Documentation](https://github.com/thinkstack-co/terraform-modules)_

<p align="right">(<a href="#readme-top">back to top</a>)</p>

<!-- terraform-docs output will be input automatically below-->
<!-- terraform-docs markdown table --output-file README.md --output-mode inject .-->
<!-- BEGIN_TF_DOCS -->
## Requirements

| Name | Version |
|------|---------|
| <a name="requirement_terraform"></a> [terraform](#requirement\_terraform) | >= 1.0.0 |
| <a name="requirement_azurerm"></a> [azurerm](#requirement\_azurerm) | >= 3.0.0 |

## Providers

| Name | Version |
|------|---------|
| <a name="provider_azurerm"></a> [azurerm](#provider\_azurerm) | >= 3.0.0 |

## Modules

No modules.

## Resources

| Name | Type |
|------|------|
| [azurerm_managed_disk.disk](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/managed_disk) | resource |
| [azurerm_virtual_machine_data_disk_attachment.attachment](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/virtual_machine_data_disk_attachment) | resource |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_name"></a> [name](#input\_name) | (Required) The name of the managed disk. | `string` | n/a | yes |
| <a name="input_location"></a> [location](#input\_location) | (Required) The Azure location where the managed disk should exist. | `string` | n/a | yes |
| <a name="input_resource_group_name"></a> [resource\_group\_name](#input\_resource\_group\_name) | (Required) The name of the resource group in which to create the managed disk. | `string` | n/a | yes |
| <a name="input_storage_account_type"></a> [storage\_account\_type](#input\_storage\_account\_type) | (Required) The type of storage to use. Options: Standard\_LRS, StandardSSD\_ZRS, Premium\_LRS, PremiumV2\_LRS, Premium\_ZRS, StandardSSD\_LRS, UltraSSD\_LRS. | `string` | `"StandardSSD_LRS"` | no |
| <a name="input_create_option"></a> [create\_option](#input\_create\_option) | (Required) The method to use when creating the disk. Options: Import, ImportSecure, Empty, Copy, FromImage, Restore, Upload, UploadSecure. | `string` | `"Empty"` | no |
| <a name="input_disk_size_gb"></a> [disk\_size\_gb](#input\_disk\_size\_gb) | (Optional) The size of the managed disk in GB. | `number` | `128` | no |
| <a name="input_zone"></a> [zone](#input\_zone) | (Optional) The Availability Zone in which the disk should be located (1, 2, or 3). | `string` | `null` | no |
| <a name="input_disk_iops_read_write"></a> [disk\_iops\_read\_write](#input\_disk\_iops\_read\_write) | (Optional) The number of IOPS. Only for UltraSSD and PremiumV2\_LRS disks. | `number` | `null` | no |
| <a name="input_disk_mbps_read_write"></a> [disk\_mbps\_read\_write](#input\_disk\_mbps\_read\_write) | (Optional) The bandwidth in MB/s. Only for UltraSSD and PremiumV2\_LRS disks. | `number` | `null` | no |
| <a name="input_disk_encryption_set_id"></a> [disk\_encryption\_set\_id](#input\_disk\_encryption\_set\_id) | (Optional) The ID of a Disk Encryption Set for customer-managed key encryption. | `string` | `null` | no |
| <a name="input_max_shares"></a> [max\_shares](#input\_max\_shares) | (Optional) Maximum number of VMs that can attach (enables shared disk). | `number` | `null` | no |
| <a name="input_source_resource_id"></a> [source\_resource\_id](#input\_source\_resource\_id) | (Optional) The ID of a snapshot or disk to copy when create\_option is Copy or Restore. | `string` | `null` | no |
| <a name="input_virtual_machine_id"></a> [virtual\_machine\_id](#input\_virtual\_machine\_id) | (Optional) The ID of the VM to attach the disk to. Set to null for standalone disk. | `string` | `null` | no |
| <a name="input_lun"></a> [lun](#input\_lun) | (Required when attaching) The Logical Unit Number (0-63) for the disk attachment. | `number` | `0` | no |
| <a name="input_caching"></a> [caching](#input\_caching) | (Optional) Caching requirements: None, ReadOnly, or ReadWrite. | `string` | `"ReadWrite"` | no |
| <a name="input_tags"></a> [tags](#input\_tags) | (Optional) A mapping of tags to assign to the resource. | `map(any)` | `{"terraform": "true"}` | no |

## Outputs

| Name | Description |
| ------ | ------------- |
| <a name="output_id"></a> [id](#output\_id) | The ID of the Managed Disk. |
| <a name="output_name"></a> [name](#output\_name) | The name of the Managed Disk. |
| <a name="output_disk_size_gb"></a> [disk\_size\_gb](#output\_disk\_size\_gb) | The size of the Managed Disk in GB. |
| <a name="output_storage_account_type"></a> [storage\_account\_type](#output\_storage\_account\_type) | The storage account type of the Managed Disk. |
| <a name="output_zone"></a> [zone](#output\_zone) | The Availability Zone of the Managed Disk. |
| <a name="output_attachment_id"></a> [attachment\_id](#output\_attachment\_id) | The ID of the VM Data Disk attachment. |
| <a name="output_lun"></a> [lun](#output\_lun) | The LUN assigned to the attached disk. |
<!-- END_TF_DOCS -->

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
