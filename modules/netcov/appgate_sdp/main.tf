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

data "aws_ec2_instance_type" "this" {
  instance_type = var.instance_type
}

# Purpose:       Resolves the AppGate SDP BYOL marketplace AMI matching the configured
#                version/arch filters; used as the launch image for the gateway instance.
# Referenced by: aws_instance.appgate (ami argument)
# References:    var.ami_name_filter, var.ami_architecture, var.ami_virtualization_type
# Why:           most_recent = true keeps the lookup current, but aws_instance.appgate
#                ignores ami changes after launch (see its lifecycle block), so a running
#                gateway never rebuilds just because a newer marketplace image appears.
data "aws_ami" "appgate_sdp" {
  most_recent = true
  owners      = ["aws-marketplace"]

  filter {
    name   = "name"
    values = [var.ami_name_filter]
  }

  filter {
    name   = "virtualization-type"
    values = [var.ami_virtualization_type]
  }

  filter {
    name   = "architecture"
    values = [var.ami_architecture]
  }
}

locals {
  # Exclude specific tag keys from the root volume to avoid selecting the root EBS volume
  # separately in tag-based backup workflows.
  root_volume_tags = var.exclude_root_volume_snapshot ? {
    for k, v in var.tags : k => v if !contains(var.root_volume_excluded_tag_keys, k)
  } : var.tags

  # When var.enable_recover_action is null (default), auto-detect from the instance type
  # data source. When explicitly set, use the caller's override.
  recover_action_enabled = var.enable_recover_action != null ? var.enable_recover_action : data.aws_ec2_instance_type.this.auto_recovery_supported
}

#############################
# AppGate SDP Gateway Instance
#############################

# Purpose:       The AppGate SDP gateway EC2 instance, launched from the resolved marketplace AMI.
# Referenced by: aws_eip.appgate, aws_cloudwatch_metric_alarm.instance/system, module outputs
# References:    data.aws_ami.appgate_sdp, instance-shaping input variables, local.root_volume_tags
# Why:           associate_public_ip_address is gated by var.associate_public_ip_address so the
#                gateway can be deployed public-facing (default) or private when fronted by a load
#                balancer / existing address. ami + user_data are ignored after launch so a running
#                gateway is never replaced by a newer marketplace image.
resource "aws_instance" "appgate" {
  ami                                  = data.aws_ami.appgate_sdp.id
  associate_public_ip_address          = var.associate_public_ip_address
  availability_zone                    = var.availability_zone
  disable_api_termination              = var.disable_api_termination
  ebs_optimized                        = var.ebs_optimized
  iam_instance_profile                 = var.iam_instance_profile
  instance_initiated_shutdown_behavior = var.instance_initiated_shutdown_behavior
  instance_type                        = var.instance_type
  ipv6_addresses                       = var.ipv6_addresses
  key_name                             = var.key_name
  monitoring                           = var.enable_detailed_monitoring
  placement_group                      = var.placement_group
  private_ip                           = var.private_ip

  metadata_options {
    http_endpoint = var.http_endpoint
    http_tokens   = var.http_tokens
  }

  root_block_device {
    delete_on_termination = var.root_delete_on_termination
    encrypted             = var.encrypted
    tags                  = merge(local.root_volume_tags, ({ "Name" = var.name }))
    volume_type           = var.root_volume_type
    volume_size           = var.root_volume_size
    iops                  = var.root_volume_iops
    throughput            = var.root_volume_throughput
  }

  source_dest_check = var.source_dest_check
  subnet_id         = var.subnet_id
  tags              = merge(var.tags, ({ "Name" = var.name }))
  tenancy           = var.tenancy
  # Only set user_data if user_data_base64 is not provided (prevents base64 warning).
  user_data = var.user_data_base64 != "" ? null : (var.user_data != "" ? var.user_data : null)
  # Only set user_data_base64 if explicitly provided.
  user_data_base64       = var.user_data_base64 != "" ? var.user_data_base64 : null
  vpc_security_group_ids = var.vpc_security_group_ids

  lifecycle {
    ignore_changes = [ami, user_data]

    # Why: A public-facing gateway must land on a known, stable address inside a public
    #      subnet. Requiring private_ip whenever associate_public_ip_address is true keeps
    #      the gateway from being assigned a random in-subnet address on a public-subnet launch.
    precondition {
      condition     = var.associate_public_ip_address == false || (var.private_ip != null && var.private_ip != "")
      error_message = "When associate_public_ip_address is true, private_ip must be set to an address within one of the public subnets."
    }
  }
}

