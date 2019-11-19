variable "ami" {
  description = "ID of AMI to use for the instance"
}

variable "associate_public_ip_address" {
  description = "If true, the EC2 instance will have associated public IP address"
  default     = false
}

variable "azs" {
  description = "A list of availability zones in the region which will be utilized by this VPC"
  default     = ["us-east-1a", "us-east-1b"]
}

variable "bgp_asn" {
    description = "BGP ASN used for dynamic routing between the customer gateway and AWS gateway"
    default     = 65001
}

variable "customer_gw_name" {
    type        = list
    description = "(Required) List of names to use for the customer gateways. The order of names will be associated with the same IP address peering order"
}

variable "created_by" {
  type        = string
  description = "(Required) the full name of the person who is created the resource in terraform"
}

variable "disable_api_termination" {
  description = "If true, enables EC2 Instance Termination Protection"
  default     = false
}

variable "ebs_optimized" {
  description = "If true, the launched EC2 instance will be EBS-optimized"
  default     = false
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

variable "enable_vpc_peering" {
  description = "Boolean which should be set to true if you want to enable and set up vpc peering"
  default     = false
}

variable "iam_instance_profile" {
  description = "The IAM Instance Profile to launch the instance with. Specified as the name of the Instance Profile."
  default     = ""
}

variable "instance_count" {
  description = "Number of instances to launch"
  default     = 1
}

variable "instance_initiated_shutdown_behavior" {
  # https://docs.aws.amazon.com/AWSEC2/latest/UserGuide/terminating-instances.html#Using_ChangingInstanceInitiatedShutdownBehavior
  description = "Shutdown behavior for the instance"
  default     = ""
}

variable "instance_type" {
  description = "The type of instance to start"
  default     = "t3a.medium"
}

variable "instance_tenancy" {
  description = "A tenancy option for instances launched into the VPC"
  default     = "default"
}

variable "ipv6_address_count" {
  description = "A number of IPv6 addresses to associate with the primary network interface. Amazon EC2 chooses the IPv6 addresses from the range of your subnet."
  default     = 0
}

variable "ipv6_addresses" {
  description = "Specify one or more IPv6 addresses from the range of the subnet to associate with the primary network interface"
  default     = []
}

variable "key_name_prefix" {
    description = "SSL key pair name prefix, used to generate unique keypair name for EC2 instance deployments"
    default = "siem_keypair"
}

variable "map_public_ip_on_launch" {
  description = "should be false if you do not want to auto-assign public IP on launch"
  default     = false
}

variable "monitoring" {
  description = "If true, the launched EC2 instance will have detailed monitoring enabled"
  default     = false
}

variable "name" {
  description = "Name to be used on all the resources as identifier"
  default     = "siem"
}

variable "placement_group" {
  description = "The Placement Group to start the instance in"
  default     = ""
}

variable "private_ip" {
  description = "Private IP address to associate with the instance in a VPC"
  default     = "10.77.1.70"
}

variable "private_propagating_vgws" {
  description = "A list of VGWs the private route table should propagate."
  default     = []
}

variable "private_subnets_list" {
  description = "A list of private subnets inside the VPC."
  default     = ["10.77.1.64/26", "10.77.1.192/26"]
}

variable "public_key" {
    description = "(Required) Public rsa key"
}

variable "public_propagating_vgws" {
  description = "A list of VGWs the public route table should propagate."
  default     = []
}

variable "public_subnets_list" {
  description = "A list of public subnets inside the VPC."
  default     = ["10.77.1.0/26", "10.77.1.128/26"]
}

variable "root_delete_on_termination" {
  type        = string
  description = "(Optional) Whether the volume should be destroyed on instance termination (Default: true)"
  default     = true
}

variable "root_volume_size" {
  type        = string
  description = "(Optional) The size of the volume in gigabytes."
  default     = "100"
}

variable "root_volume_type" {
  type        = string
  description = "(Optional) The type of volume. Can be standard, gp2, or io1. (Default: standard)"
  default     = "gp2"
}

variable "security_group_description" {
    description = "Description of the security group"
    default     = "SIEM Collector Security Group"
}

variable "security_group_name" {
    description = "Name of the security group used for SIEM"
    default     = "siem_collector_sg"
}

variable "single_nat_gateway" {
  description = "should be true if you want to provision a single shared NAT Gateway across all of your private networks"
  default     = false
}

variable "source_dest_check" {
  description = "Controls if traffic is routed to the instance when the destination address does not match the instance. Used for NAT or VPNs."
  default     = true
}

variable "static_routes_only" {
    description = "Flag to determine whether or not dynamic or static routing is enabled"
    default     = true
}

variable "region" {
  type        = string
  description = "(Required) AWS region in which the VPC and all rersources will be created in"
}

variable "tags" {
  description = "A map of tags to add to all resources"
  default     = {
    created_by  = "Your Name"
    terraform   = "true"
    environment = "prod"
    project     = "SIEM Implementation"
    team        = "Security Team"
    used_by     = "ThinkStack"
  }
}

variable "tenancy" {
  description = "The tenancy of the instance (if the instance is running in a VPC). Available values: default, dedicated, host."
  default     = "default"
}

variable "user_data" {
  description = "The user data to provide when launching the instance"
  default     = ""
}

variable "vpc_cidr" {
  description = "The CIDR block for the VPC"
  default     = "10.77.1.0/24"
}

variable "vpn_peer_ip_address" {
    type        = list
    description = "(Required) List of customer gateway external IP addresses which will be utilized to create VPN connections with"
}

variable "vpn_route_cidr_blocks" {
    type        = list
    description = "(Required) CIDR block of the VPN subnets"
}

variable "vpn_type" {
    description = "Type of VPN tunnel. Currently only supports ipsec.1"
    default     = "ipsec.1"
}

variable "allow_remote_vpc_dns_resolution" {
  type        = string
  description = "(Optional) Allow a local VPC to resolve public DNS hostnames to private IP addresses when queried from instances in the peer VPC. This is not supported for inter-region VPC peering."
  default     = ""
}

variable "auto_accept" {
  type        = string
  description = "(Optional) Accept the peering (both VPCs need to be in the same AWS account)."
  default     = true
}

variable "peer_owner_id" {
  type        = string
  description = "(Optional) The AWS account ID of the owner of the peer VPC. Defaults to the account ID the AWS provider is currently connected to."
  default     = ""
}

variable "peer_region" {
  type        = string
  description = "(Optional) The region of the accepter VPC of the [VPC Peering Connection]. auto_accept must be false, and use the aws_vpc_peering_connection_accepter to manage the accepter side."
  default     = ""
}

variable "peer_vpc_id" {
  type        = string
  description = "(Required) The ID of the VPC with which you are creating the VPC Peering Connection."
  default     = ""
}

variable "peer_vpc_subnet" {
  type        = string
  description = "(Optional) The subnet cidr block of the VPC which will be a peer"
  default     = ""
}

variable "sg_cidr_blocks" {
  description = "(Requirerd) Security group allowed cidr blocks which will allow sending traffic to the SIEM collector"
  type        = list
}
