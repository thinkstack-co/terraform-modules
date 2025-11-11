# Azure Virtual Machine Terraform Module

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

<h3 align="center">Azure Virtual Machine Module</h3>
  <p align="center">
    This module creates an Azure Virtual Machine (Linux or Windows) with comprehensive monitoring through Azure Monitor metric alerts. It is the Azure equivalent of the AWS EC2 instance module.
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

This Terraform module creates and manages Azure Virtual Machines (both Linux and Windows). The module provides comprehensive VM configuration options including networking, storage, authentication, high availability, and monitoring through Azure Monitor metric alerts.

The module supports:
- Both Linux and Windows operating systems
- Static or dynamic IP addressing
- Accelerated networking for supported VM sizes
- Managed identities (system-assigned and user-assigned)
- Custom images or marketplace images
- Availability zones and availability sets
- Azure Monitor metric alerts (VM availability, CPU, memory, disk)
- Boot diagnostics for troubleshooting
- Cloud-init / custom data support

<p align="right">(<a href="#readme-top">back to top</a>)</p>

<!-- USAGE EXAMPLES -->
## Usage

### Basic Linux VM Example

```hcl
module "linux_vm" {
  source = "github.com/thinkstack-co/terraform-modules//modules/azure/vm"

  name                = "web-server-01"
  resource_group_name = "production-rg"
  location            = "eastus"
  vm_size             = "Standard_D2s_v3"
  os_type             = "Linux"

  # Network configuration
  subnet_id          = azurerm_subnet.main.id
  private_ip_address = "10.0.1.10"

  # Authentication
  admin_username                  = "azureuser"
  disable_password_authentication = true
  ssh_public_key                  = file("~/.ssh/id_rsa.pub")

  # Image configuration
  source_image_publisher = "Canonical"
  source_image_offer     = "0001-com-ubuntu-server-jammy"
  source_image_sku       = "22_04-lts-gen2"
  source_image_version   = "latest"

  # Monitoring
  enable_monitoring_alerts = true
  action_group_id          = azurerm_monitor_action_group.main.id

  tags = {
    terraform   = "true"
    created_by  = "Terraform"
    environment = "production"
  }
}
```

### Basic Windows VM Example

```hcl
module "windows_vm" {
  source = "github.com/thinkstack-co/terraform-modules//modules/azure/vm"

  name                = "app-server-01"
  resource_group_name = "production-rg"
  location            = "eastus"
  vm_size             = "Standard_D4s_v3"
  os_type             = "Windows"

  # Network configuration
  subnet_id          = azurerm_subnet.main.id
  private_ip_address = "10.0.1.20"

  # Authentication
  admin_username = "azureadmin"
  admin_password = var.admin_password

  # Image configuration
  source_image_publisher = "MicrosoftWindowsServer"
  source_image_offer     = "WindowsServer"
  source_image_sku       = "2022-datacenter-azure-edition"
  source_image_version   = "latest"

  # Storage
  os_disk_storage_account_type = "Premium_LRS"
  os_disk_size_gb              = 256

  # Monitoring
  enable_monitoring_alerts = true
  action_group_id          = azurerm_monitor_action_group.main.id

  tags = {
    terraform   = "true"
    created_by  = "Terraform"
    environment = "production"
  }
}
```

### Complete Example with All Features

