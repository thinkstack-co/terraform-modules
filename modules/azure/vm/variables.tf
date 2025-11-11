######################################
# Azure VM Variables
######################################

variable "name" {
  type        = string
  description = "Name to be used for the VM and related resources"
}

variable "resource_group_name" {
  type        = string
  description = "Name of the resource group where the VM will be created"
}

variable "location" {
  type        = string
  description = "(Optional) Azure region where the VM will be created. If not provided, will use the resource group location"
  default     = null
}

variable "vm_size" {
  type        = string
  description = "The size of the Virtual Machine (e.g., Standard_D2s_v3, Standard_B2ms)"
}

variable "os_type" {
  type        = string
  description = "Operating system type: Linux or Windows"
  validation {
    condition     = can(regex("^(Linux|Windows)$", var.os_type))
    error_message = "The value must be either Linux or Windows."
  }
}

variable "admin_username" {
  type        = string
  description = "The admin username for the VM"
  default     = "azureuser"
}

variable "admin_password" {
  type        = string
  description = "The admin password for the VM (required for Windows, optional for Linux if SSH key is provided)"
  default     = null
  sensitive   = true
}

variable "disable_password_authentication" {
  type        = bool
  description = "Should password authentication be disabled for Linux VMs? (Only applicable to Linux)"
  default     = true
  validation {
    condition     = can(regex("^(true|false)$", var.disable_password_authentication))
    error_message = "The value must be either true or false."
  }
}

variable "ssh_public_key" {
  type        = string
  description = "SSH public key for Linux VM authentication (required if disable_password_authentication is true)"
  default     = null
}

######################################
# Network Variables
######################################

variable "subnet_id" {
  type        = string
  description = "The ID of the subnet where the VM's network interface will be created"
}

variable "private_ip_address" {
  type        = string
  description = "(Optional) Static private IP address for the VM. If not provided, a dynamic IP will be assigned"
  default     = null
}

variable "public_ip_address_id" {
  type        = string
  description = "(Optional) ID of a public IP address to associate with the VM"
  default     = null
}

variable "enable_accelerated_networking" {
  type        = bool
  description = "Enable accelerated networking for the network interface (requires supported VM size)"
  default     = false
  validation {
    condition     = can(regex("^(true|false)$", var.enable_accelerated_networking))
    error_message = "The value must be either true or false."
  }
}

variable "enable_ip_forwarding" {
  type        = bool
  description = "Enable IP forwarding on the network interface (useful for NVAs)"
  default     = false
  validation {
    condition     = can(regex("^(true|false)$", var.enable_ip_forwarding))
    error_message = "The value must be either true or false."
  }
}

######################################
# OS Disk Variables
######################################

variable "os_disk_caching" {
  type        = string
  description = "The caching type for the OS disk (None, ReadOnly, ReadWrite)"
  default     = "ReadWrite"
  validation {
    condition     = can(regex("^(None|ReadOnly|ReadWrite)$", var.os_disk_caching))
    error_message = "The value must be None, ReadOnly, or ReadWrite."
  }
}

variable "os_disk_storage_account_type" {
  type        = string
  description = "The storage account type for the OS disk (Standard_LRS, StandardSSD_LRS, Premium_LRS, Premium_ZRS)"
  default     = "Premium_LRS"
  validation {
    condition     = can(regex("^(Standard_LRS|StandardSSD_LRS|Premium_LRS|Premium_ZRS|StandardSSD_ZRS)$", var.os_disk_storage_account_type))
    error_message = "The value must be Standard_LRS, StandardSSD_LRS, Premium_LRS, Premium_ZRS, or StandardSSD_ZRS."
  }
}

variable "os_disk_size_gb" {
  type        = number
  description = "The size of the OS disk in gigabytes"
  default     = 128
}

######################################
# Source Image Variables
######################################

variable "os_version" {
  type        = string
  description = <<-EOT
    (Optional) Simplified OS version selection. When provided, automatically sets source_image_publisher, 
    source_image_offer, and source_image_sku. If not provided, you must specify those variables manually.
    
    Supported Windows versions:
    - "2025-datacenter" - Windows Server 2025 Datacenter
    - "2025-datacenter-core" - Windows Server 2025 Datacenter Core
    - "2022-datacenter" - Windows Server 2022 Datacenter
    - "2022-datacenter-core" - Windows Server 2022 Datacenter Core
    - "2022-datacenter-azure-edition" - Windows Server 2022 Datacenter Azure Edition
    - "2019-datacenter" - Windows Server 2019 Datacenter
    - "2019-datacenter-core" - Windows Server 2019 Datacenter Core
    - "2016-datacenter" - Windows Server 2016 Datacenter
    
    Supported Linux versions:
    - "ubuntu-22.04" - Ubuntu 22.04 LTS
    - "ubuntu-20.04" - Ubuntu 20.04 LTS
    - "rhel-9" - Red Hat Enterprise Linux 9
    - "rhel-8" - Red Hat Enterprise Linux 8
    - "debian-12" - Debian 12
    - "debian-11" - Debian 11
  EOT
  default     = null
}

variable "source_image_id" {
  type        = string
  description = "(Optional) The ID of a custom image to use. If provided, source_image_* variables and os_version are ignored"
  default     = null
}

variable "source_image_publisher" {
  type        = string
  description = "Publisher of the image (e.g., Canonical, MicrosoftWindowsServer)"
  default     = "Canonical"
}

