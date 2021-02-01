variable "name" {
  description = "Name of the DX Connection"
  type        = "string"  
  default     = ""
}

variable "bandwith" {
  description = "DX Connection Bandwidth 1Gbps or 10Gbps"
  default     = "1Gbps"
}

variable "location" {
    description  = "AWS Direct Connect location"
    default      = "EqDC2"
}