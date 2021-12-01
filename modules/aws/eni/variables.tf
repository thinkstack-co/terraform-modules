variable "attachment" {
  description = "Attachment block for assigning the eni to an instance"
  default     = []
}

variable "device_index" {
  description = "eni index to attach the eni to on the instance"
}

variable "instance_id" {
  description = "instance ID to attach to the eni"
}

variable "private_ips" {
  description = "Private IP to assign to the eni"
  default     = []
}

variable "private_ips_count" {
  description = "Number of private IPs to assign to the eni"
  default     = 1
}

variable "security_groups" {
  description = "Security groups to assign to the eni"
  default     = []
}

variable "source_dest_check" {
  description = "Whether to enable source destination checking for the eni"
  default     = true
}

variable "subnet_id" {
  type        = string
  description = "Subnet ID to create the eni in"
}

variable "tags" {
  description = "tags to assign to the eni"
  type        = map
}
