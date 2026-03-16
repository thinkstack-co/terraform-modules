variable "resource_group_name" {
  description = "Resource group for all AIB resources (identity, template, staging)."
  type        = string
}

variable "location" {
  description = "Azure Government region."
  type        = string
}

variable "customer_name" {
  description = "Short customer name for resource naming."
  type        = string
}

variable "subscription_id" {
  description = "Azure subscription ID (used for role assignment scope)."
  type        = string
}

variable "gallery_image_definition_id" {
  description = "Resource ID of the Compute Gallery image definition to publish versions into."
  type        = string
}

variable "source_image_sku" {
  description = "Marketplace SKU for the Win11 Multi-Session base image."
  type        = string
  default     = "win11-24h2-avd"
}

variable "tags" {
  description = "Tags applied to all resources."
  type        = map(string)
  default     = {}
}
