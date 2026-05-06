variable "resource_group_name" {
  description = "Name of the resource group to deploy into."
  type        = string
}

variable "location" {
  description = "Azure Government region."
  type        = string
}

variable "gallery_name" {
  description = "Name of the Azure Compute Gallery."
  type        = string
}

variable "image_definitions" {
  description = "Map of image definition name → configuration."
  type = map(object({
    os_type                     = string # "Windows" or "Linux"
    hyper_v_generation          = string # "V1" or "V2"
    publisher                   = string
    offer                       = string
    sku                         = string
    trusted_launch_enabled      = optional(bool, true)
    accelerated_network_enabled = optional(bool, true)
  }))
  default = {
    "win11-multisession" = {
      os_type            = "Windows"
      hyper_v_generation = "V2"
      publisher          = "NetworkCoverage"
      offer              = "Windows11"
      sku                = "MultiSession"
    }
    "win11-singlesession" = {
      os_type            = "Windows"
      hyper_v_generation = "V2"
      publisher          = "NetworkCoverage"
      offer              = "Windows11"
      sku                = "SingleSession"
    }
  }
}

variable "tags" {
  description = "Tags applied to all resources."
  type        = map(string)
  default     = {}
}