```hcl
# This example demonstrates all available features and configuration options
module "advanced_vm" {
  source = "github.com/thinkstack-co/terraform-modules//modules/azure/vm"

  ###########################
  # Required Arguments
  ###########################
  name                = "advanced-vm-01"
  resource_group_name = "production-rg"
  vm_size             = "Standard_D8s_v5"
  os_type             = "Linux"
  subnet_id           = azurerm_subnet.main.id

  ###########################
  # Optional Location
  ###########################
  # location - Azure region where the VM will be created
  # If not provided, will use the resource group location
  location = "eastus"

  ###########################
  # Network Configuration
  ###########################
  # private_ip_address - Static private IP address for the VM
  # If not provided, a dynamic IP will be assigned
  private_ip_address = "10.0.1.30"

  # public_ip_address_id - ID of a public IP address to associate with the VM
  public_ip_address_id = azurerm_public_ip.vm.id

  # enable_accelerated_networking - Enable accelerated networking
  # Requires supported VM size (see locals.tf for supported sizes)
  # Provides up to 30 Gbps networking throughput and lower latency
  enable_accelerated_networking = true

  # enable_ip_forwarding - Enable IP forwarding on the network interface
  # Useful for Network Virtual Appliances (NVAs) like firewalls or routers
  enable_ip_forwarding = false

  ###########################
  # Authentication (Linux)
  ###########################
  admin_username                  = "azureuser"
  disable_password_authentication = true
  ssh_public_key                  = file("~/.ssh/id_rsa.pub")

  ###########################
  # OS Disk Configuration
  ###########################
  # os_disk_caching - The caching type for the OS disk
  # Options: None, ReadOnly, ReadWrite
  os_disk_caching = "ReadWrite"

  # os_disk_storage_account_type - The storage account type for the OS disk
  # Options: Standard_LRS (HDD), StandardSSD_LRS (SSD), Premium_LRS (Premium SSD)
  # Premium_LRS requires s-series VM sizes
  os_disk_storage_account_type = "Premium_LRS"

  # os_disk_size_gb - The size of the OS disk in gigabytes
  os_disk_size_gb = 512

  ###########################
  # Source Image Configuration
  ###########################
  # Option 1: Use a custom image
  source_image_id = "/subscriptions/xxx/resourceGroups/xxx/providers/Microsoft.Compute/images/custom-image"

  # Option 2: Use a marketplace image (comment out source_image_id above)
  # source_image_publisher = "Canonical"
  # source_image_offer     = "0001-com-ubuntu-server-jammy"
  # source_image_sku       = "22_04-lts-gen2"
  # source_image_version   = "latest"

  ###########################
  # High Availability
  ###########################
  # zone - Availability zone to place the VM in (1, 2, or 3)
  # Cannot be used with availability_set_id
  zone = "1"

  ###########################
  # Managed Identity
  ###########################
  # identity_type - Type of managed identity
  # Options: SystemAssigned, UserAssigned, or "SystemAssigned, UserAssigned"
  identity_type = "SystemAssigned"

  ###########################
  # Boot Diagnostics
  ###########################
  enable_boot_diagnostics              = true
  boot_diagnostics_storage_account_uri = azurerm_storage_account.diag.primary_blob_endpoint

  ###########################
  # Custom Data (Cloud-Init)
  ###########################
  # custom_data - Custom data to provide when launching the VM
  # Will be base64 encoded automatically
  # Limited to 64 KB, executed only on first boot
  custom_data = <<-EOF
    #cloud-config
    package_update: true
    package_upgrade: true
    packages:
      - nginx
      - docker.io
    runcmd:
      - systemctl enable nginx
      - systemctl start nginx
  EOF

  ###########################
  # Azure Monitor Alerts
  ###########################
  # enable_monitoring_alerts - Enable Azure Monitor metric alerts
  enable_monitoring_alerts = true

  # action_group_id - ID of the Azure Monitor action group
  # Action groups define who gets notified (email, SMS, webhook, etc.)
  action_group_id = azurerm_monitor_action_group.main.id

  # enable_cpu_alert - Enable CPU percentage alert
  enable_cpu_alert    = true
  cpu_alert_threshold = 85

  # enable_memory_alert - Enable memory alert
  # Note: Requires Azure Monitor agent to be installed on the VM
  enable_memory_alert           = true
  memory_alert_threshold_bytes  = 536870912 # 512 MB

  # enable_disk_alert - Enable disk operations alert
  enable_disk_alert         = true
  disk_operations_threshold = 1500

  ###########################
  # Performance Optimization
  ###########################
  # azure_subscription_id - Pass from root module to avoid redundant API calls
  azure_subscription_id = data.azurerm_subscription.current.subscription_id

  ###########################
  # Tags
  ###########################
  tags = {
    terraform   = "true"
    created_by  = "Terraform"
    environment = "production"
    role        = "advanced_app"
  }
}
```

### Argument Reference

#### Required Arguments

* `name` - (Required) Name to be used for the VM and related resources.
* `resource_group_name` - (Required) Name of the resource group where the VM will be created.
* `vm_size` - (Required) The size of the Virtual Machine (e.g., Standard_D2s_v3, Standard_B2ms).
* `os_type` - (Required) Operating system type: Linux or Windows.
* `subnet_id` - (Required) The ID of the subnet where the VM's network interface will be created.

#### Network Configuration

* `location` - (Optional) Azure region where the VM will be created. If not provided, will use the resource group location.
* `private_ip_address` - (Optional) Static private IP address for the VM. If not provided, a dynamic IP will be assigned.
* `public_ip_address_id` - (Optional) ID of a public IP address to associate with the VM.
* `enable_accelerated_networking` - (Optional) Enable accelerated networking for the network interface. Requires supported VM size. Default: `false`.
* `enable_ip_forwarding` - (Optional) Enable IP forwarding on the network interface. Useful for NVAs. Default: `false`.

#### Authentication

* `admin_username` - (Optional) The admin username for the VM. Default: `azureuser`.
* `admin_password` - (Optional) The admin password for the VM. Required for Windows, optional for Linux if SSH key is provided.
* `disable_password_authentication` - (Optional) Should password authentication be disabled for Linux VMs? Default: `true`.
* `ssh_public_key` - (Optional) SSH public key for Linux VM authentication. Required if disable_password_authentication is true.

