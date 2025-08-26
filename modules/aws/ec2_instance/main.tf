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
# Fetching the current region data
data "aws_region" "current" {}

# Fetching the current AWS caller identity
data "aws_caller_identity" "current" {}

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
    tags                  = merge(var.tags, ({ "Name" = var.name }))
    volume_type           = var.root_volume_type
    volume_size           = var.root_volume_size
    iops                  = var.root_volume_iops
    throughput            = var.root_volume_throughput
  }

  source_dest_check      = var.source_dest_check
  subnet_id              = var.subnet_id
  tags                   = merge(var.tags, ({ "Name" = var.name }))
  tenancy                = var.tenancy
  user_data              = var.user_data_base64 != "" ? null : var.user_data
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
resource "aws_cloudwatch_metric_alarm" "instance" {
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
  period                    = "60"
  statistic                 = "Maximum"
  threshold                 = "1"
  treat_missing_data        = "missing"
}

# Creating another CloudWatch metric alarm for each instance. This alarm triggers if the system status check of the instance fails.
resource "aws_cloudwatch_metric_alarm" "system" {
  #If the instance is of a type that does not support recovery actions, no action is taken when the alarm is triggered.
  #If it does support recovery, AWS attempts to recover the instance when the alarm is triggered.
  alarm_actions = contains(local.recover_action_unsupported_instances, aws_instance.ec2.instance_type) ? [] : ["arn:aws:automate:${data.aws_region.current.name}:ec2:recover"]

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
  period                    = "60"
  statistic                 = "Maximum"
  threshold                 = "1"
  treat_missing_data        = "missing"
}
