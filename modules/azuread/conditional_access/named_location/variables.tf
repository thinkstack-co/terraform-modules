variable "display_name" {
  type        = string
  description = "(Required) The friendly name for this named location."
}

variable "country" {
  type = list(object({
    countries_and_regions                 = list(string)
    include_unknown_countries_and_regions = bool
  }))
  description = "(Optional) A list of countries and regions to include in the named location."
  default     = null
}

variable "ip" {
  type = list(object({
    ip_ranges = list(string)
    trusted   = bool
  }))
  description = "(Optional) A list of IP ranges to include in the named location."
  default     = null
}
