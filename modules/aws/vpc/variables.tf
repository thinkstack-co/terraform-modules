###########################
# VPC
###########################

variable "vpc_cidr" {
  description = "The CIDR block for the VPC"
  default     = "10.11.0.0/16"
  type        = string
}

variable "enable_dns_hostnames" {
  description = "(Optional) A boolean flag to enable/disable DNS hostnames in the VPC. Defaults false."
  default     = true
  type        = bool
}

variable "enable_dns_support" {
  description = "(Optional) A boolean flag to enable/disable DNS support in the VPC. Defaults true."
  default     = true
  type        = bool
}

variable "instance_tenancy" {
  description = "A tenancy option for instances launched into the VPC"
  default     = "default"
}

###########################
# Subnets
###########################

variable "azs" {
  description = "A list of Availability zones in the region"
  default     = ["us-east-2a", "us-east-2b", "us-east-2c"]
}

variable "db_subnets_list" {
  description = "A list of database subnets inside the VPC."
  default     = ["10.11.11.0/24", "10.11.12.0/24", "10.11.13.0/24"]
}

variable "dmz_subnets_list" {
  description = "A list of DMZ subnets inside the VPC."
  default     = ["10.11.101.0/24", "10.11.102.0/24", "10.11.103.0/24"]
}

variable "map_public_ip_on_launch" {
  description = "(Optional) Specify true to indicate that instances launched into the subnet should be assigned a public IP address. Default is false."
  default     = true
  type        = bool
}

variable "mgmt_subnets_list" {
  description = "A list of mgmt subnets inside the VPC."
  default     = ["10.11.61.0/24", "10.11.62.0/24", "10.11.63.0/24"]
}

variable "private_subnets_list" {
  description = "A list of private subnets inside the VPC."
  default     = ["10.11.1.0/24", "10.11.2.0/24", "10.11.3.0/24"]
}

variable "public_subnets_list" {
  description = "A list of public subnets inside the VPC."
  default     = ["10.11.201.0/24", "10.11.202.0/24", "10.11.203.0/24"]
}

variable "workspaces_subnets_list" {
  description = "A list of workspaces subnets inside the VPC."
  default     = ["10.11.21.0/24", "10.11.22.0/24", "10.11.23.0/24"]
}

###########################
# Gateways
###########################

variable "single_nat_gateway" {
  description = "(Optional) A boolean flag to enable/disable use of only a single shared NAT Gateway across all of your private networks. Defaults False."
  default     = false
}

###########################
# Route Tables and Associations
###########################

variable "db_propagating_vgws" {
  description = "A list of VGWs the db route table should propagate."
  default     = []
}

variable "dmz_propagating_vgws" {
  description = "A list of VGWs the DMZ route table should propagate."
  default     = []
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

variable "mgmt_propagating_vgws" {
  description = "A list of VGWs the mgmt route table should propagate."
  default     = []
}

variable "private_propagating_vgws" {
  description = "A list of VGWs the private route table should propagate."
  default     = []
}

variable "public_propagating_vgws" {
  description = "A list of VGWs the public route table should propagate."
  default     = []
}

/* variable "vpc_region" {
  description = "The region for the VPC"
  type        = string
} */

variable "workspaces_propagating_vgws" {
  description = "A list of VGWs the workspaces route table should propagate."
  default     = []
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
    default     = "CloudWatch kms key used to encrypt flow logs"
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
  default     = "alias/flow_logs_key_"
  type        = string
}

###########################
# CloudWatch Log Group
###########################

variable "cloudwatch_name_prefix" {
  description = "(Optional, Forces new resource) Creates a unique name beginning with the specified prefix."
  default     = "flow_logs_"
  type        = string
}

variable "cloudwatch_retention_in_days" {
  description = "(Optional) Specifies the number of days you want to retain log events in the specified log group. Possible values are: 1, 3, 5, 7, 14, 30, 60, 90, 120, 150, 180, 365, 400, 545, 731, 1827, 3653, and 0. If you select 0, the events in the log group are always retained and never expire."
  default     = 365
  type        = number
}

###########################
# IAM Policy
###########################

variable "iam_policy_description" {
    description = "(Optional, Forces new resource) Description of the IAM policy."
    default     = "Used with flow logs to send packet capture logs to a CloudWatch log group"
    type        = string
}

variable "iam_policy_name_prefix" {
    description = "(Optional, Forces new resource) Creates a unique name beginning with the specified prefix. Conflicts with name."
    default     = "flow_log_policy_"
    type        = string
}

variable "iam_policy_path" {
    type = string
    description = "(Optional, default '/') Path in which to create the policy. See IAM Identifiers for more information."
    default = "/"
}

###########################
# IAM Role
###########################

variable "iam_role_assume_role_policy" {
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

variable "iam_role_description" {
  type        = string
  description = "(Optional) The description of the role."
  default     = "Role utilized for EC2 instances ENI flow logs. This role allows creation of log streams and adding logs to the log streams in cloudwatch"
}

variable "iam_role_force_detach_policies" {
  type        = bool
  description = "(Optional) Specifies to force detaching any policies the role has before destroying it. Defaults to false."
  default     = false
}

variable "iam_role_max_session_duration" {
  type        = number
  description = "(Optional) The maximum session duration (in seconds) that you want to set for the specified role. If you do not specify a value for this setting, the default maximum of one hour is applied. This setting can have a value from 1 hour to 12 hours."
  default     = 3600
}

variable "iam_role_name_prefix" {
  type        = string
  description = "(Required, Forces new resource) Creates a unique friendly name beginning with the specified prefix. Conflicts with name."
  default     = "flow_logs_role_"
}

variable "iam_role_permissions_boundary" {
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

###############################################################
# General Use Variables
###############################################################

variable "enable_firewall" {
  description = "(Optional) A boolean flag to enable/disable the use of a firewall instance within the VPC. Defaults False."
  default     = false
  type        = bool
}

variable "enable_nat_gateway" {
  description = "(Optional) A boolean flag to enable/disable the use of NAT gateways in the private subnets. Defaults True."
  default     = true
  type        = bool
}

variable "enable_s3_endpoint" {
  description = "(Optional) A boolean flag to enable/disable the use of a S3 endpoint with the VPC. Defaults False"
  default     = false
  type        = bool
}

variable "enable_vpc_flow_logs" {
  description = "(Optional) A boolean flag to enable/disable the use of VPC flow logs with the VPC. Defaults True."
  default     = true
  type        = bool
}

variable "name" {
  description = "(Required) Name to be tagged on all of the resources as an identifier"
  type        = string
}

variable "tags" {
  description = "(Optional) A mapping of tags to assign to the object."
  default     = {
    terraform   = "true"
    created_by  = "ThinkStack"
    environment = "prod"
    priority    = "high"
  }
}
