######################################
# EC2 Instance Variables
######################################

variable "domain_name" {
  description = "Enables DHCP options for the VPC"
  type        = string
  default     = null
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

