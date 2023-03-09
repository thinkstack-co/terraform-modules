terraform {
  required_version = ">= 1.0.0"
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = ">= 4.0.0"
    }
  }
}

###########################
# Data Sources
###########################
data "aws_caller_identity" "current" {}
data "aws_region" "current" {}

###########################
# VPC
###########################

resource "aws_vpc" "vpc" {
  cidr_block           = var.vpc_cidr
  enable_dns_hostnames = var.enable_dns_hostnames
  enable_dns_support   = var.enable_dns_support
  instance_tenancy     = var.instance_tenancy
  tags                 = merge(var.tags, ({ "Name" = format("%s", var.name) }))
}

###########################
# VPC - Subnets
###########################

resource "aws_subnet" "private_subnets" {
  vpc_id            = aws_vpc.vpc.id
  cidr_block        = var.private_subnets_list[count.index]
  availability_zone = element(var.azs, count.index)
  count             = length(var.private_subnets_list)
  tags              = merge(var.tags, ({ "Name" = format("%s-subnet-private-%s", var.name, element(var.azs, count.index)) }))
}

resource "aws_subnet" "public_subnets" {
  vpc_id                  = aws_vpc.vpc.id
  cidr_block              = var.public_subnets_list[count.index]
  availability_zone       = element(var.azs, count.index)
  map_public_ip_on_launch = var.map_public_ip_on_launch
  count                   = length(var.public_subnets_list)
  tags                    = merge(var.tags, ({ "Name" = format("%s-subnet-public-%s", var.name, element(var.azs, count.index)) }))
}

###########################
# VPC - Gateways
###########################

resource "aws_eip" "nateip" {
  count = var.enable_nat_gateway ? (var.single_nat_gateway ? 1 : length(var.azs)) : 0
  vpc   = true
}

resource "aws_internet_gateway" "igw" {
  tags   = merge(var.tags, ({ "Name" = format("%s-igw", var.name) }))
  vpc_id = aws_vpc.vpc.id
}

resource "aws_nat_gateway" "natgw" {
  depends_on = [aws_internet_gateway.igw]

  allocation_id = element(aws_eip.nateip[*].id, (var.single_nat_gateway ? 0 : count.index))
  count         = var.enable_nat_gateway ? (var.single_nat_gateway ? 1 : length(var.azs)) : 0
  subnet_id     = element(aws_subnet.public_subnets[*].id, (var.single_nat_gateway ? 0 : count.index))
}

###########################
# VPC - Routes
###########################

resource "aws_route_table" "public_route_table" {
  propagating_vgws = var.enable_vpn_peering ? [aws_vpn_gateway.vpn_gateway[0].id] : []
  tags             = merge(var.tags, ({ "Name" = format("%s-rt-public", var.name) }))
  vpc_id           = aws_vpc.vpc.id
}

resource "aws_route" "public_default_route" {
  destination_cidr_block = "0.0.0.0/0"
  gateway_id             = aws_internet_gateway.igw.id
  route_table_id         = aws_route_table.public_route_table.id
}

resource "aws_route_table" "private_route_table" {
  count            = length(var.azs)
  propagating_vgws = var.enable_vpn_peering ? [aws_vpn_gateway.vpn_gateway[0].id] : []
  tags             = merge(var.tags, ({ "Name" = format("%s-rt-private-%s", var.name, element(var.azs, count.index)) }))
  vpc_id           = aws_vpc.vpc.id
}

resource "aws_route" "private_default_route_natgw" {
  count                  = var.enable_firewall ? 0 : length(var.azs)
  destination_cidr_block = "0.0.0.0/0"
  nat_gateway_id         = aws_nat_gateway.natgw[count.index].id
  route_table_id         = aws_route_table.private_route_table[count.index].id
}

resource "aws_route_table_association" "private" {
  count          = length(var.private_subnets_list)
  route_table_id = aws_route_table.private_route_table[count.index].id
  subnet_id      = aws_subnet.private_subnets[count.index].id
}

