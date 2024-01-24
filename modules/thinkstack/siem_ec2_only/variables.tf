variable "ami" {
  type        = string
  description = "ID of AMI to use for the instance"
}

variable "associate_public_ip_address" {
  type        = bool
  description = "If true, the EC2 instance will have associated public IP address"
  default     = false
  validation {
    condition     = can(regex("^(true|false)$", var.associate_public_ip_address))
    error_message = "The value must be either true or false."
  }
}

variable "availability_zone" {
  type        = string
  description = "The AZ to start the instance in"
  default     = aws_subnet.private_subnets[count.index].availability_zone
}

variable "disable_api_termination" {
  type        = bool
  description = "If true, enables EC2 Instance Termination Protection"
  default     = false
  validation {
    condition     = can(regex("^(true|false)$", var.disable_api_termination))
    error_message = "The value must be either true or false."
  }
}

variable "ebs_optimized" {
  type        = bool
  description = "If true, the launched EC2 instance will be EBS-optimized"
  default     = false
  validation {
    condition     = can(regex("^(true|false)$", var.ebs_optimized))
    error_message = "The value must be either true or false."
  }
}

variable "encrypted" {
  type        = bool
  description = "(Optional) Enable volume encryption. (Default: false). Must be configured to perform drift detection."
  default     = true
  validation {
    condition     = can(regex("^(true|false)$", var.encrypted))
    error_message = "The value must be either true or false."
  }
}

variable "http_endpoint" {
  type        = string
  description = "(Optional) Whether the metadata service is available. Valid values include enabled or disabled. Defaults to enabled."
  default     = "enabled"
  validation {
    condition     = can(regex("^(enabled|disabled)$", var.http_endpoint))
    error_message = "The value must be either enabled or disabled."
  }
}

variable "http_tokens" {
  type        = string
  description = "(Optional) Whether or not the metadata service requires session tokens, also referred to as Instance Metadata Service Version 2 (IMDSv2). Valid values include optional or required. Defaults to optional."
  default     = "required"
  validation {
    condition     = can(regex("^(optional|required)$", var.http_tokens))
    error_message = "The value must be either optional or required."
  }
}

variable "iam_instance_profile" {
  type        = string
  description = "The IAM Instance Profile to launch the instance with. Specified as the name of the Instance Profile."
  default     = "siem-ssm-service-role"
}

variable "instance_count" {
  type        = number
  description = "Number of instances to launch"
  default     = 1
}

variable "instance_initiated_shutdown_behavior" {
  type        = string
  description = "(Optional) Shutdown behavior for the instance. Amazon defaults this to stop for EBS-backed instances and terminate for instance-store instances. Cannot be set on instance-store instances. See Shutdown Behavior for more information. https://docs.aws.amazon.com/AWSEC2/latest/UserGuide/terminating-instances.html#Using_ChangingInstanceInitiatedShutdownBehavior"
  default     = "stop"
  validation {
    condition     = can(regex("stop|terminate", var.instance_initiated_shutdown_behavior))
    error_message = "The value must be either stop or terminate."
  }
}

variable "instance_type" {
  type        = string
  description = "The type of instance to start"
  default     = "t3a.medium"
}

variable "instance_tenancy" {
  type        = string
  description = "A tenancy option for instances launched into the VPC"
  default     = "default"
}

variable "key_name" {
  type        = string
  description = "The key name to use for the instance"
  default     = aws_key_pair.deployer_key.id
}

variable "key_name_prefix" {
  type        = string
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
  default     = "gp3"
}

variable "map_public_ip_on_launch" {
  type        = bool
  description = "should be false if you do not want to auto-assign public IP on launch"
  default     = false
}

variable "monitoring" {
  type        = bool
  description = "If true, the launched EC2 instance will have detailed monitoring enabled"
  default     = false
}

variable "name" {
  type        = string
  description = "Name to be used on all the resources as identifier"
  default     = "siem"
}

variable "placement_group" {
  type        = string
  description = "The Placement Group to start the instance in"
  default     = ""
}

variable "private_ip" {
  type        = string
  description = "Private IP address to associate with the instance in a VPC"
  default     = "10.77.1.70"
}

variable "private_subnets_list" {
  type        = list(string)
  description = "A list of private subnets inside the VPC."
  default     = ["10.77.1.64/26", "10.77.1.192/26"]
}

variable "public_key" {
  type        = string
  description = "(Required) Public rsa key"
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
  default     = "gp3"
}

variable "security_group_description" {
  type        = string
  description = "Description of the security group"
  default     = "SIEM Collector Security Group"
}

variable "security_group_name" {
  type        = string
  description = "Name of the security group used for SIEM"
  default     = "siem_collector_sg"
}

variable "source_dest_check" {
  type        = bool
  description = "Controls if traffic is routed to the instance when the destination address does not match the instance. Used for NAT or VPNs."
  default     = true
  validation {
    condition     = can(regex("^(true|false)$", var.source_dest_check))
    error_message = "The value must be either true or false."
  }
}

variable "subnet_id" {
    type        = string
    description = "The VPC Subnet ID to launch in"
    default     = aws_subnet.private_subnets[count.index].id
}

variable "user_data" {
  type        = string
  description = "The user data to provide when launching the instance. Do not pass gzip-compressed data via this argument; see user_data_base64 instead."
  default     = null
}

variable "vpc_security_group_ids" {
  type        = string
  description = "The CIDR block for the VPC"
  default     = [aws_security_group.sg.id]
}

variable "sg_cidr_blocks" {
  description = "(Requirerd) Security group allowed cidr blocks which will allow sending traffic to the SIEM collector"
  type        = list(any)
}

variable "iam_role_name" {
  type        = string
  description = "(Optional, Forces new resource) The name of the role. If omitted, Terraform will assign a random, unique name."
  default     = "siem-ssm-service-role"
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
# General Use Variables
###########################

variable "tags" {
  type        = map(string)
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
