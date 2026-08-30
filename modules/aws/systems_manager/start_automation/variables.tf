# Variables for Maintenance Window for both Stopping and Starting EC2 Instances

variable "mw_name" {
  description = "The name of the maintenance window."
  type        = string
  default     = "MyMaintenanceWindow"
}

variable "mw_cutoff" {
  description = "The number of hours before the end of the Maintenance Window that Systems Manager stops scheduling new tasks for execution."
  type        = number
  default     = 1
}

variable "mw_duration" {
  description = "The duration of the Maintenance Window in hours."
  type        = number
  default     = 4
}

variable "mw_tags" {
  description = "Tags to apply to the Maintenance Window."
  type        = map(string)
  default     = {}
}

variable "mw_schedule_timezone" {
  description = "The time zone to use for the maintenance window. E.g., 'America/New_York'."
  type        = string
  default     = "UTC"
}

variable "target_resource_type" {
  description = "The type of resource you can specify when registering a target. Only 'INSTANCE' is currently supported."
  type        = string
  default     = "INSTANCE"
}

variable "target_details" {
  description = "The list of instance IDs that are targets for the maintenance window."
  type        = list(string)
  default     = []
}

# Variables specific to Stopping EC2 Instances

variable "mw_schedule_stop" {
  description = "The schedule for when to stop the EC2 instances, using cron or rate expressions."
  type        = string
  default     = "cron(0 22 ? * MON-FRI *)" # Example: 10 PM every weekday
}

variable "mw_description_stop" {
  description = "Description for the maintenance window for stopping instances."
  type        = string
  default     = "Maintenance window to stop EC2 instances."
}

variable "mw_allow_unassociated_targets_stop" {
  description = "Indicates whether targets must be registered with the Maintenance Window before tasks can be defined."
  type        = bool
  default     = true
}

variable "mw_enabled_stop" {
  description = "Indicates whether the maintenance window for stopping is enabled."
  type        = bool
  default     = true
}

variable "mw_end_date_stop" {
  description = "The end date of the maintenance window for stopping in the form YYYY-MM-DD. This can be left empty if there's no end date."
  type        = string
  default     = ""
}

variable "mw_schedule_offset_stop" {
  description = "The number of days to wait after the date and time specified by a CRON format to run the maintenance window for stopping."
  type        = number
  default     = 0
}

variable "mw_start_date_stop" {
  description = "The start date of the maintenance window for stopping in the form YYYY-MM-DD. This can be left empty if immediate start is desired."
  type        = string
  default     = ""
}

variable "target_name_stop" {
  description = "The name of the maintenance window target for stopping instances."
  type        = string
  default     = "StopTarget"
}

variable "stop_order" {
  description = "Order in which EC2 instances should be stopped."
  type        = list(string)
  default     = []
}

variable "stop_max_concurrency" {
  description = "The maximum number of instances to stop concurrently."
  type        = string
  default     = "1"
}

variable "stop_max_errors" {
  description = "The maximum number of errors allowed before stopping the automation."
  type        = string
  default     = "1"
}

# Variables specific to Starting EC2 Instances

variable "mw_schedule_start" {
  description = "The schedule for when to start the EC2 instances, using cron or rate expressions."
  type        = string
  default     = "cron(0 6 ? * MON-FRI *)" # Example: 6 AM every weekday
}

variable "mw_description_start" {
  description = "Description for the maintenance window for starting instances."
  type        = string
  default     = "Maintenance window to start EC2 instances."
}

variable "mw_allow_unassociated_targets_start" {
  description = "Indicates whether targets must be registered with the Maintenance Window before tasks can be defined for starting."
  type        = bool
  default     = true
}

variable "mw_enabled_start" {
  description = "Indicates whether the maintenance window for starting is enabled."
  type        = bool
  default     = true
}

variable "mw_end_date_start" {
  description = "The end date of the maintenance window for starting in the form YYYY-MM-DD. This can be left empty if there's no end date."
  type        = string
  default     = ""
}

variable "mw_schedule_offset_start" {
  description = "The number of days to wait after the date and time specified by a CRON format to run the maintenance window for starting."
  type        = number
  default     = 0
}

variable "mw_start_date_start" {
  description = "The start date of the maintenance window for starting in the form YYYY-MM-DD. This can be left empty if immediate start is desired."
  type        = string
  default     = ""
}

variable "target_name_start" {
  description = "The name of the maintenance window target for starting instances."
  type        = string
  default     = "StartTarget"
}

variable "start_order" {
  description = "Order in which EC2 instances should be started."
  type        = list(string)
  default     = []
}

variable "start_max_concurrency" {
  description = "The maximum number of instances to start concurrently."
  type        = string
  default     = "1"
}

variable "start_max_errors" {
  description = "The maximum number of errors allowed before stopping the start automation."
  type        = string
  default     = "1"
}