resource "aws_route_table_association" "public" {
  count          = length(var.public_subnets_list)
  route_table_id = aws_route_table.public_route_table.id
  subnet_id      = aws_subnet.public_subnets[count.index].id
}

###########################
# VPC - Peering
###########################

resource "aws_vpc_peering_connection" "peer" {
  count         = var.enable_vpc_peering ? length(var.peer_vpc_ids) : 0
  auto_accept   = var.auto_accept
  peer_owner_id = var.peer_owner_id
  peer_region   = var.peer_region
  peer_vpc_id   = var.peer_vpc_ids[count.index]
  tags          = var.tags
  vpc_id        = aws_vpc.vpc.id
}

resource "aws_route" "vpc_peer_route" {
  count                     = var.enable_vpc_peering ? 1 : 0
  destination_cidr_block    = var.peer_vpc_subnet
  route_table_id            = aws_route_table.private_route_table[0].id
  vpc_peering_connection_id = aws_vpc_peering_connection.peer[count.index].id
}

###########################
# VPC - VPN
###########################

resource "aws_vpn_gateway" "vpn_gateway" {
  count  = var.enable_vpn_peering ? 1 : 0
  vpc_id = aws_vpc.vpc.id
  tags   = merge(var.tags, ({ "Name" = format("%s_vpn_gw", var.name) }))
}

resource "aws_customer_gateway" "customer_gateway" {
  count      = var.enable_vpn_peering ? length(var.vpn_peer_ip_address) : 0
  bgp_asn    = var.bgp_asn
  ip_address = var.vpn_peer_ip_address[count.index]
  type       = var.vpn_type
  tags       = merge(var.tags, ({ "Name" = format("%s_customer_gw", var.customer_gw_name[count.index]) }))
}

resource "aws_vpn_connection" "vpn_connection" {
  count               = var.enable_vpn_peering ? length(var.vpn_peer_ip_address) : 0
  customer_gateway_id = aws_customer_gateway.customer_gateway[count.index].id
  static_routes_only  = var.static_routes_only
  tags                = merge(var.tags, ({ "Name" = format("%s_vpn_connection", var.name) }))
  type                = var.vpn_type
  vpn_gateway_id      = aws_vpn_gateway.vpn_gateway[0].id
}

resource "aws_vpn_connection_route" "vpn_route" {
  count                  = var.enable_vpn_peering ? length(var.vpn_route_cidr_blocks) : 0
  destination_cidr_block = var.vpn_route_cidr_blocks[count.index]
  vpn_connection_id      = aws_vpn_connection.vpn_connection[0].id
}

###########################
# Transit Gateway
###########################

resource "aws_route" "transit_route" {
  count                  = var.enable_transit_gateway_peering ? length(var.transit_subnet_route_cidr_blocks) : 0
  destination_cidr_block = var.transit_subnet_route_cidr_blocks[count.index]
  route_table_id         = aws_route_table.private_route_table[0].id
  transit_gateway_id     = var.transit_gateway_id
}

###########################
# EC2 - Keypair
###########################

resource "aws_key_pair" "deployer_key" {
  key_name_prefix = var.key_name_prefix
  public_key      = var.public_key
}

###########################
# EC2 - Instance
###########################

