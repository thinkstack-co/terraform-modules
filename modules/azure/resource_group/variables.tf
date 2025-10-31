###########################
# Resource Group Variables
###########################

variable "name" {
  description = "(Required) The name of the resource group. Must be unique within the Azure subscription."
  type        = string
}

variable "location" {
  description = "(Required) The Azure region where the resource group will be created."
  type        = string
  default     = "eastus"
}

variable "tags" {
  type        = map(string)
  description = "(Optional) A mapping of tags to assign to the resource group."
  default = {
    terraform   = "true"
    created_by  = "ThinkStack"
    environment = "prod"
    priority    = "high"
  }
}
