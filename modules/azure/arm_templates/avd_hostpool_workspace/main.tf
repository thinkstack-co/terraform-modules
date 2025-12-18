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
# ARM Template Deployment
###########################
# This module deploys an ARM template "as an ARM template".
# The ARM template JSON is kept in this module folder as the source of truth.

resource "azurerm_resource_group_template_deployment" "avd" {
  name                = var.deployment_name
  resource_group_name = var.resource_group_name
  deployment_mode     = "Incremental"

  # Read the ARM template from disk
  template_content = file("${path.module}/avd_hostpool_workspace.json")

  # Wire Terraform variables into ARM parameters
  parameters_content = jsonencode({
    isManagementHostPool = {
      value = var.is_management_host_pool
    }

    customerShortName = {
      value = var.customer_short_name
    }

    locationShortName = {
      value = var.location_short_name
    }

    hostpoolName = {
      value = var.hostpool_name
    }

    hostpoolFriendlyName = {
      value = var.hostpool_friendly_name
    }

    hostpoolDescription = {
      value = var.hostpool_description
    }

    preferredAppGroupType = {
      value = var.preferred_app_group_type
    }

    hostpoolType = {
      value = var.hostpool_type
    }

    personalDesktopAssignmentType = {
      value = var.personal_desktop_assignment_type
    }

    maxSessionLimit = {
      value = var.max_session_limit
    }

    loadBalancerType = {
      value = var.load_balancer_type
    }

    customRdpProperty = {
      value = var.custom_rdp_property
    }
  })
}
