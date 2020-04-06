variable "availability_zone" {
  description = "The AZ where the EBS volume will exist"
}

variable "encrypted" {
  description = "Whether or not the ebs volume will be encrypted"
  default     = true
}

variable "iops" {
  description = "iops to provision"
  default     = ""
}

variable "size" {
  type        = string
  description = "size of the ebs volume"
}

variable "snapshot_id" {
  type        = string
  description = "snapshot id to base the volume from"
  default     = ""
}

variable "type" {
  type        = string
  description = "ebs volume type (example gp2, io1, standard, sc1, st1)"
  default     = "gp2"
}

variable "tags" {
  description = "tags to assign to the ebs volume"
  default     = {}
}

variable "device_name" {
  type        = string
  description = "The device name to expose to the instance (for example, /dev/sdh or xvdf)"
  default     = "xvdf"
}

variable "instance_id" {
  type        = string
  description = "ID of the instance to attach to"
}