resource "aws_instance" "ec2" {
  ami                                  = var.ami
  associate_public_ip_address          = var.associate_public_ip_address
  availability_zone                    = aws_subnet.private_subnets[count.index].availability_zone
  count                                = var.instance_count
  disable_api_termination              = var.disable_api_termination
  ebs_optimized                        = var.ebs_optimized
  iam_instance_profile                 = var.iam_instance_profile
  instance_initiated_shutdown_behavior = var.instance_initiated_shutdown_behavior
  instance_type                        = var.instance_type
  key_name                             = aws_key_pair.deployer_key.id
  monitoring                           = var.monitoring
  placement_group                      = var.placement_group
  private_ip                           = var.private_ip

  metadata_options {
    http_endpoint = var.http_endpoint
    http_tokens   = var.http_tokens
  }

  root_block_device {
    delete_on_termination = var.root_delete_on_termination
    encrypted             = var.encrypted
    volume_type           = var.root_volume_type
    volume_size           = var.root_volume_size
  }
  source_dest_check      = var.source_dest_check
  subnet_id              = aws_subnet.private_subnets[count.index].id
  tags                   = merge(var.tags, ({ "Name" = format("%s%d", var.name, count.index + 1) }))
  tenancy                = var.tenancy
  user_data              = file("${path.module}/snypr_centos_script.sh")
  volume_tags            = merge(var.tags, ({ "Name" = format("%s%d", var.name, count.index + 1) }))
  vpc_security_group_ids = [aws_security_group.sg.id]

  lifecycle {
    ignore_changes = [user_data]
  }
}

######################
# EBS Volume for logs
######################

resource "aws_ebs_volume" "log_volume" {
  availability_zone = aws_subnet.private_subnets[count.index].availability_zone
  count             = var.instance_count
  encrypted         = var.encrypted
  size              = var.log_volume_size
  type              = var.log_volume_type
  tags              = merge(var.tags, ({ "Name" = format("%s%d", var.name, count.index + 1) }))
}

resource "aws_volume_attachment" "log_volume_attachment" {
  count       = var.instance_count
  device_name = var.log_volume_device_name
  instance_id = aws_instance.ec2[count.index].id
  volume_id   = aws_ebs_volume.log_volume[count.index].id
}

###################################################
# EC2 - CloudWatch Alarms
###################################################

#####################
# Status Check Failed Instance Metric
#####################

resource "aws_cloudwatch_metric_alarm" "instance" {
  actions_enabled     = true
  alarm_actions       = []
  alarm_description   = "EC2 instance StatusCheckFailed_Instance alarm"
  alarm_name          = format("%s-instance-alarm", aws_instance.ec2[count.index].id)
  comparison_operator = "GreaterThanOrEqualToThreshold"
  count               = var.instance_count
  datapoints_to_alarm = 2
  dimensions = {
    InstanceId = aws_instance.ec2[count.index].id
  }
  evaluation_periods        = "2"
  insufficient_data_actions = []
  metric_name               = "StatusCheckFailed_Instance"
  namespace                 = "AWS/EC2"
  ok_actions                = []
  period                    = "60"
  statistic                 = "Maximum"
  threshold                 = "1"
  treat_missing_data        = "missing"
}

#####################
# Status Check Failed System Metric
#####################

resource "aws_cloudwatch_metric_alarm" "system" {
  actions_enabled     = true
  alarm_actions       = ["arn:aws:automate:${data.aws_region.current.name}:ec2:recover"]
  alarm_description   = "EC2 instance StatusCheckFailed_System alarm"
  alarm_name          = format("%s-system-alarm", aws_instance.ec2[count.index].id)
  comparison_operator = "GreaterThanOrEqualToThreshold"
  count               = var.instance_count
  datapoints_to_alarm = 2
  dimensions = {
    InstanceId = aws_instance.ec2[count.index].id
  }
  evaluation_periods        = "2"
  insufficient_data_actions = []
  metric_name               = "StatusCheckFailed_System"
  namespace                 = "AWS/EC2"
  ok_actions                = []
  period                    = "60"
  statistic                 = "Maximum"
  threshold                 = "1"
  treat_missing_data        = "missing"
}

###########################
# EC2 - Security Group
###########################

