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

variable "enable_vpn_tunnel" {
  description = "(Required)Boolean which should be set to true if you want to enable and set up a vpn tunnel"
  default     = true
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

variable "region" {
  type        = string
  description = "(Required) AWS region in which the VPC and all rersources will be created in"
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

variable "allow_remote_vpc_dns_resolution" {
  type        = string
  description = "(Optional) Allow a local VPC to resolve public DNS hostnames to private IP addresses when queried from instances in the peer VPC. This is not supported for inter-region VPC peering."
  default     = true
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
# KMS Encryption Key
###########################

variable "key_customer_master_key_spec" {
    description = "(Optional) Specifies whether the key contains a symmetric key or an asymmetric key pair and the encryption algorithms or signing algorithms that the key supports. Valid values: SYMMETRIC_DEFAULT, RSA_2048, RSA_3072, RSA_4096, ECC_NIST_P256, ECC_NIST_P384, ECC_NIST_P521, or ECC_SECG_P256K1. Defaults to SYMMETRIC_DEFAULT. For help with choosing a key spec, see the AWS KMS Developer Guide."
    default     = "SYMMETRIC_DEFAULT"
    type        = string
}

variable "key_description" {
    description = "(Optional) The description of the key as viewed in AWS console."
    default     = "Cloudtrail kms key used to encrypt audit logs"
    type        = string
}

variable "key_deletion_window_in_days" {
    description = "(Optional) Duration in days after which the key is deleted after destruction of the resource, must be between 7 and 30 days. Defaults to 30 days."
    default     = 30
    type        = number
}

variable "key_enable_key_rotation" {
  description = "(Optional) Specifies whether key rotation is enabled. Defaults to false."
  default     = true
  type        = bool
}

variable "key_usage" {
  description = "(Optional) Specifies the intended use of the key. Defaults to ENCRYPT_DECRYPT, and only symmetric encryption and decryption are supported."
  default     = "ENCRYPT_DECRYPT"
  type        = string
}

variable "key_is_enabled" {
  description = "(Optional) Specifies whether the key is enabled. Defaults to true."
  default     = true
  type        = string
}

variable "key_name_prefix" {
  description = "(Optional) Creates an unique alias beginning with the specified prefix. The name must start with the word alias followed by a forward slash (alias/)."
  default     = "alias/cloudtrail_key_"
  type        = string
}

###########################
# S3 Bucket
###########################

variable "s3_bucket_prefix" {
  description = "(Optional, Forces new resource) Creates a unique bucket name beginning with the specified prefix. Conflicts with bucket."
  default     = "siem-cloudtrail-"
  type        = string
}

variable "s3_versioning_enabled" {
  description = "(Optional) Enable versioning. Once you version-enable a bucket, it can never return to an unversioned state. You can, however, suspend versioning on that bucket."
  default     = false
}

variable "s3_mfa_delete" {
  description = "(Optional) Enable MFA delete for either Change the versioning state of your bucket or Permanently delete an object version. Default is false."
  default     = true
}

###########################
# Cloudtrail
###########################

variable "cloudtrail_enable_log_file_validation" {
  description = "(Optional) Whether log file integrity validation is enabled. Defaults to false."
  default     = true
  type        = bool
}

variable "cloudtrail_include_global_service_events" {
  description = "(Optional) Whether the trail is publishing events from global services such as IAM to the log files. Defaults to true."
  default     = true
  type        = bool
}

variable "cloudtrail_is_multi_region_trail" {
  description = "(Optional) Whether the trail is created in the current region or in all regions. Defaults to false."
  default     = true
  type        = bool
}

variable "cloudtrail_name" {
  description = "(Required) Name of the trail."
  default     = "cloudtrail"
  type        = string
}

variable "cloudtrail_s3_key_prefix" {
  description = "(Optional) S3 key prefix that follows the name of the bucket you have designated for log file delivery."
  default     = null
  type        = string
}

variable "cloudtrail_insight_type" {
  type        = string
  description = "(Optional) Type of insights to log on a trail. The valid value is ApiCallRateInsight"
  default     = "ApiCallRateInsight"
}

##################
# SQS
##################

variable "sqs_name" {
  type        = string
  description = "(Optional) This is the human-readable name of the queue. If omitted, Terraform will assign a random name."
  default     = "siem_sqs_queue"
}

variable "sqs_visibility_timeout_seconds" {
  type        = number
  description = "(Optional) The visibility timeout for the queue. An integer from 0 to 43200 (12 hours). The default for this attribute is 30. For more information about visibility timeout, see AWS docs."
  default     = 30
}

variable "sqs_message_retention_seconds" {
  type        = number
  description = "(Optional) The number of seconds Amazon SQS retains a message. Integer representing seconds, from 60 (1 minute) to 1209600 (14 days). The default for this attribute is 345600 (4 days)."
  default     = 345600
}

variable "sqs_max_message_size" {
  type        = number
  description = "(Optional) The limit of how many bytes a message can contain before Amazon SQS rejects it. An integer from 1024 bytes (1 KiB) up to 262144 bytes (256 KiB). The default for this attribute is 262144 (256 KiB)."
  default     = 262144
}

variable "sqs_delay_seconds" {
  type        = number
  description = "(Optional) The time in seconds that the delivery of all messages in the queue will be delayed. An integer from 0 to 900 (15 minutes). The default for this attribute is 0 seconds."
  default     = 0
}

variable "sqs_receive_wait_time_seconds" {
  type        = number
  description = "(Optional) The time for which a ReceiveMessage call will wait for a message to arrive (long polling) before returning. An integer from 0 to 20 (seconds). The default for this attribute is 0, meaning that the call will return immediately."
  default     = 0
}

variable "sqs_redrive_policy" {
  type        = string
  description = "(Optional) The JSON policy to set up the Dead Letter Queue, see AWS docs. Note: when specifying maxReceiveCount, you must specify it as an integer (5), and not a string ('5')."
  default     = null
}

variable "sqs_fifo_queue" {
  type        = bool
  description = "(Optional) Boolean designating a FIFO queue. If not set, it defaults to false making it standard."
  default     = false
}

variable "sqs_content_based_deduplication" {
  type        = bool
  description = "(Optional) Enables content-based deduplication for FIFO queues. For more information, see the related documentation"
  default     = false
}

variable "sqs_kms_master_key_id" {
  type        = string
  description = "(Optional) The ID of an AWS-managed customer master key (CMK) for Amazon SQS or a custom CMK. For more information, see Key Terms."
  default     = "alias/aws/sqs"
}

variable "sqs_kms_data_key_reuse_period_seconds" {
  type        = number
  description = "(Optional) The length of time, in seconds, for which Amazon SQS can reuse a data key to encrypt or decrypt messages before calling AWS KMS again. An integer representing seconds, between 60 seconds (1 minute) and 86,400 seconds (24 hours). The default is 300 (5 minutes)."
  default     = 300
}