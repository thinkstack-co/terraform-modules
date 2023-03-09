variable "associate_with_private_ip" {
  type        = string
  description = "(Optional) A user specified primary or secondary private IP address to associate with the Elastic IP address. If no private IP address is specified, the Elastic IP address is associated with the primary private IP address."
  default     = ""
}

variable "instance" {
  type        = string
  description = "(Optional) EC2 instance ID."
  default     = ""
}

variable "network_interface" {
  type        = string
  description = "(Optional) Network interface ID to associate with."
  default     = ""
}

variable "tags" {
  type        = map(any)
  description = "(Optional) A mapping of tags to assign to the resource."
  default     = {}
}

variable "vpc" {
  type        = string
  description = "(Optional) Boolean if the EIP is in a VPC or not."
  default     = true
}