resource "aws_security_group" "sg" {
  description = var.security_group_description
  name        = var.security_group_name
  tags        = merge(var.tags, ({ "Name" = format("%s", var.security_group_name) }))
  vpc_id      = aws_vpc.vpc.id

  ingress {
    from_port   = -1
    to_port     = -1
    protocol    = "icmp"
    cidr_blocks = var.sg_cidr_blocks
    description = "Allow ICMP"
  }

  ingress {
    from_port   = 162
    to_port     = 162
    protocol    = "udp"
    cidr_blocks = var.sg_cidr_blocks
    description = "SNMP Trap Ingester Port"
  }

  /* 
########################################
# Syslog Port Mappings
########################################
Port - Description
13001 - Firewalls
13002 - Access Points
13003 - Windows
13004 - Switches and Routers
13005 - NTAs (Corelight, Darktrace, Extrahop, etc)
13006 - PDUs and UPS devices
13007 - Linux
13008 - Manage Engine ADAudit
13009 - Vulnerability Scanners (Trace, Qualys, Nessus, etc)
13010 - Hypervisors
13011 - Reserved
13012 - Web Proxy or Reverse Proxy (NGINX)
13013 - Reserved
13014 - Firewall Orchestration (Fortimanager, Cisco FMC, etc)
13015 - SANs and NAS devices
13016 - Security Cameras
13017 - Dell iDRAC
13018 - HP iLO
13019 - Backup Platforms (Veeam)
13020 - Endpoint Security (Carbon Black, Crowdstrike, Cylance, etc)
 */

  ingress {
    from_port   = 13001
    to_port     = 13020
    protocol    = "udp"
    cidr_blocks = var.sg_cidr_blocks
    description = "RIN Syslog Ingester Ports"
  }

  ingress {
    from_port   = 13001
    to_port     = 13020
    protocol    = "tcp"
    cidr_blocks = var.sg_cidr_blocks
    description = "RIN Syslog Ingester Ports"
  }

  egress {
    description = "Allow all outbound traffic"
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    #tfsec:ignore:aws-ec2-no-public-egress-sgr
    cidr_blocks = ["0.0.0.0/0"]
  }
}

###################################################
# Systems Manager
###################################################

##################
# IAM role
##################

resource "aws_iam_role" "this" {
  name               = var.iam_role_name
  assume_role_policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Sid": "",
      "Effect": "Allow",
      "Principal": {
        "Service": "ec2.amazonaws.com"
      },
      "Action": "sts:AssumeRole"
    }
  ]
}
EOF
}

resource "aws_iam_role_policy_attachment" "this_attach" {
  role       = aws_iam_role.this.name
  policy_arn = "arn:aws:iam::aws:policy/service-role/AmazonEC2RoleforSSM"
}

##################
# IAM role profile
##################

resource "aws_iam_instance_profile" "this" {
  name = var.iam_role_name
  role = aws_iam_role.this.name
}

##################
# IAM role policy
##################

/*resource "type" "name" {
  policy_arn = "arn:aws:iam::aws:policy/AmazonSSMManagedInstanceCore"
}*/

##################
# SSM activation
##################

##################
# SSM association
##################

######################################################
# VPC Flow Logs
######################################################

###########################
# KMS Encryption Key
###########################

resource "aws_kms_key" "key" {
  count                    = (var.enable_vpc_flow_logs == true ? 1 : 0)
  customer_master_key_spec = var.flow_key_customer_master_key_spec
  description              = var.flow_key_description
  deletion_window_in_days  = var.flow_key_deletion_window_in_days
  enable_key_rotation      = var.flow_key_enable_key_rotation
  key_usage                = var.flow_key_usage
  is_enabled               = var.flow_key_is_enabled
  tags                     = var.tags
  policy = jsonencode({
    "Version" = "2012-10-17",
    "Statement" = [
      {
        "Sid"    = "Enable IAM User Permissions",
        "Effect" = "Allow",
        "Principal" = {
          "AWS" = "arn:aws:iam::${data.aws_caller_identity.current.account_id}:root"
        },
        "Action"   = "kms:*",
        "Resource" = "*"
      },
      {
        "Effect" = "Allow",
        "Principal" = {
          "Service" = "logs.${data.aws_region.current.name}.amazonaws.com"
        },
        "Action" = [
          "kms:Encrypt*",
          "kms:Decrypt*",
          "kms:ReEncrypt*",
          "kms:GenerateDataKey*",
          "kms:Describe*"
        ],
        "Resource" = "*",
        "Condition" = {
          "ArnEquals" = {
            "kms:EncryptionContext:aws:logs:arn" : "arn:aws:logs:${data.aws_region.current.name}:${data.aws_caller_identity.current.account_id}:log-group:*"
          }
        }
      }
    ]
  })
}

