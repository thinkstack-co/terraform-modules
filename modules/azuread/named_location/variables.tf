variable "display_name" {
  description = "(Required) The friendly name for this named location."
  type        = string
}

variable "ip_ranges" {
  description = "(Required) List of IP address ranges in IPv4 CIDR format (e.g. 1.2.3.4/32) or any allowable IPv6 format from IETF RFC596."
  type = list
  default = null
}

variable "trusted" {
  description = "(Optional) Whether the named location is trusted. Defaults to false."
  type = bool
  default = false
}

variable "countries_and_regions" {
  description = "(Required) List of countries and/or regions in two-letter format specified by ISO 3166-2."
  type = list
  default = null
}

variable "include_unknown_countries_and_regions" {
  description = "(Optional) Whether IP addresses that don't map to a country or region should be included in the named location. Defaults to false."
  type = bool
  default = false
}
