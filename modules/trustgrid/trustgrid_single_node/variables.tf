variable "instance_profile_name" {
  type        = string
  description = "IAM Instance Profile the Trustgrid EC2 node will use"
}

variable "license" {
  type        = string
  description = "The Trustgrid license given from the API or Portal"
}

variable "trustgrid_log_group_name" {
  type        = string
  description = "The log group where a log stream will be created for cloudwatch to write /var/log/trustgrid/tg-default.log"
}

variable "syslog_log_group_name" {
  type        = string
  description = "The log group where a log stream will be created for cloudwatch to write /var/log/syslog"
}

variable "management_subnet_id" {
  type        = list(string)
  description = "Subnet ID for management traffic (needs to be able to reach the internet)"
}

variable "management_security_group_ids" {
  type        = list
  description = "Security group IDs for the management interface"
}

variable "data_subnet_id" {
  type        = list(string)
  description = "Subnet ID for data traffic"
}

variable "data_security_group_ids" {
  type        = list
  description = "Security group IDs for the data interface"
}

#variable "data_ip" {
#  type        = string
#  description = "Data IP"
#}

variable "name" {
  type        = string
  description = "Instance name"
}

variable "instance_type" {
  type        = string
  description = "Node instance type"
  default     = "t3.small"

  validation {
    condition     = contains(["t3.small", "t3.medium", "t3.large", "t3.xlarge","t3a.small", "t3a.medium", "t3a.large", "t3a.xlarge"], var.instance_type)
    error_message = "Instance type must be t3.small, t3.medium, t3.large, or t3.xlarge."
  }
}

variable key_pair_name {
  type        = string
  description = "AWS Key Pair for ubuntu user in EC2 instance"
}

variable root_block_device_encrypt {
  type = bool
  description = "Should the root device be encrypted in AWS"
  default = true
}

variable root_block_device_size {
  type = number
  description = "Size of the root volume in GB"
  default = 30 
}

variable is_tggateway {
  type = bool
  description = "Determines if security group should allow tcp/udp port 8443 inbound for Trustgrid Tunnels"
  default = false
}

variable is_wggateway {
  type = bool
  description = "Determines if security group should allow port 51820 inbound for Wireguard"
  default = false
}

variable is_appgateway {
  type = bool
  description = "Determines if security group should allow port 443 inbound for Application Gateway"
  default = false
}