resource "aws_kms_alias" "alias" {
  count         = (var.enable_vpc_flow_logs == true ? 1 : 0)
  name_prefix   = var.flow_key_name_prefix
  target_key_id = aws_kms_key.key[0].key_id
}

###########################
# CloudWatch Log Group
###########################

resource "aws_cloudwatch_log_group" "log_group" {
  count             = (var.enable_vpc_flow_logs == true ? 1 : 0)
  kms_key_id        = aws_kms_key.key[0].arn
  name_prefix       = var.flow_cloudwatch_name_prefix
  retention_in_days = var.flow_cloudwatch_retention_in_days
  tags              = var.tags
}

###########################
# IAM Policy
###########################
resource "aws_iam_policy" "policy" {
  count       = (var.enable_vpc_flow_logs == true ? 1 : 0)
  description = var.flow_iam_policy_description
  name_prefix = var.flow_iam_policy_name_prefix
  path        = var.flow_iam_policy_path
  tags        = var.tags
  #tfsec:ignore:aws-iam-no-policy-wildcards
  policy = jsonencode({
    Version = "2012-10-17",
    Statement = [{
      Effect = "Allow",
      Action = [
        "logs:CreateLogGroup",
        "logs:CreateLogStream",
        "logs:PutLogEvents",
        "logs:DescribeLogGroups",
        "logs:DescribeLogStreams"
      ],
      Resource = [
        "${aws_cloudwatch_log_group.log_group[0].arn}:*"
      ]
    }]
  })
}

###########################
# IAM Role
###########################

resource "aws_iam_role" "role" {
  count                 = (var.enable_vpc_flow_logs == true ? 1 : 0)
  assume_role_policy    = var.flow_iam_role_assume_role_policy
  description           = var.flow_iam_role_description
  force_detach_policies = var.flow_iam_role_force_detach_policies
  max_session_duration  = var.flow_iam_role_max_session_duration
  name_prefix           = var.flow_iam_role_name_prefix
  permissions_boundary  = var.flow_iam_role_permissions_boundary
}

resource "aws_iam_role_policy_attachment" "role_attach" {
  count      = (var.enable_vpc_flow_logs == true ? 1 : 0)
  role       = aws_iam_role.role[0].name
  policy_arn = aws_iam_policy.policy[0].arn
}

###########################
# VPC Flow Log
###########################

resource "aws_flow_log" "vpc_flow" {
  count                    = (var.enable_vpc_flow_logs == true ? 1 : 0)
  iam_role_arn             = aws_iam_role.role[0].arn
  log_destination_type     = var.flow_log_destination_type
  log_destination          = aws_cloudwatch_log_group.log_group[0].arn
  max_aggregation_interval = var.flow_max_aggregation_interval
  tags                     = var.tags
  traffic_type             = var.flow_traffic_type
  vpc_id                   = aws_vpc.vpc.id
}

######################################################
# SIEM Monitoring for AWS CloudTrail
######################################################

###########################
# KMS
###########################

