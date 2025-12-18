######################################
# Azure ARM Template Deployment Variables
######################################

variable "deployment_name" {
  type        = string
  description = "(Optional) Name of the ARM template deployment in the resource group"
  default     = "avd-hostpool-workspace"
}

variable "resource_group_name" {
  type        = string
  description = "(Required) Name of the resource group where AVD resources will be created"
}

######################################
# Management vs Customer Mode
######################################

variable "is_management_host_pool" {
  type        = bool
  description = "Indicates whether the Azure AVD host pool is designated for management purposes. Set to true if the host pool is intended for administrative use, otherwise false"
  default     = false
}

variable "customer_short_name" {
  type        = string
  description = "(Required when is_management_host_pool = false) The abbreviated name of the customer"
  default     = ""

  validation {
    condition     = var.is_management_host_pool || length(trimspace(var.customer_short_name)) > 0
    error_message = "customer_short_name must be set when is_management_host_pool is false."
  }
}

variable "location_short_name" {
  type        = string
  description = "(Required) Short name for the Azure region used in naming (e.g., eu1, wu2)"

  validation {
    condition = contains(
      [
        "cu",
        "eu1",
        "eu2",
        "ncu",
        "scu",
        "wcu",
        "wu1",
        "wu2",
        "wu3",
        "uga",
        "ugt",
        "ugv",
      ],
      var.location_short_name
    )
    error_message = "location_short_name must be one of: cu, eu1, eu2, ncu, scu, wcu, wu1, wu2, wu3, uga, ugt, ugv."
  }
}

######################################
# Host Pool Settings
######################################

variable "hostpool_name" {
  type        = string
  description = "(Required) The name of the host pool to be created"
}

variable "hostpool_friendly_name" {
  type        = string
  description = "(Optional) The friendly name of the Host pool to be created"
  default     = ""
}

variable "hostpool_description" {
  type        = string
  description = "(Optional) The description of the Host pool to be created"
  default     = ""
}

variable "preferred_app_group_type" {
  type        = string
  description = "Preferred App Group type to display"
  default     = "Desktop"

  validation {
    condition     = contains(["Desktop", "RemoteApp"], var.preferred_app_group_type)
    error_message = "preferred_app_group_type must be Desktop or RemoteApp."
  }
}

variable "hostpool_type" {
  type        = string
  description = "Host pool type: Personal or Pooled"

  validation {
    condition     = contains(["Personal", "Pooled"], var.hostpool_type)
    error_message = "hostpool_type must be Personal or Pooled."
  }
}

variable "personal_desktop_assignment_type" {
  type        = string
  description = "(Required when hostpool_type = Personal) Set the type of assignment for a Personal host pool type"
  default     = ""

  validation {
    condition = (
      var.hostpool_type != "Personal" ||
      contains(["Automatic", "Direct"], var.personal_desktop_assignment_type)
    )
    error_message = "personal_desktop_assignment_type must be Automatic or Direct when hostpool_type is Personal."
  }
}

variable "max_session_limit" {
  type        = number
  description = "(Required when hostpool_type = Pooled) Maximum number of sessions"
  default     = 99999

  validation {
    condition     = var.max_session_limit > 0
    error_message = "max_session_limit must be greater than 0."
  }
}

variable "load_balancer_type" {
  type        = string
  description = "(Required when hostpool_type = Pooled) Type of load balancer algorithm"
  default     = "BreadthFirst"

  validation {
    condition     = contains(["BreadthFirst", "DepthFirst"], var.load_balancer_type)
    error_message = "load_balancer_type must be BreadthFirst or DepthFirst."
  }
}

variable "custom_rdp_property" {
  type        = string
  description = "Host pool rdp properties"
  default     = "enablerdsaadauth:i:1;enablecredsspsupport:i:1;videoplaybackmode:i:1;audiocapturemode:i:1;audiomode:i:0;camerastoredirect:s:*;devicestoredirect:s:;drivestoredirect:s:;redirectclipboard:i:0;redirectcomports:i:0;redirectprinters:i:0;redirectsmartcards:i:0;usbdevicestoredirect:s:;use multimon:i:1;dynamic resolution:i:1;autoreconnection enabled:i:0;bandwidthautodetect:i:1;networkautodetect:i:1;redirectwebauthn:i:1;"
}
