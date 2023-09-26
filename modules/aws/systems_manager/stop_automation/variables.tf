# Maintenance Window Variables

variable "mw_allow_unassociated_targets" {
  description = "Whether targets must be registered with the Maintenance Window before tasks can be defined for those targets."
  type        = bool
  default     = false
}

variable "mw_cutoff" {
  description = "The number of hours before the end of the Maintenance Window that Systems Manager stops scheduling new tasks for execution."
  type        = number
}

variable "mw_description" {
  description = "A description for the maintenance window."
  type        = string
  default     = null
}

variable "mw_duration" {
  description = "The duration of the Maintenance Window in hours."
  type        = number
}

variable "mw_enabled" {
  description = "Whether the maintenance window is enabled."
  type        = bool
  default     = true
}

variable "mw_end_date" {
  description = "Timestamp in ISO-8601 extended format when to no longer run the maintenance window."
  type        = string
  default     = null
}

variable "mw_name" {
  description = "The name of the maintenance window."
  type        = string
}

variable "mw_schedule" {
  description = "The schedule of the Maintenance Window in the form of a cron or rate expression."
  type        = string
}

variable "mw_schedule_offset" {
  description = "The number of days to wait after the date and time specified by a CRON expression before running the maintenance window."
  type        = number
  default     = null
}

variable "mw_schedule_timezone" {
  description = "Timezone for schedule in Internet Assigned Numbers Authority (IANA) Time Zone Database format."
  type        = string
  default     = null
}

variable "mw_start_date" {
  description = "Timestamp in ISO-8601 extended format when to begin the maintenance window."
  type        = string
  default     = null
}

variable "mw_tags" {
  description = "A map of tags to assign to the resource."
  type        = map(string)
  default     = {}
}

# Maintenance Window Target Variables

variable "target_description" {
  description = "The description of the maintenance window target."
  type        = string
  default     = null
}

variable "target_details" {
  description = "The targets to register with the maintenance window. Specify targets using instance IDs, resource group names, or tags that have been applied to instances."
  type        = list(object({
    key    = string
    values = list(string)
  }))
}

variable "target_name" {
  description = "(Optional) The name of the maintenance window target."
  type        = string
  default     = null
}

variable "target_owner_information" {
  description = "User-provided value that will be included in any CloudWatch events raised while running tasks for these targets in this Maintenance Window."
  type        = string
  default     = null
}

variable "target_resource_type" {
  description = "The type of target being registered with the Maintenance Window. Possible values are INSTANCE and RESOURCE_GROUP."
  type        = string
}

variable "start_order" {
  description = "The list of EC2 instance IDs to start in order."
  type        = list(string)
}

# Maintenance Window Task Variables

variable "stop_order" {
  description = "The list of EC2 instance IDs to start in order."
  type        = list(string)
}

variable "window_id" {
  description = "The ID of the maintenance window to register the task with."
  type        = string
  default     = "" # Provide a default if you wish or leave it empty
}

variable "max_concurrency" {
  description = "The maximum number of targets this task can be run for in parallel."
  type        = string
  default     = "1"
}

variable "max_errors" {
  description = "The maximum number of errors allowed before this task stops being scheduled."
  type        = string
  default     = "1"
}