resource "aws_kms_key" "cloudtrail_key" {
  count                    = (var.enable_siem_cloudtrail_logs == true ? 1 : 0)
  customer_master_key_spec = var.cloudtrail_key_customer_master_key_spec
  description              = var.cloudtrail_key_description
  deletion_window_in_days  = var.cloudtrail_key_deletion_window_in_days
  enable_key_rotation      = var.cloudtrail_key_enable_key_rotation
  key_usage                = var.cloudtrail_key_usage
  is_enabled               = var.cloudtrail_key_is_enabled
  tags                     = var.tags
  policy = jsonencode({
    "Version" = "2012-10-17",
    "Id"      = "Key policy created by CloudTrail",
    "Statement" = [
      {
        "Sid"    = "Enable IAM User Permissions",
        "Effect" = "Allow",
        "Principal" = {
          "AWS" = [
            "arn:aws:iam::${data.aws_caller_identity.current.account_id}:root"
          ]
        },
        "Action"   = "kms:*",
        "Resource" = "*"
      },
      {
        "Sid"    = "Allow CloudTrail to encrypt logs",
        "Effect" = "Allow",
        "Principal" = {
          "Service" = "cloudtrail.amazonaws.com"
        },
        "Action"   = "kms:GenerateDataKey*",
        "Resource" = "arn:aws:kms:${data.aws_region.current.name}:${data.aws_caller_identity.current.account_id}:key/*",
        "Condition" = {
          "StringLike" = {
            "kms:EncryptionContext:aws:cloudtrail:arn" : "arn:aws:cloudtrail:*:${data.aws_caller_identity.current.account_id}:trail/*"
          }
        }
      },
      {
        "Sid"    = "Allow CloudTrail to describe key",
        "Effect" = "Allow",
        "Principal" = {
          "Service" : "cloudtrail.amazonaws.com"
        },
        "Action"   = "kms:DescribeKey",
        "Resource" = "arn:aws:kms:${data.aws_region.current.name}:${data.aws_caller_identity.current.account_id}:key/*"
      },
      {
        "Sid"    = "Allow principals in the account to decrypt log files",
        "Effect" = "Allow",
        "Principal" = {
          "AWS" : "*"
        },
        "Action" = [
          "kms:Decrypt",
          "kms:ReEncryptFrom"
        ],
        "Resource" = "arn:aws:kms:${data.aws_region.current.name}:${data.aws_caller_identity.current.account_id}:key/*",
        "Condition" = {
          "StringEquals" = {
            "kms:CallerAccount" : "${data.aws_caller_identity.current.account_id}"
          },
          "StringLike" = {
            "kms:EncryptionContext:aws:cloudtrail:arn" : "arn:aws:cloudtrail:*:${data.aws_caller_identity.current.account_id}:trail/*"
          }
        }
      },
      {
        "Sid"    = "Allow alias creation during setup",
        "Effect" = "Allow",
        "Principal" = {
          "AWS" : "*"
        },
        "Action"   = "kms:CreateAlias",
        "Resource" = "*",
        "Condition" = {
          "StringEquals" = {
            "kms:CallerAccount" : "${data.aws_caller_identity.current.account_id}",
            "kms:ViaService" : "ec2.${data.aws_region.current.name}.amazonaws.com"
          }
        }
      },
      {
        "Sid"    = "Enable cross account log decryption",
        "Effect" = "Allow",
        "Principal" = {
          "AWS" : "*"
        },
        "Action" = [
          "kms:Decrypt",
          "kms:ReEncryptFrom"
        ],
        "Resource" = "arn:aws:kms:${data.aws_region.current.name}:${data.aws_caller_identity.current.account_id}:key/*",
        "Condition" = {
          "StringEquals" = {
            "kms:CallerAccount" : "${data.aws_caller_identity.current.account_id}"
          },
          "StringLike" = {
            "kms:EncryptionContext:aws:cloudtrail:arn" : "arn:aws:cloudtrail:*:${data.aws_caller_identity.current.account_id}:trail/*"
          }
        }
      }
    ]
  })
}

