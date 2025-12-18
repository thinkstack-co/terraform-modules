# Setting the required version of Terraform and Azure provider
terraform {
  required_version = ">= 1.0.0"
  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = ">= 3.0.0"
    }
  }
}

###########################
# Data Sources (Conditional)
###########################
# These data sources are now CONDITIONAL to avoid redundant API calls.

# Only fetch subscription from Azure if not passed as a variable (backward compatible)
data "azurerm_subscription" "current" {
  count = var.azure_subscription_id == null ? 1 : 0
  # count = 0: Variable provided, skip API call (fast path)
  # count = 1: Variable is null, query Azure (backward compatible path)
}

# Only fetch resource group location if not passed as a variable
data "azurerm_resource_group" "vm" {
  count = var.location == null ? 1 : 0
  name  = var.resource_group_name
}

###########################
# Local Values
###########################

locals {
  # Use passed azure_subscription_id variable if provided, otherwise query from data source
  azure_subscription_id = var.azure_subscription_id != null ? var.azure_subscription_id : data.azurerm_subscription.current[0].subscription_id

  # Use passed location variable if provided, otherwise query from resource group
  location = var.location != null ? var.location : data.azurerm_resource_group.vm[0].location
}

#############################
# Network Interface
#############################
# Creating a network interface for the VM
resource "azurerm_network_interface" "vm" {
  name                = "${var.name}-nic"
  location            = local.location
  resource_group_name = var.resource_group_name
  tags                = merge(var.tags, { "Name" = var.name })

  ip_configuration {
    name                          = "internal"
    subnet_id                     = var.subnet_id
    private_ip_address_allocation = var.private_ip_address != null ? "Static" : "Dynamic"
    private_ip_address            = var.private_ip_address
    public_ip_address_id          = var.public_ip_address_id
  }

  accelerated_networking_enabled = var.enable_accelerated_networking
  ip_forwarding_enabled          = var.enable_ip_forwarding
}

#############################
# Azure Virtual Machine
#############################
# Creating an Azure VM with various parameters specified in the module variables.
# Reference variables.tf for questions about arguments
resource "azurerm_linux_virtual_machine" "vm" {
  count = var.os_type == "Linux" ? 1 : 0

  name                            = var.name
  resource_group_name             = var.resource_group_name
  location                        = local.location
  size                            = var.vm_size
  admin_username                  = var.admin_username
  disable_password_authentication = var.disable_password_authentication
  admin_password                  = var.disable_password_authentication ? null : var.admin_password
  network_interface_ids           = [azurerm_network_interface.vm.id]
  availability_set_id             = var.availability_set_id
  zone                            = var.zone
  tags                            = merge(var.tags, { "Name" = var.name })

  # SSH key configuration for Linux VMs
  dynamic "admin_ssh_key" {
    for_each = var.disable_password_authentication && var.ssh_public_key != null ? [1] : []
    content {
      username   = var.admin_username
      public_key = var.ssh_public_key
    }
  }

  os_disk {
    name                 = "${var.name}-osdisk"
    caching              = var.os_disk_caching
    storage_account_type = var.os_disk_storage_account_type
    disk_size_gb         = var.os_disk_size_gb
  }

  # Source image reference
  dynamic "source_image_reference" {
    for_each = var.source_image_id == null ? [1] : []
    content {
      publisher = local.selected_publisher
      offer     = local.selected_offer
      sku       = local.selected_sku
      version   = var.source_image_version
    }
  }

  source_image_id = var.source_image_id

  # Boot diagnostics
  dynamic "boot_diagnostics" {
    for_each = var.enable_boot_diagnostics ? [1] : []
    content {
      storage_account_uri = var.boot_diagnostics_storage_account_uri
    }
  }

  # Custom data (user data equivalent)
  custom_data = var.custom_data_base64 != null ? var.custom_data_base64 : (var.custom_data != null ? base64encode(var.custom_data) : null)

  # Identity configuration
  dynamic "identity" {
    for_each = var.identity_type != null ? [1] : []
    content {
      type         = var.identity_type
      identity_ids = var.identity_type == "UserAssigned" || var.identity_type == "SystemAssigned, UserAssigned" ? var.identity_ids : null
    }
  }

  lifecycle {
    ignore_changes = [source_image_reference, source_image_id, custom_data]
  }
}

