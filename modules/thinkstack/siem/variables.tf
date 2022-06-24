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
  default     = 65077
}

variable "customer_gw_name" {
  type        = list
  description = "(Required) List of names to use for the customer gateways. The order of names will be associated with the same IP address peering order"
  default     = null
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
  description = "(Required)Boolean which should be set to true if you want to enable and set up vpc peering"
  default     = false
}

variable "enable_vpn_peering" {
  description = "(Required)Boolean which should be set to true if you want to enable and set up a vpn tunnel"
  default     = false
}

variable "encrypted" {
  type        = string
  description = "(Optional) Enable volume encryption. (Default: false). Must be configured to perform drift detection."
  default     = true
}

variable "iam_instance_profile" {
  description = "The IAM Instance Profile to launch the instance with. Specified as the name of the Instance Profile."
  default     = "siem-ssm-service-role"
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

variable "key_name_prefix" {
  description = "SSL key pair name prefix, used to generate unique keypair name for EC2 instance deployments"
  default     = "siem_keypair"
}

variable "log_volume_device_name" {
  type        = string
  description = "(Required) The device name to expose to the instance (for example, /dev/sdh or xvdh). See Device Naming on Linux Instances and Device Naming on Windows Instances for more information."
  default     = "/dev/sdf"
}

variable "log_volume_size" {
  type        = string
  description = "(Optional) The size of the drive in GiBs."
  default     = 300
}

variable "log_volume_type" {
  type        = string
  description = "(Optional) The type of volume. Can be standard, gp2, or io1. (Default: standard)"
  default     = "gp2"
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

variable "tenancy" {
  description = "The tenancy of the instance (if the instance is running in a VPC). Available values: default, dedicated, host."
  default     = "default"
}

variable "vpc_cidr" {
  description = "The CIDR block for the VPC"
  default     = "10.77.1.0/24"
}

variable "vpn_peer_ip_address" {
  type        = list
  description = "(Required) List of customer gateway external IP addresses which will be utilized to create VPN connections with"
  default     = null
}

variable "vpn_route_cidr_blocks" {
  type        = list
  description = "(Required) CIDR block of the VPN subnets"
  default     = null
}

variable "vpn_type" {
  description = "Type of VPN tunnel. Currently only supports ipsec.1"
  default     = "ipsec.1"
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

variable "peer_vpc_ids" {
  type        = list
  description = "(Required) The ID of the VPC with which you are creating the VPC Peering Connection."
  default     = []
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

variable "iam_role_name" {
  type        = string
  description = "(Optional, Forces new resource) The name of the role. If omitted, Terraform will assign a random, unique name."
  default     = "siem-ssm-service-role"
}

###########################
# Transit Gateway
###########################

variable "transit_gateway_id" {
  type        = string
  description = "(Optional) Identifier of an EC2 Transit Gateway."
  default     = null
}

variable "transit_subnet_route_cidr_blocks" {
  type        = list
  description = "(Optional) The destination CIDR blocks to send to the transit gateway."
  default     = null
}

###########################
# KMS Encryption Key
###########################

variable "flow_key_customer_master_key_spec" {
    description = "(Optional) Specifies whether the key contains a symmetric key or an asymmetric key pair and the encryption algorithms or signing algorithms that the key supports. Valid values: SYMMETRIC_DEFAULT, RSA_2048, RSA_3072, RSA_4096, ECC_NIST_P256, ECC_NIST_P384, ECC_NIST_P521, or ECC_SECG_P256K1. Defaults to SYMMETRIC_DEFAULT. For help with choosing a key spec, see the AWS KMS Developer Guide."
    default     = "SYMMETRIC_DEFAULT"
    type        = string
}

variable "flow_key_description" {
    description = "(Optional) The description of the key as viewed in AWS console."
    default     = "CloudWatch kms key used to encrypt flow logs"
    type        = string
}

variable "flow_key_deletion_window_in_days" {
    description = "(Optional) Duration in days after which the key is deleted after destruction of the resource, must be between 7 and 30 days. Defaults to 30 days."
    default     = 30
    type        = number
}

variable "flow_key_enable_key_rotation" {
  description = "(Optional) Specifies whether key rotation is enabled. Defaults to false."
  default     = true
  type        = bool
}

variable "flow_key_usage" {
  description = "(Optional) Specifies the intended use of the key. Defaults to ENCRYPT_DECRYPT, and only symmetric encryption and decryption are supported."
  default     = "ENCRYPT_DECRYPT"
  type        = string
}

variable "flow_key_is_enabled" {
  description = "(Optional) Specifies whether the key is enabled. Defaults to true."
  default     = true
  type        = string
}

variable "flow_key_name_prefix" {
  description = "(Optional) Creates an unique alias beginning with the specified prefix. The name must start with the word alias followed by a forward slash (alias/)."
  default     = "alias/flow_logs_key_"
  type        = string
}

###########################
# CloudWatch Log Group
###########################

variable "flow_cloudwatch_name_prefix" {
  description = "(Optional, Forces new resource) Creates a unique name beginning with the specified prefix."
  default     = "flow_logs_"
  type        = string
}

variable "flow_cloudwatch_retention_in_days" {
  description = "(Optional) Specifies the number of days you want to retain log events in the specified log group. Possible values are: 1, 3, 5, 7, 14, 30, 60, 90, 120, 150, 180, 365, 400, 545, 731, 1827, 3653, and 0. If you select 0, the events in the log group are always retained and never expire."
  default     = 365
  type        = number
}

###########################
# IAM Policy
###########################

variable "flow_iam_policy_description" {
    description = "(Optional, Forces new resource) Description of the IAM policy."
    default     = "Used with flow logs to send packet capture logs to a CloudWatch log group"
    type        = string
}

variable "flow_iam_policy_name_prefix" {
    description = "(Optional, Forces new resource) Creates a unique name beginning with the specified prefix. Conflicts with name."
    default     = "flow_log_policy_"
    type        = string
}

variable "flow_iam_policy_path" {
    type = string
    description = "(Optional, default '/') Path in which to create the policy. See IAM Identifiers for more information."
    default = "/"
}

###########################
# IAM Role
###########################

variable "flow_iam_role_assume_role_policy" {
  type        = string
  description = "(Required) The policy that grants an entity permission to assume the role."
  default = <<POLICY
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Effect": "Allow",
      "Principal": {
        "Service": "vpc-flow-logs.amazonaws.com"
      },
      "Action": "sts:AssumeRole"
    }
  ]
}
POLICY
}

variable "flow_iam_role_description" {
  type        = string
  description = "(Optional) The description of the role."
  default     = "Role utilized for EC2 instances ENI flow logs. This role allows creation of log streams and adding logs to the log streams in cloudwatch"
}

variable "flow_iam_role_force_detach_policies" {
  type        = bool
  description = "(Optional) Specifies to force detaching any policies the role has before destroying it. Defaults to false."
  default     = false
}

variable "flow_iam_role_max_session_duration" {
  type        = number
  description = "(Optional) The maximum session duration (in seconds) that you want to set for the specified role. If you do not specify a value for this setting, the default maximum of one hour is applied. This setting can have a value from 1 hour to 12 hours."
  default     = 3600
}

variable "flow_iam_role_name_prefix" {
  type        = string
  description = "(Required, Forces new resource) Creates a unique friendly name beginning with the specified prefix. Conflicts with name."
  default     = "flow_logs_role_"
}

variable "flow_iam_role_permissions_boundary" {
  type        = string
  description = "(Optional) The ARN of the policy that is used to set the permissions boundary for the role."
  default     = ""
}

###########################
# VPC Flow Log
###########################

variable "flow_log_destination_type" {
  type        = string
  description = "(Optional) The type of the logging destination. Valid values: cloud-watch-logs, s3. Default: cloud-watch-logs."
  default     = "cloud-watch-logs"
}

variable "flow_max_aggregation_interval" {
  type        = number
  description = "(Optional) The maximum interval of time during which a flow of packets is captured and aggregated into a flow log record. Valid Values: 60 seconds (1 minute) or 600 seconds (10 minutes). Default: 600."
  default     = 60
}

variable "flow_traffic_type" {
  type        = string
  description = "(Optional) The type of traffic to capture. Valid values: ACCEPT,REJECT, ALL."
  default     = "ALL"
}

######################################################
# SIEM Monitor for AWS CloudTrail
######################################################

###########################
# CloudTrail
###########################

###########################
# KMS Encryption Key
###########################

variable "cloudtrail_key_customer_master_key_spec" {
    description = "(Optional) Specifies whether the key contains a symmetric key or an asymmetric key pair and the encryption algorithms or signing algorithms that the key supports. Valid values: SYMMETRIC_DEFAULT, RSA_2048, RSA_3072, RSA_4096, ECC_NIST_P256, ECC_NIST_P384, ECC_NIST_P521, or ECC_SECG_P256K1. Defaults to SYMMETRIC_DEFAULT. For help with choosing a key spec, see the AWS KMS Developer Guide."
    default     = "SYMMETRIC_DEFAULT"
    type        = string
}

variable "cloudtrail_key_description" {
    description = "(Optional) The description of the key as viewed in AWS console."
    default     = "Cloudtrail kms key used to encrypt logs"
    type        = string
}

variable "cloudtrail_key_deletion_window_in_days" {
    description = "(Optional) Duration in days after which the key is deleted after destruction of the resource, must be between 7 and 30 days. Defaults to 30 days."
    default     = 30
    type        = number
}

variable "cloudtrail_key_enable_key_rotation" {
  description = "(Optional) Specifies whether key rotation is enabled. Defaults to false."
  default     = true
  type        = bool
}

variable "cloudtrail_key_usage" {
  description = "(Optional) Specifies the intended use of the key. Defaults to ENCRYPT_DECRYPT, and only symmetric encryption and decryption are supported."
  default     = "ENCRYPT_DECRYPT"
  type        = string
}

variable "cloudtrail_key_is_enabled" {
  description = "(Optional) Specifies whether the key is enabled. Defaults to true."
  default     = true
  type        = string
}

variable "cloudtrail_key_name_prefix" {
  description = "(Optional) Creates an unique alias beginning with the specified prefix. The name must start with the word alias followed by a forward slash (alias/)."
  default     = "alias/cloudtrail_logs_key_"
  type        = string
}

variable "bucket_prefix" {
  type        = string
  description = "(Optional, Forces new resource) Creates a unique bucket name beginning with the specified prefix. Conflicts with bucket. Must be lowercase and less than or equal to 37 characters in length"
  default     = "siem-cloudtrail-"
}

###############################################################
# General Use Variables
###############################################################

variable "enable_transit_gateway_peering" {
  description = "(Optional) A boolean flag to enable/disable the use of a transit gateway. Defaults false."
  default     = false
  type        = bool
}

variable "enable_vpc_flow_logs" {
  description = "(Optional) A boolean flag to enable/disable the use of VPC flow logs with the VPC. Defaults true."
  default     = true
  type        = bool
}

variable "enable_siem_cloudtrail_logs" {
  description = "(Optional) A boolean flag to enable/disable the use of Cloudtrail logs and a SQS Queue for delivery to the SIEM. Defaults false."
  default     = false
  type        = bool
}

variable "tags" {
  description = "A map of tags to add to all resources"
  default = {
    backup      = "true"
    created_by  = "Your Name"
    terraform   = "true"
    environment = "prod"
    project     = "SIEM Implementation"
    service     = "soc"
    team        = "Security Team"
    used_by     = "ThinkStack"
  }
}