resource "aws_kms_alias" "cloudtrail_alias" {
  count         = (var.enable_siem_cloudtrail_logs == true ? 1 : 0)
  name_prefix   = var.cloudtrail_key_name_prefix
  target_key_id = aws_kms_key.cloudtrail_key[0].key_id
}

###########################
# SQS
###########################

resource "aws_sqs_queue" "cloudtrail_queue" {
  count                     = (var.enable_siem_cloudtrail_logs == true ? 1 : 0)
  name                      = "siem_cloudtrail_queue"
  delay_seconds             = 0
  max_message_size          = 262144
  message_retention_seconds = 345600
  policy                    = <<POLICY
{
  "Version": "2012-10-17",
  "Id": "access-policy-id-1",
  "Statement": [
    {
      "Sid": "queueid1",
      "Effect": "Allow",
      "Principal": {
        "Service": "s3.amazonaws.com"
      },
      "Action": "SQS:SendMessage",
      "Resource": "arn:aws:sqs:${data.aws_region.current.name}:${data.aws_caller_identity.current.account_id}:siem_cloudtrail_queue",
      "Condition": {
        "StringEquals": {
          "aws:SourceAccount": "${data.aws_caller_identity.current.account_id}"
        },
        "ArnLike": {
          "aws:SourceArn": "${aws_s3_bucket.cloudtrail_s3_bucket[0].arn}"
        }
      }
    }
  ]
}
POLICY


  receive_wait_time_seconds = 0
  tags                      = var.tags
}

###########################
# S3 Bucket
###########################

resource "aws_s3_bucket" "cloudtrail_s3_bucket" {
  count         = (var.enable_siem_cloudtrail_logs == true ? 1 : 0)
  bucket_prefix = var.bucket_prefix
  tags          = var.tags
}

resource "aws_s3_bucket_acl" "cloudtrail_bucket_acl" {
  count  = (var.enable_siem_cloudtrail_logs == true ? 1 : 0)
  bucket = aws_s3_bucket.cloudtrail_s3_bucket[0].id
  acl    = "private"
}

resource "aws_s3_bucket_public_access_block" "cloudtrail_bucket_public_access_block" {
  count  = (var.enable_siem_cloudtrail_logs == true ? 1 : 0)
  bucket = aws_s3_bucket.cloudtrail_s3_bucket[0].id

  block_public_acls   = true
  block_public_policy = true
}

resource "aws_s3_bucket_policy" "cloudtrail_bucket_policy" {
  count  = (var.enable_siem_cloudtrail_logs == true ? 1 : 0)
  bucket = aws_s3_bucket.cloudtrail_s3_bucket[0].id
  policy = <<POLICY
{
    "Version": "2012-10-17",
    "Statement": [
        {
            "Sid": "AWSCloudTrailAclCheck",
            "Effect": "Allow",
            "Principal": {
              "Service": "cloudtrail.amazonaws.com"
            },
            "Action": "s3:GetBucketAcl",
            "Resource": "${aws_s3_bucket.cloudtrail_s3_bucket[0].arn}"
        },
        {
            "Sid": "AWSCloudTrailWrite",
            "Effect": "Allow",
            "Principal": {
              "Service": "cloudtrail.amazonaws.com"
            },
            "Action": "s3:PutObject",
            "Resource": "${aws_s3_bucket.cloudtrail_s3_bucket[0].arn}/*",
            "Condition": {
                "StringEquals": {
                    "s3:x-amz-acl": "bucket-owner-full-control"
                }
            }
        }
    ]
}
POLICY
}

resource "aws_s3_bucket_server_side_encryption_configuration" "cloudtrail_bucket_encryption" {
  count  = (var.enable_siem_cloudtrail_logs == true ? 1 : 0)
  bucket = aws_s3_bucket.cloudtrail_s3_bucket[0].bucket

  rule {
    apply_server_side_encryption_by_default {
      kms_master_key_id = aws_kms_key.cloudtrail_key[0].arn
      sse_algorithm     = "aws:kms"
    }
  }
}

