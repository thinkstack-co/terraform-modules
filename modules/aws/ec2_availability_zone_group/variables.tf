variable "group_name" {
  description = "(Required) Name of the Availability Zone Group."
  type        = string
}

variable "opt_in_status" {
  description = "(Optional) Indicates whether to enable or disable Availability Zone Group. Valid values: opted-in or not-opted-in."
  type        = string
  default     = "opted-in"
}