#### OS Disk Configuration

* `os_disk_caching` - (Optional) The caching type for the OS disk (None, ReadOnly, ReadWrite). Default: `ReadWrite`.
* `os_disk_storage_account_type` - (Optional) The storage account type for the OS disk. Default: `Premium_LRS`.
* `os_disk_size_gb` - (Optional) The size of the OS disk in gigabytes. Default: `128`.

#### Source Image Configuration

* `source_image_id` - (Optional) The ID of a custom image to use. If provided, source_image_* variables are ignored.
* `source_image_publisher` - (Optional) Publisher of the image. Default: `Canonical`.
* `source_image_offer` - (Optional) Offer of the image. Default: `0001-com-ubuntu-server-jammy`.
* `source_image_sku` - (Optional) SKU of the image. Default: `22_04-lts-gen2`.
* `source_image_version` - (Optional) Version of the image. Default: `latest`.

#### High Availability

* `availability_set_id` - (Optional) ID of the availability set to place the VM in. Cannot be used with zone.
* `zone` - (Optional) Availability zone to place the VM in (1, 2, or 3). Cannot be used with availability_set_id.

#### Managed Identity

* `identity_type` - (Optional) Type of managed identity (SystemAssigned, UserAssigned, or "SystemAssigned, UserAssigned").
* `identity_ids` - (Optional) List of user assigned identity IDs. Required if identity_type includes UserAssigned.

#### Boot Diagnostics

* `enable_boot_diagnostics` - (Optional) Enable boot diagnostics for the VM. Default: `true`.
* `boot_diagnostics_storage_account_uri` - (Optional) Storage account URI for boot diagnostics. If not provided, managed storage will be used.

#### Custom Data

* `custom_data` - (Optional) Custom data to provide when launching the VM. Will be base64 encoded automatically.
* `custom_data_base64` - (Optional) Pre-encoded base64 custom data to provide when launching the VM.

#### Azure Monitor Alerts

* `enable_monitoring_alerts` - (Optional) Enable Azure Monitor metric alerts for the VM. Default: `true`.
* `action_group_id` - (Optional) ID of the Azure Monitor action group to use for alerts.
* `enable_cpu_alert` - (Optional) Enable CPU percentage alert. Default: `true`.
* `cpu_alert_threshold` - (Optional) CPU percentage threshold for alerting. Default: `80`.
* `enable_memory_alert` - (Optional) Enable memory alert (requires Azure Monitor agent). Default: `false`.
* `memory_alert_threshold_bytes` - (Optional) Available memory bytes threshold for alerting. Default: `1073741824` (1 GB).
* `enable_disk_alert` - (Optional) Enable disk operations alert. Default: `false`.
* `disk_operations_threshold` - (Optional) Disk operations per second threshold for alerting. Default: `1000`.

#### Performance Optimization

* `azure_subscription_id` - (Optional) Azure subscription ID to use instead of querying via data source. Pass from root module to avoid redundant API calls.

#### Tags

