variable "bundle_id" {
    description = "the default bundle ID to use when creating an AWS workspace"
    default = "wsb-9jvhtb24f"
    type = string
}

variable "root_volume_size" {
    description = "the size of the root volume for the workspace"
    default     = "80"
    type        = string
}

variable "user_volume_size" {
    description = "the size of the user volume for the workspace"
    default     = "50"
    type        = string
}

variable "running_mode_type" {
    description = "the running mode of the workspace"
    default     = "AUTO_STOP"
    type        = string
}

variable "auto_stop_timeout" {
    description = "the auto stop configuration time out of auto stop instances"
    default     = "60"
    type        = string
}

variable "directory_id" {
    description = "the directory id of the workspaces directory; needs to be taken from the customer environment and passed through"
    default     = ""
    type        = string
}
variable "user_name" {
    description = "the user name of the user for the workspace"
    type        = string
}

variable "compute_type" {
    description = "the compute type of the amazon workspace"
    default     = "PERFORMANCE"
    type        = string
}