terraform {
  required_version = ">= 1.0.0"
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = ">= 4.0.0, < 7.0.0"
    }
  }
}

###########################
# Data Sources
###########################
data "aws_region" "current" {}

locals {
  # Build a map of DC keys ("dc1", "dc2", ...) to their per-instance attributes.
  # for_each (rather than count) is used so that disabling one DC does not shift
  # the other's resource address. var.disabled_dcs filters specific keys out.
  dcs = {
    for idx in range(var.number) :
    format("dc%d", idx + 1) => {
      private_ip = element(var.private_ip, idx)
      subnet_id  = element(var.subnet_id, idx)
      name       = format("%s%01d", var.name, idx + 1)
    }
    if !contains(var.disabled_dcs, format("dc%d", idx + 1))
  }

  # Remove backup selection tags from root volume tags when exclude_root_volume_snapshot is enabled.
  root_volume_tags = var.exclude_root_volume_snapshot ? {
    for k, v in var.tags : k => v if !contains(var.root_volume_excluded_tag_keys, k)
  } : var.tags
}

###########################
# EC2 Instance
###########################

resource "aws_instance" "ec2_instance" {
  for_each                             = local.dcs
  ami                                  = var.ami
  disable_api_termination              = var.disable_api_termination
  ebs_optimized                        = var.ebs_optimized
  iam_instance_profile                 = var.iam_instance_profile
  instance_initiated_shutdown_behavior = var.instance_initiated_shutdown_behavior
  instance_type                        = var.instance_type
  key_name                             = var.key_name
  monitoring                           = var.enable_detailed_monitoring
  placement_group                      = var.placement_group
  private_ip                           = each.value.private_ip

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
  subnet_id         = each.value.subnet_id
  tenancy           = var.tenancy
  tags              = merge(var.tags, ({ "Name" = each.value.name }))
  user_data         = var.user_data
  volume_tags = merge(
    local.root_volume_tags, # Use filtered tags when excluding root volume backup tags.
    ({ "Name" = each.value.name }),
    ({ "os_drive" = "c" })
  )
  vpc_security_group_ids = var.vpc_security_group_ids

  lifecycle {
    ignore_changes = [ami, user_data]
  }
}

# v2.10.0 re-keyed the DC instance from count to for_each ("dc1","dc2",...).
# These moved blocks migrate existing count-indexed state in place (index N ->
# "dc{N+1}") so the upgrade renames rather than destroys live domain controllers.
# Static set covers up to 6 DCs; unmatched entries are no-ops.
moved {
  from = aws_instance.ec2_instance[0]
  to   = aws_instance.ec2_instance["dc1"]
}
moved {
  from = aws_instance.ec2_instance[1]
  to   = aws_instance.ec2_instance["dc2"]
}
moved {
  from = aws_instance.ec2_instance[2]
  to   = aws_instance.ec2_instance["dc3"]
}
moved {
  from = aws_instance.ec2_instance[3]
  to   = aws_instance.ec2_instance["dc4"]
}
moved {
  from = aws_instance.ec2_instance[4]
  to   = aws_instance.ec2_instance["dc5"]
}
moved {
  from = aws_instance.ec2_instance[5]
  to   = aws_instance.ec2_instance["dc6"]
}

###########################
# VPC DHCP Options
###########################

resource "aws_vpc_dhcp_options" "dc_dns" {
  count       = var.enable_dhcp_options ? 1 : 0
  domain_name = var.domain_name
  # Iterate the for_each map; keys sort alphabetically so dc1's IP comes before dc2's.
  domain_name_servers = [for inst in aws_instance.ec2_instance : inst.private_ip]
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
  # Alarm per DC; skip entirely when create_cloudwatch_alarms is false.
  for_each = {
    for k, v in aws_instance.ec2_instance : k => v
    if var.create_cloudwatch_alarms
  }
  actions_enabled     = true
  alarm_actions       = []
  alarm_description   = "EC2 instance StatusCheckFailed_Instance alarm"
  alarm_name          = format("%s-instance-alarm", each.value.id)
  comparison_operator = "GreaterThanOrEqualToThreshold"
  datapoints_to_alarm = 2
  dimensions = {
    InstanceId = each.value.id
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
  # Alarm per DC; skip entirely when create_cloudwatch_alarms is false.
  for_each = {
    for k, v in aws_instance.ec2_instance : k => v
    if var.create_cloudwatch_alarms
  }
  actions_enabled     = true
  alarm_actions       = ["arn:aws:automate:${data.aws_region.current.region}:ec2:recover"]
  alarm_description   = "EC2 instance StatusCheckFailed_System alarm"
  alarm_name          = format("%s-system-alarm", each.value.id)
  comparison_operator = "GreaterThanOrEqualToThreshold"
  datapoints_to_alarm = 2
  dimensions = {
    InstanceId = each.value.id
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