* `tags` - (Optional) A mapping of tags to assign to the resources. Default: `{}`.

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
| [azurerm_network_interface.vm](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/network_interface) | resource | [Azure Documentation](https://docs.microsoft.com/en-us/azure/virtual-network/virtual-network-network-interface) |
| [azurerm_linux_virtual_machine.vm](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/linux_virtual_machine) | resource | [Azure Documentation](https://docs.microsoft.com/en-us/azure/virtual-machines/linux/) |
| [azurerm_windows_virtual_machine.vm](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/windows_virtual_machine) | resource | [Azure Documentation](https://docs.microsoft.com/en-us/azure/virtual-machines/windows/) |
| [azurerm_monitor_metric_alert.vm_availability](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/monitor_metric_alert) | resource | [Azure Documentation](https://docs.microsoft.com/en-us/azure/azure-monitor/alerts/alerts-metric) |
| [azurerm_monitor_metric_alert.cpu_percentage](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/monitor_metric_alert) | resource | [Azure Documentation](https://docs.microsoft.com/en-us/azure/azure-monitor/alerts/alerts-metric) |
| [azurerm_monitor_metric_alert.memory_percentage](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/monitor_metric_alert) | resource | [Azure Documentation](https://docs.microsoft.com/en-us/azure/azure-monitor/alerts/alerts-metric) |
| [azurerm_monitor_metric_alert.disk_operations](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/monitor_metric_alert) | resource | [Azure Documentation](https://docs.microsoft.com/en-us/azure/azure-monitor/alerts/alerts-metric) |
| [azurerm_subscription.current](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/data-sources/subscription) | data source | [Azure Documentation](https://docs.microsoft.com/en-us/azure/azure-resource-manager/management/overview) |
| [azurerm_resource_group.vm](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/data-sources/resource_group) | data source | [Azure Documentation](https://docs.microsoft.com/en-us/azure/azure-resource-manager/management/manage-resource-groups-portal) |

<p align="right">(<a href="#readme-top">back to top</a>)</p>

<!-- INPUTS -->
## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| name | Name to be used for the VM and related resources | `string` | n/a | yes |
| resource_group_name | Name of the resource group where the VM will be created | `string` | n/a | yes |
| vm_size | The size of the Virtual Machine | `string` | n/a | yes |
| os_type | Operating system type: Linux or Windows | `string` | n/a | yes |
| subnet_id | The ID of the subnet where the VM's network interface will be created | `string` | n/a | yes |
| location | Azure region where the VM will be created | `string` | `null` | no |
| admin_username | The admin username for the VM | `string` | `"azureuser"` | no |
| admin_password | The admin password for the VM | `string` | `null` | no |
| disable_password_authentication | Should password authentication be disabled for Linux VMs? | `bool` | `true` | no |
| ssh_public_key | SSH public key for Linux VM authentication | `string` | `null` | no |
| private_ip_address | Static private IP address for the VM | `string` | `null` | no |
| public_ip_address_id | ID of a public IP address to associate with the VM | `string` | `null` | no |
| enable_accelerated_networking | Enable accelerated networking | `bool` | `false` | no |
| enable_ip_forwarding | Enable IP forwarding | `bool` | `false` | no |
| os_disk_caching | The caching type for the OS disk | `string` | `"ReadWrite"` | no |
| os_disk_storage_account_type | The storage account type for the OS disk | `string` | `"Premium_LRS"` | no |
| os_disk_size_gb | The size of the OS disk in gigabytes | `number` | `128` | no |
| source_image_id | The ID of a custom image to use | `string` | `null` | no |
| source_image_publisher | Publisher of the image | `string` | `"Canonical"` | no |
| source_image_offer | Offer of the image | `string` | `"0001-com-ubuntu-server-jammy"` | no |
| source_image_sku | SKU of the image | `string` | `"22_04-lts-gen2"` | no |
| source_image_version | Version of the image | `string` | `"latest"` | no |
| availability_set_id | ID of the availability set to place the VM in | `string` | `null` | no |
| zone | Availability zone to place the VM in | `string` | `null` | no |
| enable_boot_diagnostics | Enable boot diagnostics for the VM | `bool` | `true` | no |
| boot_diagnostics_storage_account_uri | Storage account URI for boot diagnostics | `string` | `null` | no |
| custom_data | Custom data to provide when launching the VM | `string` | `null` | no |
| custom_data_base64 | Pre-encoded base64 custom data | `string` | `null` | no |
| identity_type | Type of managed identity | `string` | `null` | no |
| identity_ids | List of user assigned identity IDs | `list(string)` | `null` | no |
| enable_monitoring_alerts | Enable Azure Monitor metric alerts | `bool` | `true` | no |
| action_group_id | ID of the Azure Monitor action group | `string` | `null` | no |
| enable_cpu_alert | Enable CPU percentage alert | `bool` | `true` | no |
| cpu_alert_threshold | CPU percentage threshold for alerting | `number` | `80` | no |
| enable_memory_alert | Enable memory alert | `bool` | `false` | no |
| memory_alert_threshold_bytes | Available memory bytes threshold | `number` | `1073741824` | no |
| enable_disk_alert | Enable disk operations alert | `bool` | `false` | no |
| disk_operations_threshold | Disk operations per second threshold | `number` | `1000` | no |
| tags | A mapping of tags to assign to the resources | `map(string)` | `{}` | no |
| azure_subscription_id | Azure subscription ID (performance optimization) | `string` | `null` | no |

## Outputs

| Name | Description |
|------|-------------|
| vm_id | ID of the virtual machine |
| vm_name | Name of the virtual machine |
| private_ip_address | Private IP address of the virtual machine |
| public_ip_address | Public IP address of the virtual machine (if assigned) |
| network_interface_id | ID of the network interface |
| availability_zone | Availability zone of the virtual machine |
| os_disk_id | ID of the OS disk |
| identity_principal_id | Principal ID of the system assigned managed identity |
| identity_tenant_id | Tenant ID of the system assigned managed identity |
| vm_availability_alert_id | ID of the VM availability alert |
| cpu_percentage_alert_id | ID of the CPU percentage alert |
| memory_percentage_alert_id | ID of the memory percentage alert |
| disk_operations_alert_id | ID of the disk operations alert |
| performance_optimization_info | Diagnostic information about performance optimization |
| vm_configuration_summary | Summary of the VM configuration |

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
