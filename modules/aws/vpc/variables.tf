variable "azs" {
  description = "A list of Availability zones in the region"
  default     = ["us-east-2a", "us-east-2b", "us-east-2c"]
}

variable "db_subnets_list" {
  description = "A list of database subnets inside the VPC."
  default     = ["10.11.11.0/24", "10.11.12.0/24", "10.11.13.0/24"]
}

variable "db_propagating_vgws" {
  description = "A list of VGWs the db route table should propagate."
  default     = []
}

variable "dmz_subnets_list" {
  description = "A list of DMZ subnets inside the VPC."
  default     = ["10.11.101.0/24", "10.11.102.0/24", "10.11.103.0/24"]
}

variable "dmz_propagating_vgws" {
  description = "A list of VGWs the DMZ route table should propagate."
  default     = []
}

variable "enable_dns_hostnames" {
  description = "should be true if you want to use private DNS within the VPC"
  default     = true
}

variable "enable_dns_support" {
  description = "should be true if you want to use private DNS within the VPC"
  default     = true
}

variable "enable_firewall" {
  description = "should be true if you are using a firewall to NAT traffic for the private subnets"
  default     = false
}

variable "enable_nat_gateway" {
  description = "should be true if you want to provision NAT Gateways for each of your private networks"
  default     = true
}

variable "enable_s3_endpoint" {
  description = "should be true if you want to provision an S3 endpoint to the VPC"
  default     = false
  type        = bool
}

variable "fw_dmz_network_interface_id" {
  type        = list
  description = "Firewall DMZ eni id"
  default     = []
}

variable "fw_network_interface_id" {
  description = "Firewall network interface id"
  default     = []
}

variable "instance_tenancy" {
  description = "A tenancy option for instances launched into the VPC"
  default     = "default"
}

variable "map_public_ip_on_launch" {
  description = "should be false if you do not want to auto-assign public IP on launch"
  default     = true
}

variable "mgmt_subnets_list" {
  description = "A list of mgmt subnets inside the VPC."
  default     = ["10.11.61.0/24", "10.11.62.0/24", "10.11.63.0/24"]
}

variable "mgmt_propagating_vgws" {
  description = "A list of VGWs the mgmt route table should propagate."
  default     = []
}

variable "name" {
  description = "Name to be used on all the resources as identifier"
  default     = "terraform"
}

variable "private_subnets_list" {
  description = "A list of private subnets inside the VPC."
  default     = ["10.11.1.0/24", "10.11.2.0/24", "10.11.3.0/24"]
}

variable "public_subnets_list" {
  description = "A list of public subnets inside the VPC."
  default     = ["10.11.201.0/24", "10.11.202.0/24", "10.11.203.0/24"]
}

variable "private_propagating_vgws" {
  description = "A list of VGWs the private route table should propagate."
  default     = []
}

variable "public_propagating_vgws" {
  description = "A list of VGWs the public route table should propagate."
  default     = []
}

variable "single_nat_gateway" {
  description = "should be true if you want to provision a single shared NAT Gateway across all of your private networks"
  default     = false
}

variable "tags" {
  description = "A map of tags to add to all resources"
  default     = {
    terraform   = "true"
    environment = "prod"
    project     = "core_infrastructure"
  }
}

variable "vpc_cidr" {
  description = "The CIDR block for the VPC"
  default     = "10.11.0.0/16"
}

variable "workspaces_subnets_list" {
  description = "A list of workspaces subnets inside the VPC."
  default     = ["10.11.21.0/24", "10.11.22.0/24", "10.11.23.0/24"]
}

variable "workspaces_propagating_vgws" {
  description = "A list of VGWs the workspaces route table should propagate."
  default     = []
}
