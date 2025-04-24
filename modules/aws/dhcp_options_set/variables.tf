######################################
# EC2 Instance Variables
######################################

variable "domain_name" {
  description = "Define the domain name for the DHCP Options Set"
  type        = string
  default     = null
}

variable "enable_dhcp_options" {
  description = "(Optional) boolean to determine if DHCP options are enabled"
  type        = bool
  default     = true
  validation {
    condition     = can(regex("true|false", var.enable_dhcp_options))
    error_message = "The value must be either true or false."
  }
}
variable "domain_name_servers" {
  description = "List of IP addresses for the DNS servers"
  type        = list(string)
  default     = ["10.11.1.100", "10.11.2.100"]
}

variable "ntp_servers" {
  description = "List of IP addresses for the NTP servers"
  type        = list(string)
  default     = ["10.11.1.100", "10.11.2.100"]
}

variable "tags" {
  type        = map(any)
  description = "(Optional) A mapping of tags to assign to the object."
  default = {
    Name        = "prod_dhcp_options_set"
    terraform   = "true"
    created_by  = "ThinkStack"
    environment = "prod"
    description = "DHCP Option Set for the VPC"
  }
}

variable "vpc_id" {
  description = "ID of the VPC to attach the DHCP Options Set to"
  type        = string
  default     = null
}

