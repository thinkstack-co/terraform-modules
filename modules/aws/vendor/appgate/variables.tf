###############################################################################
# Customer Environment (Required)
###############################################################################

variable "client_abbreviation" {
  type        = string
  description = "Client abbreviation for naming (e.g., 'nc', 'dcc')"

  validation {
    condition     = can(regex("^[a-zA-Z][a-zA-Z0-9]{1,9}$", var.client_abbreviation))
    error_message = "Must be 2-10 alphanumeric characters starting with a letter."
  }
}

variable "customer_name" {
  type        = string
  description = "Full customer name for Appgate labels (e.g., 'Dubin Clark')"
}

variable "vpc_id" {
  type        = string
  description = "VPC ID from the customer's VPC module"
}

variable "subnet_id" {
  type        = string
  description = "Public subnet ID for the gateway"
}

variable "key_pair_name" {
  type        = string
  description = "Existing AWS key pair name in the customer environment"
}

###############################################################################
# Naming
###############################################################################

variable "gateway_index" {
  type        = number
  description = "Gateway number (1 = AGGW01, 2 = AGGW02, etc.)"
  default     = 1

  validation {
    condition     = var.gateway_index >= 1 && var.gateway_index <= 99
    error_message = "Must be 1-99."
  }
}

variable "vpc_identifier" {
  type        = string
  description = "VPC label for SG naming (e.g., 'vpc01')"
  default     = "vpc01"
}

variable "subnet_index" {
  type        = number
  description = "Subnet number for ENI naming"
  default     = 1
}

###############################################################################
# Security Group
###############################################################################

variable "netcov_appgate_ip" {
  type        = string
  description = "NetCov management IPv4 address for SSH + 8443"
  default     = "3.138.92.59"

  validation {
    condition     = can(regex("^(\\d{1,3}\\.){3}\\d{1,3}$", var.netcov_appgate_ip))
    error_message = "Must be a valid IPv4 address (e.g., 3.138.92.59)."
  }
}

variable "additional_admin_cidrs" {
  type        = map(string)
  description = "Engineer IPs for SSH + 8443. Key = name, value = x.x.x.x/32"
  default = {
    "netcov_1" = "3.138.92.59/32"
    "netcov_2" = "3.83.5.218/32"
    "netcov_3" = "50.18.17.253/32"
  }
}

###############################################################################
# EC2
###############################################################################

variable "instance_type" {
  type        = string
  description = "Instance type per Appgate sizing guide. t3.medium for <500 users."
  default     = "t3.medium"
}

variable "ami_id" {
  type        = string
  description = "Explicit AMI ID. Null = auto-discover latest Appgate SDP BYOL."
  default     = null
}

variable "root_volume_size" {
  type        = number
  description = "Root volume GiB"
  default     = 100
}

variable "root_volume_iops" {
  type        = number
  description = "gp3 IOPS"
  default     = 3000
}

variable "root_volume_throughput" {
  type        = number
  description = "gp3 throughput MiB/s"
  default     = 125
}

variable "kms_key_id" {
  type        = string
  description = "KMS key for EBS encryption. Null = default aws/ebs."
  default     = null
}

###############################################################################
# Tags
###############################################################################

variable "map_migrated_value" {
  type        = string
  description = "MAP tracking tag"
  default     = "d-server-03jpm34ivsp1f1"
}

variable "additional_tags" {
  type        = map(string)
  description = "Extra tags applied to all resources"
  default     = {}
}

###############################################################################
# Appgate SDP
###############################################################################

variable "manage_appgate_appliance" {
  type        = bool
  description = "Register this gateway in the Appgate controller"
  default     = false
}

variable "appgate_site_id" {
  type        = string
  description = "Appgate Site ID for this gateway"
  default     = null
}

variable "tunnel_destinations" {
  type = list(object({
    address = string
    netmask = number
  }))
  description = "Subnets reachable through the gateway tunnel"
  default     = []
}

variable "appgate_tags" {
  type        = list(string)
  description = "Appgate appliance tags"
  default     = ["autoscale"]
}

variable "appgate_seed_json" {
  type        = string
  description = "Seed JSON from Appgate controller. Null = skip auto-seeding."
  default     = null
  sensitive   = true
}

variable "private_key_pem" {
  type        = string
  description = "PEM key for SSH seed provisioning. Must match key_pair_name."
  default     = null
  sensitive   = true
}