#############
# Elastic IP
#############

# Purpose:       Allocates and associates a stable public EIP with the AppGate gateway so its
#                public address survives stop/start and instance replacement.
# Referenced by: module outputs (eip_id, eip_public_ip)
# References:    aws_instance.appgate, var.create_eip, var.eip_associate_with_private_ip
# Why:           Gated behind var.create_eip so the gateway can also run without a dedicated EIP
#                (e.g. fronted by an NLB or a pre-existing address).
resource "aws_eip" "appgate" {
  count = var.create_eip ? 1 : 0

  instance                  = aws_instance.appgate.id
  associate_with_private_ip = var.eip_associate_with_private_ip
  domain                    = "vpc"
  tags                      = merge(var.tags, ({ "Name" = var.name }))
}

###################################################
# CloudWatch Alarms
###################################################

# Purpose:       Alarms when the instance status check fails. No recover action (instance-level
#                status failures are not auto-recoverable).
# Referenced by: module outputs (instance_alarm_id)
# References:    aws_instance.appgate, var.create_cloudwatch_alarms, var.enable_detailed_monitoring
resource "aws_cloudwatch_metric_alarm" "instance" {
  count         = var.create_cloudwatch_alarms ? 1 : 0
  alarm_actions = [] # No 'Recover' action for StatusCheckFailed_Instance metric

  actions_enabled     = true
  alarm_description   = "AppGate SDP instance StatusCheckFailed_Instance alarm"
  alarm_name          = format("%s-instance-alarm", aws_instance.appgate.id)
  comparison_operator = "GreaterThanOrEqualToThreshold"
  datapoints_to_alarm = 2
  dimensions = {
    InstanceId = aws_instance.appgate.id
  }
  evaluation_periods        = "2"
  insufficient_data_actions = []
  metric_name               = "StatusCheckFailed_Instance"
  namespace                 = "AWS/EC2"
  ok_actions                = []
  period                    = var.enable_detailed_monitoring ? "60" : "300" # 60s detailed, 300s basic (free)
  statistic                 = "Maximum"
  threshold                 = "1"
  treat_missing_data        = "missing"
}

# Purpose:       Alarms when the system status check fails, optionally triggering the EC2 recover
#                action when the instance type supports it.
# Referenced by: module outputs (system_alarm_id)
# References:    aws_instance.appgate, local.recover_action_enabled, var.create_cloudwatch_alarms
resource "aws_cloudwatch_metric_alarm" "system" {
  count = var.create_cloudwatch_alarms ? 1 : 0
  # Auto-detected from instance type by default, or explicitly overridden via var.enable_recover_action.
  alarm_actions = local.recover_action_enabled ? ["arn:aws:automate:${data.aws_region.current.region}:ec2:recover"] : []

  actions_enabled     = true
  alarm_description   = "AppGate SDP instance StatusCheckFailed_System alarm"
  alarm_name          = format("%s-system-alarm", aws_instance.appgate.id)
  comparison_operator = "GreaterThanOrEqualToThreshold"
  datapoints_to_alarm = 2
  dimensions = {
    InstanceId = aws_instance.appgate.id
  }
  evaluation_periods        = "2"
  insufficient_data_actions = []
  metric_name               = "StatusCheckFailed_System"
  namespace                 = "AWS/EC2"
  ok_actions                = []
  period                    = var.enable_detailed_monitoring ? "60" : "300" # 60s detailed, 300s basic (free)
  statistic                 = "Maximum"
  threshold                 = "1"
  treat_missing_data        = "missing"
}