resource "aws_s3_bucket_lifecycle_configuration" "cloudtrail_bucket_lifecycle" {
  count  = (var.enable_siem_cloudtrail_logs == true ? 1 : 0)
  bucket = aws_s3_bucket.cloudtrail_s3_bucket[0].id

  rule {
    id     = "30_day_delete"
    status = "Enabled"

    filter {}
    expiration {
      days = 30
    }
  }
}

resource "aws_s3_bucket_notification" "cloudtrail_bucket_notification" {
  count  = (var.enable_siem_cloudtrail_logs == true ? 1 : 0)
  bucket = aws_s3_bucket.cloudtrail_s3_bucket[0].id

  queue {
    queue_arn = aws_sqs_queue.cloudtrail_queue[0].arn
    events    = ["s3:ObjectCreated:Put"]
  }
}

###########################
# Cloudtrail
###########################

resource "aws_cloudtrail" "cloudtrail" {
  count                         = (var.enable_siem_cloudtrail_logs == true ? 1 : 0)
  enable_log_file_validation    = true
  include_global_service_events = true
  is_multi_region_trail         = true
  kms_key_id                    = aws_kms_key.cloudtrail_key[0].arn
  name                          = "siem-cloudtrail"
  s3_bucket_name                = aws_s3_bucket.cloudtrail_s3_bucket[0].id
  insight_selector {
    insight_type = "ApiCallRateInsight"
  }
}

###########################
# IAM Policy
###########################

resource "aws_iam_policy" "siem_cloudtrail_policy" {
  count       = (var.enable_siem_cloudtrail_logs == true ? 1 : 0)
  description = "Used with the SIEM, KMS, Cloudtrail, SQS, and S3 to retrieve Cloudtrail logs"
  name_prefix = "siem_policy_"
  path        = "/"
  tags        = var.tags
  policy = jsonencode({
    Version = "2012-10-17",
    Statement = [
      {
        Effect = "Allow",
        Action = [
          "sqs:DeleteMessage",
          "s3:GetObject",
          "sqs:GetQueueUrl",
          "sqs:ChangeMessageVisibility",
          "kms:Decrypt",
          "sqs:PurgeQueue",
          "sqs:ReceiveMessage"
        ],
        Resource = [
          "${aws_sqs_queue.cloudtrail_queue[0].arn}",
          "${aws_s3_bucket.cloudtrail_s3_bucket[0].arn}/*",
          "${aws_kms_key.cloudtrail_key[0].arn}"
        ]
      },
      {
        Effect = "Allow",
        Action = [
          "sqs:ListQueues"
        ],
        Resource = "*"
      }
    ]
  })
}

###########################
# IAM Group
###########################

resource "aws_iam_group" "siem_cloudtrail_group" {
  count = (var.enable_siem_cloudtrail_logs == true ? 1 : 0)
  name  = "siem"
  path  = "/siem/"
}

resource "aws_iam_group_policy_attachment" "siem_policy_siem_group" {
  count      = (var.enable_siem_cloudtrail_logs == true ? 1 : 0)
  group      = aws_iam_group.siem_cloudtrail_group[0].name
  policy_arn = aws_iam_policy.siem_cloudtrail_policy[0].arn
}

###########################
# IAM User
###########################

resource "aws_iam_user" "siem_cloudtrail_user" {
  count = (var.enable_siem_cloudtrail_logs == true ? 1 : 0)
  name  = "siem"
  path  = "/siem/"
  tags  = var.tags
}

resource "aws_iam_user_group_membership" "siem_user" {
  count = (var.enable_siem_cloudtrail_logs == true ? 1 : 0)
  user  = aws_iam_user.siem_cloudtrail_user[0].name
  groups = [
    aws_iam_group.siem_cloudtrail_group[0].name,
  ]
}
