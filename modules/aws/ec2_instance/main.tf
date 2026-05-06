# Setting the required version of Terraform and AWS provider
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

data "aws_caller_identity" "current" {}

data "aws_ec2_instance_type" "this" {
  instance_type = var.instance_type
}

locals {
  # Exclude specific tag keys from the root volume to avoid selecting the root EBS volume separately in tag-based backup workflows.
  root_volume_tags = var.exclude_root_volume_snapshot ? {
    for k, v in var.tags : k => v if !contains(var.root_volume_excluded_tag_keys, k)
  } : var.tags

  # When var.enable_recover_action is null (default), auto-detect from the instance type data source.
  # When explicitly set to true/false, use the caller's override.
  recover_action_enabled = var.enable_recover_action != null ? var.enable_recover_action : data.aws_ec2_instance_type.this.auto_recovery_supported
}

#############################
# EC2 instance Module
#############################
# Creating an EC2 instance with various parameters specified in the module variables.
# Reference variables.tf for questions about arguments
resource "aws_instance" "ec2" {
  ami                                  = var.ami
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
  # Only set user_data if user_data_base64 is not provided (prevents base64 warning)
  user_data = var.user_data_base64 != "" ? null : (var.user_data != "" ? var.user_data : null)
  # Only set user_data_base64 if explicitly provided
  user_data_base64       = var.user_data_base64 != "" ? var.user_data_base64 : null
  vpc_security_group_ids = var.vpc_security_group_ids

  lifecycle {
    ignore_changes = [ami, user_data]
  }
}

###################################################
# CloudWatch Alarms
###################################################
# Creating a CloudWatch metric alarm for each instance. This alarm triggers if the status check of the instance fails.
# Set create_cloudwatch_alarms = false to disable these alarms.
# Alarm period adjusts based on monitoring mode: 60s for detailed, 300s for basic (to match metric availability).
resource "aws_cloudwatch_metric_alarm" "instance" {
  count         = var.create_cloudwatch_alarms ? 1 : 0
  alarm_actions = [] # No 'Recover' action for StatusCheckFailed_Instance metric

  actions_enabled     = true
  alarm_description   = "EC2 instance StatusCheckFailed_Instance alarm"
  alarm_name          = format("%s-instance-alarm", aws_instance.ec2.id)
  comparison_operator = "GreaterThanOrEqualToThreshold"
  datapoints_to_alarm = 2
  dimensions = {
    InstanceId = aws_instance.ec2.id
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

resource "aws_cloudwatch_metric_alarm" "system" {
  count = var.create_cloudwatch_alarms ? 1 : 0
  # Auto-detected from instance type by default, or explicitly overridden via var.enable_recover_action.
  alarm_actions = local.recover_action_enabled ? ["arn:aws:automate:${data.aws_region.current.id}:ec2:recover"] : []

  actions_enabled     = true
  alarm_description   = "EC2 instance StatusCheckFailed_System alarm"
  alarm_name          = format("%s-system-alarm", aws_instance.ec2.id)
  comparison_operator = "GreaterThanOrEqualToThreshold"
  datapoints_to_alarm = 2
  dimensions = {
    InstanceId = aws_instance.ec2.id
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
