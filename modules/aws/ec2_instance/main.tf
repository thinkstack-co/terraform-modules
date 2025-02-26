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

# Retrieving the current AWS region
data "aws_region" "current" {}

# Dynamically check instance type information for auto recovery support
data "aws_ec2_instance_type" "instance_type_info" {
  instance_type = var.instance_type
}

# Creating EC2 instance with the specified configuration
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
  source_dest_check                    = var.source_dest_check
  subnet_id                            = var.subnet_id
  tenancy                              = var.tenancy
  user_data                            = var.user_data
  vpc_security_group_ids               = var.vpc_security_group_ids

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
    tags                  = merge(var.tags, ({ "Name" = var.name }))
    volume_type           = var.root_volume_type
    volume_size           = var.root_volume_size
    iops                  = var.root_volume_type == "io1" || var.root_volume_type == "io2" || var.root_volume_type == "gp3" ? var.root_volume_iops : null
    throughput            = var.root_volume_type == "gp3" ? var.root_volume_throughput : null
  }

  tags = merge(
    {
      "Name" = var.name
    },
    var.tags,
  )

  lifecycle {
    ignore_changes = [ami, user_data]
  }
}

# Creating a CloudWatch metric alarm for the instance. This alarm triggers if the instance status check fails.
resource "aws_cloudwatch_metric_alarm" "instance" {
  alarm_actions             = ["arn:aws:automate:${data.aws_region.current.name}:ec2:reboot"]
  actions_enabled           = true
  alarm_description         = "EC2 instance StatusCheckFailed_Instance alarm"
  alarm_name                = format("%s-instance-alarm", aws_instance.ec2.id)
  comparison_operator       = "GreaterThanOrEqualToThreshold"
  datapoints_to_alarm       = 2
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

# Creating another CloudWatch metric alarm for the instance. This alarm triggers if the system status check of the instance fails.
resource "aws_cloudwatch_metric_alarm" "system" {
  # Determine if recovery actions should be enabled based on:
  # 1. If the user has explicitly disabled recovery actions
  # 2. If the instance is in an Auto Scaling group (detected by checking for ASG tags)
  # 3. If the instance type doesn't support recovery actions (determined dynamically)
  # Note: We still create the alarm, but we don't add the recovery action if it's not supported
  alarm_actions = (
    var.disable_recovery_actions || 
    contains(keys(aws_instance.ec2.tags), "aws:autoscaling:groupName") ||
    contains(var.additional_unsupported_instance_types, var.instance_type) ||
    !data.aws_ec2_instance_type.instance_type_info.auto_recovery_supported
  ) ? [] : ["arn:aws:automate:${data.aws_region.current.name}:ec2:recover"]

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
