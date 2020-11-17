terraform {
  required_version = ">= 0.12.0"
}

resource "aws_network_interface" "eni" {
  count               = var.eni_number
  description         = var.description
  subnet_id           = element(var.subnet_id, [count.index])
  private_ips         = element(var.private_ips, [count.index])
  private_ips_count   = element(var.private_ips_count, [count.index])
  security_groups     = var.vpc_security_group_ids
  source_dest_check   = var.source_dest_check
  tags                = var.tags

  # Attachment varaible conflicts with the attachment within the aws_instance resource
  # attachment          = var.attachment

  lifecycle           = {
    prevent_destroy   = true
  }
}

resource "aws_instance" "ec2" {
  ami                                  = var.ami
  # associate_public_ip_address          = var.associate_public_ip_address
  availability_zone                    = var.availability_zone
  count                                = var.number
  disable_api_termination              = var.disable_api_termination
  ebs_optimized                        = var.ebs_optimized
  # ebs_block_device                     = var.ebs_block_device
  # ephemeral_block_device               = var.ephemeral_block_device
  key_name                             = var.key_name
  monitoring                           = var.monitoring
  placement_group                      = var.placement_group
  tenancy                              = var.tenancy
  instance_initiated_shutdown_behavior = var.instance_initiated_shutdown_behavior
  instance_type                        = var.instance_type
  # subnet_id                            = var.subnet_id
  # private_ip                           = var.private_ip
  # source_dest_check                    = var.source_dest_check
  user_data                            = var.user_data
  iam_instance_profile                 = var.iam_instance_profile
  # ipv6_address_count                   = var.ipv6_address_count
  # ipv6_addresses                       = var.ipv6_addresses
  tags                                 = merge(var.tags, map("Name", format("%s%01d", var.name, count.index + 1)))
  volume_tags                          = merge(var.tags, map("Name", format("%s%01d", var.name, count.index + 1)))
  # root_block_device                    = var.root_block_device
  

  network_interface {
        network_interface_id    = aws_network_interface.eni.id
        device_index            = var.device_index
        delete_on_termination   = var.delete_on_termination
  }

  # vpc_security_group_ids               = var.vpc_security_group_ids

  lifecycle {
    ignore_changes  = [user_data, volume_tags]
  }
}

###################################################
# CloudWatch Alarms
###################################################

#####################
# Status Check Failed Instance Metric
#####################

resource "aws_cloudwatch_metric_alarm" "instance" {
  actions_enabled           = true
  alarm_actions             = []
  alarm_description         = "EC2 instance StatusCheckFailed_Instance alarm"
  alarm_name                = format("%s-instance-alarm", element(aws_instance.ec2.*.id, count.index))
  comparison_operator       = "GreaterThanOrEqualToThreshold"
  count                     = var.number
  datapoints_to_alarm       = 2
  dimensions                = {
    InstanceId = element(aws_instance.ec2.*.id, count.index)
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
  #unit                      = var.unit
}

#####################
# Status Check Failed System Metric
#####################

resource "aws_cloudwatch_metric_alarm" "system" {
  actions_enabled           = true
  alarm_actions             = ["arn:aws:automate:${var.region}:ec2:recover"]
  alarm_description         = "EC2 instance StatusCheckFailed_System alarm"
  alarm_name                = format("%s-system-alarm", element(aws_instance.ec2.*.id, count.index))
  comparison_operator       = "GreaterThanOrEqualToThreshold"
  count                     = var.number
  datapoints_to_alarm       = 2
  dimensions                = {
    InstanceId = element(aws_instance.ec2.*.id, count.index)
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
  #unit                      = var.unit
}
