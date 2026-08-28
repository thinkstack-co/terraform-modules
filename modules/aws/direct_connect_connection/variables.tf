variable "name" {
  description = "(Required) Name of the Direct Connect connection."
  type        = string
}

variable "bandwidth" {
  description = "(Required) Bandwidth of the Direct Connect connection (e.g. 1Gbps, 10Gbps)."
  type        = string
}

variable "location" {
  description = "(Required) AWS Direct Connect location code where the connection terminates (e.g. EqDC2)."
  type        = string
}

variable "tags" {
  description = "Tags to apply to the Direct Connect connection"
  type        = map(string)
  default     = {}
}