# Windows VM resource
resource "azurerm_windows_virtual_machine" "vm" {
  count = var.os_type == "Windows" ? 1 : 0

  name                  = var.name
  resource_group_name   = var.resource_group_name
  location              = local.location
  size                  = var.vm_size
  admin_username        = var.admin_username
  admin_password        = var.admin_password
  network_interface_ids = [azurerm_network_interface.vm.id]
  availability_set_id   = var.availability_set_id
  zone                  = var.zone
  tags                  = merge(var.tags, { "Name" = var.name })

  os_disk {
    name                 = "${var.name}-osdisk"
    caching              = var.os_disk_caching
    storage_account_type = var.os_disk_storage_account_type
    disk_size_gb         = var.os_disk_size_gb
  }

  # Source image reference
  dynamic "source_image_reference" {
    for_each = var.source_image_id == null ? [1] : []
    content {
      publisher = local.selected_publisher
      offer     = local.selected_offer
      sku       = local.selected_sku
      version   = var.source_image_version
    }
  }

  source_image_id = var.source_image_id

  # Boot diagnostics
  dynamic "boot_diagnostics" {
    for_each = var.enable_boot_diagnostics ? [1] : []
    content {
      storage_account_uri = var.boot_diagnostics_storage_account_uri
    }
  }

  # Custom data (user data equivalent)
  custom_data = var.custom_data_base64 != null ? var.custom_data_base64 : (var.custom_data != null ? base64encode(var.custom_data) : null)

  # Identity configuration
  dynamic "identity" {
    for_each = var.identity_type != null ? [1] : []
    content {
      type         = var.identity_type
      identity_ids = var.identity_type == "UserAssigned" || var.identity_type == "SystemAssigned, UserAssigned" ? var.identity_ids : null
    }
  }

  lifecycle {
    ignore_changes = [source_image_reference, source_image_id, custom_data]
  }
}

###################################################
# Azure Monitor Metric Alerts (CloudWatch equivalent)
###################################################
# Creating Azure Monitor metric alerts for VM health monitoring
# These are equivalent to AWS CloudWatch alarms

# VM Availability Alert (equivalent to StatusCheckFailed_Instance)
resource "azurerm_monitor_metric_alert" "vm_availability" {
  name                = "${var.name}-vm-availability-alert"
  resource_group_name = var.resource_group_name
  scopes              = [var.os_type == "Linux" ? azurerm_linux_virtual_machine.vm[0].id : azurerm_windows_virtual_machine.vm[0].id]
  description         = "Alert when VM availability drops below threshold"
  severity            = 1
  enabled             = var.enable_monitoring_alerts

  criteria {
    metric_namespace = "Microsoft.Compute/virtualMachines"
    metric_name      = "VmAvailabilityMetric"
    aggregation      = "Average"
    operator         = "LessThan"
    threshold        = 1

    # Alert if VM is unavailable for 2 consecutive 1-minute periods
    dimension {
      name     = "VMName"
      operator = "Include"
      values   = [var.name]
    }
  }

  frequency   = "PT1M"
  window_size = "PT5M"

  action {
    action_group_id = var.action_group_id
  }

  tags = merge(var.tags, { "Name" = var.name })
}

# CPU Percentage Alert (additional monitoring)
resource "azurerm_monitor_metric_alert" "cpu_percentage" {
  count = var.enable_cpu_alert ? 1 : 0

  name                = "${var.name}-cpu-percentage-alert"
  resource_group_name = var.resource_group_name
  scopes              = [var.os_type == "Linux" ? azurerm_linux_virtual_machine.vm[0].id : azurerm_windows_virtual_machine.vm[0].id]
  description         = "Alert when CPU percentage exceeds threshold"
  severity            = 2
  enabled             = var.enable_monitoring_alerts

  criteria {
    metric_namespace = "Microsoft.Compute/virtualMachines"
    metric_name      = "Percentage CPU"
    aggregation      = "Average"
    operator         = "GreaterThan"
    threshold        = var.cpu_alert_threshold
  }

  frequency   = "PT1M"
  window_size = "PT5M"

  action {
    action_group_id = var.action_group_id
  }

  tags = merge(var.tags, { "Name" = var.name })
}

# Memory Percentage Alert (if available)
resource "azurerm_monitor_metric_alert" "memory_percentage" {
  count = var.enable_memory_alert ? 1 : 0

  name                = "${var.name}-memory-percentage-alert"
  resource_group_name = var.resource_group_name
  scopes              = [var.os_type == "Linux" ? azurerm_linux_virtual_machine.vm[0].id : azurerm_windows_virtual_machine.vm[0].id]
  description         = "Alert when memory percentage exceeds threshold"
  severity            = 2
  enabled             = var.enable_monitoring_alerts

  criteria {
    metric_namespace = "Microsoft.Compute/virtualMachines"
    metric_name      = "Available Memory Bytes"
    aggregation      = "Average"
    operator         = "LessThan"
    threshold        = var.memory_alert_threshold_bytes
  }

  frequency   = "PT1M"
  window_size = "PT5M"

  action {
    action_group_id = var.action_group_id
  }

  tags = merge(var.tags, { "Name" = var.name })
}

# Disk Read/Write Operations Alert
resource "azurerm_monitor_metric_alert" "disk_operations" {
  count = var.enable_disk_alert ? 1 : 0

  name                = "${var.name}-disk-operations-alert"
  resource_group_name = var.resource_group_name
  scopes              = [var.os_type == "Linux" ? azurerm_linux_virtual_machine.vm[0].id : azurerm_windows_virtual_machine.vm[0].id]
  description         = "Alert when disk operations exceed threshold"
  severity            = 2
  enabled             = var.enable_monitoring_alerts

  criteria {
    metric_namespace = "Microsoft.Compute/virtualMachines"
    metric_name      = "Disk Read Operations/Sec"
    aggregation      = "Average"
    operator         = "GreaterThan"
    threshold        = var.disk_operations_threshold
  }

  frequency   = "PT1M"
  window_size = "PT5M"

  action {
    action_group_id = var.action_group_id
  }

  tags = merge(var.tags, { "Name" = var.name })
}
