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

# Retrieving the current AWS account ID
data "aws_caller_identity" "current" {}

# Dynamically check instance type information for auto recovery support
data "aws_ec2_instance_type" "instance_type_info" {
  instance_type = var.instance_type
}

# Local variables for configuration logic
locals {
  # List of instance types that support CloudWatch recovery actions
  # Based on AWS documentation: https://docs.aws.amazon.com/AWSEC2/latest/UserGuide/cloudwatch-recovery.html
  recovery_supported_instance_families = [
    # General purpose
    "a1", "m3", "m4", "m5", "m5a", "m5n", "m5zn", "m6a", "m6g", "m6i", "m6in", 
    "m7a", "m7g", "m7i", "m7i-flex", "m8g", "t1", "t2", "t3", "t3a", "t4g",
    # Compute optimized
    "c3", "c4", "c5", "c5a", "c5n", "c6a", "c6g", "c6gn", "c6i", "c6in", 
    "c7a", "c7g", "c7gn", "c7i", "c7i-flex", "c8g",
    # Memory optimized
    "r3", "r4", "r5", "r5a", "r5b", "r5n", "r6a", "r6g", "r6i", "r6in", 
    "r7a", "r7g", "r7i", "r7iz", "r8g", "u-3tb1", "u-6tb1", "u-9tb1", 
    "u-12tb1", "u-18tb1", "u-24tb1", "u7i-6tb", "u7i-8tb", "u7i-12tb", 
    "u7in-16tb", "u7in-24tb", "u7in-32tb", "u7inh-32tb", "x1", "x1e", 
    "x2idn", "x2iedn", "x2iezn", "x8g",
    # Accelerated computing
    "g3", "g5g", "inf1", "p2", "p3", "vt1",
    # High-performance computing
    "hpc6a", "hpc7a", "hpc7g"
  ]

  # Extract instance family from instance type (e.g., m4.large -> m4)
  # Use try() to handle potential regex failures gracefully
  instance_family = try(regex("^([a-z0-9-]+)[.]", var.instance_type)[0], "unknown")
  
  # Check if instance family is in the supported list
  is_recovery_supported = contains(local.recovery_supported_instance_families, local.instance_family)
  
  # Check for instance store volumes - only specific instance types support recovery with instance store volumes
  instance_store_supported_with_recovery = ["m3", "c3", "r3", "x1", "x1e", "x2idn", "x2iedn"]
  has_instance_store = length(var.ephemeral_block_device) > 0
  instance_store_recovery_supported = !has_instance_store || contains(instance_store_supported_with_recovery, local.instance_family)
  
  # Check if the instance is in a pending or running state
  # Recovery actions will work on running instances, and pending instances will soon be running
  is_instance_running = contains(["pending", "running"], aws_instance.ec2.instance_state)
  
  # Determine if recovery actions should be disabled based on multiple factors
  # According to AWS docs: https://docs.aws.amazon.com/AWSEC2/latest/UserGuide/cloudwatch-recovery.html
  disable_recovery = (
    # User explicitly disabled recovery
    var.disable_recovery_actions || 
    # Instance is part of an Auto Scaling group (detected via tags)
    contains(keys(aws_instance.ec2.tags), "aws:autoscaling:groupName") ||
    # Instance type is in user-provided list of unsupported types
    contains(var.additional_unsupported_instance_types, var.instance_type) ||
    # Instance family not in supported list
    !local.is_recovery_supported ||
    # Instance has instance store volumes but instance type doesn't support recovery with them
    (has_instance_store && !local.instance_store_recovery_supported) ||
    # Instance has host tenancy (Dedicated Host)
    var.tenancy == "host" ||
    # Instance is on a dedicated host
    var.host_id != null ||
    # Instance uses Elastic Fabric Adapter (determined by user flag)
    var.uses_efa ||
    # Instance is not in pending or running state
    !local.is_instance_running
  )
}

# Creating EC2 instance with the specified configuration
resource "aws_instance" "ec2" {
  ami                                  = var.ami
  associate_public_ip_address          = var.associate_public_ip_address
  availability_zone                    = var.availability_zone
  disable_api_termination              = var.disable_api_termination
  ebs_optimized                        = var.ebs_optimized
  host_id                              = var.host_id
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

  # Configure network interface with optional Elastic Fabric Adapter support
  dynamic "network_interface" {
    for_each = var.network_interface != null ? [var.network_interface] : []
    content {
      device_index          = network_interface.value.device_index
      network_interface_id  = network_interface.value.network_interface_id
      delete_on_termination = lookup(network_interface.value, "delete_on_termination", false)
    }
  }

  # Configure ephemeral block devices if specified
  dynamic "ephemeral_block_device" {
    for_each = var.ephemeral_block_device
    content {
      device_name  = ephemeral_block_device.value.device_name
      virtual_name = lookup(ephemeral_block_device.value, "virtual_name", null)
      no_device    = lookup(ephemeral_block_device.value, "no_device", null)
    }
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
  # Use the local variable to determine if recovery actions should be enabled
  alarm_actions = local.disable_recovery ? [] : ["arn:aws:automate:${data.aws_region.current.name}:ec2:recover"]

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
  # Always include ok_actions with a dummy value to avoid the Terraform/AWS API issue
  # See: https://github.com/hashicorp/terraform/issues/5388
  ok_actions                = local.disable_recovery ? [] : ["arn:aws:sns:${data.aws_region.current.name}:${data.aws_caller_identity.current.account_id}:dummy-topic"]
  period                    = "60"
  statistic                 = "Maximum"
  threshold                 = "1"
  treat_missing_data        = "missing"
}
