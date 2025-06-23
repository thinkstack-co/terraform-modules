variable "name" {
  description = "Name of the Direct Connect connection"
  type        = string
  default     = "tf-dx-connection"
}

variable "bandwidth" {
  description = "Bandwidth of the Direct Connect connection"
  type        = string
  default     = "1Gbps"
}

variable "location" {
  description = "Location of the Direct Connect connection"
  type        = string
  default     = "EqDC2"
}

variable "tags" {
  description = "Tags to apply to the Direct Connect connection"
  type        = map(string)
  default     = {}
}