variable "source_image_offer" {
  type        = string
  description = "Offer of the image (e.g., UbuntuServer, WindowsServer)"
  default     = "0001-com-ubuntu-server-jammy"
}

variable "source_image_sku" {
  type        = string
  description = "SKU of the image (e.g., 22_04-lts-gen2, 2022-datacenter-azure-edition)"
  default     = "22_04-lts-gen2"
}

variable "source_image_version" {
  type        = string
  description = "Version of the image (use 'latest' for the most recent version)"
  default     = "latest"
}

######################################
# Availability Variables
######################################

variable "availability_set_id" {
  type        = string
  description = "(Optional) ID of the availability set to place the VM in"
  default     = null
}

variable "zone" {
  type        = string
  description = "(Optional) Availability zone to place the VM in (1, 2, or 3)"
  default     = null
}

######################################
# Boot Diagnostics Variables
######################################

variable "enable_boot_diagnostics" {
  type        = bool
  description = "Enable boot diagnostics for the VM"
  default     = true
  validation {
    condition     = can(regex("^(true|false)$", var.enable_boot_diagnostics))
    error_message = "The value must be either true or false."
  }
}

variable "boot_diagnostics_storage_account_uri" {
  type        = string
  description = "(Optional) Storage account URI for boot diagnostics. If not provided, managed storage will be used"
  default     = null
}

######################################
# Custom Data Variables
######################################

variable "custom_data" {
  type        = string
  description = "Custom data (user data) to provide when launching the VM (will be base64 encoded automatically)"
  default     = null
}

variable "custom_data_base64" {
  type        = string
  description = "Pre-encoded base64 custom data to provide when launching the VM"
  default     = null
}

######################################
# Identity Variables
######################################

variable "identity_type" {
  type        = string
  description = "(Optional) Type of managed identity (SystemAssigned, UserAssigned, or SystemAssigned, UserAssigned)"
  default     = null
  validation {
    condition     = var.identity_type == null || can(regex("^(SystemAssigned|UserAssigned|SystemAssigned, UserAssigned)$", var.identity_type))
    error_message = "The value must be SystemAssigned, UserAssigned, or 'SystemAssigned, UserAssigned'."
  }
}

variable "identity_ids" {
  type        = list(string)
  description = "(Optional) List of user assigned identity IDs (required if identity_type includes UserAssigned)"
  default     = null
}

######################################
# Monitoring Variables
######################################

variable "enable_monitoring_alerts" {
  type        = bool
  description = "Enable Azure Monitor metric alerts for the VM"
  default     = true
  validation {
    condition     = can(regex("^(true|false)$", var.enable_monitoring_alerts))
    error_message = "The value must be either true or false."
  }
}

variable "action_group_id" {
  type        = string
  description = "ID of the Azure Monitor action group to use for alerts"
  default     = null
}

variable "enable_cpu_alert" {
  type        = bool
  description = "Enable CPU percentage alert"
  default     = true
  validation {
    condition     = can(regex("^(true|false)$", var.enable_cpu_alert))
    error_message = "The value must be either true or false."
  }
}

variable "cpu_alert_threshold" {
  type        = number
  description = "CPU percentage threshold for alerting"
  default     = 80
}

variable "enable_memory_alert" {
  type        = bool
  description = "Enable memory alert (requires Azure Monitor agent)"
  default     = false
  validation {
    condition     = can(regex("^(true|false)$", var.enable_memory_alert))
    error_message = "The value must be either true or false."
  }
}

variable "memory_alert_threshold_bytes" {
  type        = number
  description = "Available memory bytes threshold for alerting"
  default     = 1073741824 # 1 GB in bytes
}

variable "enable_disk_alert" {
  type        = bool
  description = "Enable disk operations alert"
  default     = false
  validation {
    condition     = can(regex("^(true|false)$", var.enable_disk_alert))
    error_message = "The value must be either true or false."
  }
}

variable "disk_operations_threshold" {
  type        = number
  description = "Disk operations per second threshold for alerting"
  default     = 1000
}

######################################
# Tags Variable
######################################

variable "tags" {
  type        = map(string)
  description = "A mapping of tags to assign to the resources"
  default     = {}
}

######################################
# Performance Optimization Variables
######################################
# These variables are optional performance optimizations to reduce redundant Azure API calls.
# When multiple module instances are deployed, each module traditionally queries Azure for
# subscription information independently, resulting in duplicate API calls.
# 
# By passing these values as variables from the root module (which queries once), we can:
# - Reduce API calls significantly in large deployments
# - Improve terraform plan/apply speed
# - Reduce risk of Azure API rate limiting
# - Decrease network latency during Terraform operations
#
# These variables are OPTIONAL and maintain backward compatibility:
# - If provided: Uses the passed values (fast, no API call)
# - If null: Falls back to querying Azure directly (slow, but works with old code)

variable "azure_subscription_id" {
  type        = string
  description = <<-EOT
    (Optional) Azure subscription ID to use instead of querying via data source.
    
    PERFORMANCE OPTIMIZATION: Pass this value from the root module to avoid redundant 
    Azure API calls. In deployments with many module instances, this can reduce plan time 
    and eliminate duplicate API calls.
    
    Example in root module:
      data "azurerm_subscription" "current" {}
      
      module "vm" {
        source                 = "..."
        azure_subscription_id  = data.azurerm_subscription.current.subscription_id  # Pass once, reuse everywhere
      }
    
    If not provided, the module will query Azure directly (backward compatible).
  EOT
  default     = null
}
