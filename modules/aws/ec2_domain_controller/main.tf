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
data "aws_region" "current" {}

locals {
  # Remove backup selection tags from root volume tags when exclude_root_volume_snapshot is enabled.
  root_volume_tags = var.exclude_root_volume_snapshot ? {
    for k, v in var.tags : k => v if !contains(var.root_volume_excluded_tag_keys, k)
  } : var.tags
}

###########################
# EC2 Instance
###########################

resource "aws_instance" "ec2_instance" {
  ami                                  = var.ami
  count                                = var.number
  disable_api_termination              = var.disable_api_termination
  ebs_optimized                        = var.ebs_optimized
  iam_instance_profile                 = var.iam_instance_profile
  instance_initiated_shutdown_behavior = var.instance_initiated_shutdown_behavior
  instance_type                        = var.instance_type
  key_name                             = var.key_name
  monitoring                           = var.enable_detailed_monitoring
  placement_group                      = var.placement_group
  private_ip                           = element(var.private_ip, count.index)

  maintenance_options {
    auto_recovery = var.auto_recovery
  }

  metadata_options {
    http_endpoint = var.http_endpoint
    http_tokens   = var.http_tokens
  }

  root_block_device {
    delete_on_termination = var.root_delete_on_termination
    encrypted             = var.encrypted
    iops                  = var.root_iops
    kms_key_id            = var.kms_key_id
    volume_size           = var.root_volume_size
    volume_type           = var.root_volume_type
  }

  source_dest_check = var.source_dest_check
  subnet_id         = element(var.subnet_id, count.index)
  tenancy           = var.tenancy
  tags              = merge(var.tags, ({ "Name" = format("%s%01d", var.name, count.index + 1) }))
  user_data         = var.user_data
  volume_tags = merge(
    local.root_volume_tags, # Use filtered tags when excluding root volume backup tags.
    ({ "Name" = format("%s%01d", var.name, count.index + 1) }),
    ({ "os_drive" = "c" })
  )
  vpc_security_group_ids = var.vpc_security_group_ids

  lifecycle {
    ignore_changes = [ami, user_data]
  }
}

###########################
# VPC DHCP Options
###########################

resource "aws_vpc_dhcp_options" "dc_dns" {
  count               = var.enable_dhcp_options ? 1 : 0
  domain_name         = var.domain_name
  domain_name_servers = aws_instance.ec2_instance[*].private_ip
  # Optional custom NTP servers; when the list is empty, no NTP servers are set in DHCP options
  ntp_servers = var.ntp_servers
  tags        = merge(var.tags, ({ "Name" = format("%s-dhcp-options", var.name) }))
}

resource "aws_vpc_dhcp_options_association" "dc_dns" {
  count           = var.enable_dhcp_options ? 1 : 0
  dhcp_options_id = aws_vpc_dhcp_options.dc_dns[0].id
  vpc_id          = var.vpc_id
}


###################################################
# CloudWatch Alarms
###################################################
# Set create_cloudwatch_alarms = false to disable these alarms.
# Alarm period adjusts based on monitoring mode: 60s for detailed, 300s for basic (to match metric availability).

#####################
# Status Check Failed Instance Metric
#####################

resource "aws_cloudwatch_metric_alarm" "instance" {
  count               = var.create_cloudwatch_alarms ? var.number : 0
  actions_enabled     = true
  alarm_actions       = []
  alarm_description   = "EC2 instance StatusCheckFailed_Instance alarm"
  alarm_name          = format("%s-instance-alarm", element(aws_instance.ec2_instance[*].id, count.index))
  comparison_operator = "GreaterThanOrEqualToThreshold"
  datapoints_to_alarm = 2
  dimensions = {
    InstanceId = element(aws_instance.ec2_instance[*].id, count.index)
  }
  evaluation_periods        = "2"
  insufficient_data_actions = []
  metric_name               = "StatusCheckFailed_Instance"
  namespace                 = "AWS/EC2"
  ok_actions                = []
  period                    = var.enable_detailed_monitoring ? "60" : "300" # 60s for detailed, 300s for basic (free)
  statistic                 = "Maximum"
  threshold                 = "1"
  treat_missing_data        = "missing"
}

#####################
# Status Check Failed System Metric
#####################

resource "aws_cloudwatch_metric_alarm" "system" {
  count               = var.create_cloudwatch_alarms ? var.number : 0
  actions_enabled     = true
  alarm_actions       = ["arn:aws:automate:${data.aws_region.current.id}:ec2:recover"]
  alarm_description   = "EC2 instance StatusCheckFailed_System alarm"
  alarm_name          = format("%s-system-alarm", element(aws_instance.ec2_instance[*].id, count.index))
  comparison_operator = "GreaterThanOrEqualToThreshold"
  datapoints_to_alarm = 2
  dimensions = {
    InstanceId = element(aws_instance.ec2_instance[*].id, count.index)
  }
  evaluation_periods        = "2"
  insufficient_data_actions = []
  metric_name               = "StatusCheckFailed_System"
  namespace                 = "AWS/EC2"
  ok_actions                = []
  period                    = var.enable_detailed_monitoring ? "60" : "300" # 60s for detailed, 300s for basic (free)
  statistic                 = "Maximum"
  threshold                 = "1"
  treat_missing_data        = "missing"
}
