terraform {
  required_version = ">= 1.0.0"
}

resource "aws_instance" "ec2_instance" {
  ami = var.ami
  # This is redundant with the subnet_id option set. The subnet_id already defines an availability zone
  # availability_zone                    = element(var.availability_zone, count.index)
  count                                = var.number
  disable_api_termination              = var.disable_api_termination
  ebs_optimized                        = var.ebs_optimized
  iam_instance_profile                 = var.iam_instance_profile
  instance_initiated_shutdown_behavior = var.instance_initiated_shutdown_behavior
  instance_type                        = var.instance_type
  key_name                             = var.key_name
  monitoring                           = var.monitoring
  placement_group                      = var.placement_group
  private_ip                           = element(var.private_ip, count.index)
  root_block_device {
    delete_on_termination = var.root_delete_on_termination
    encrypted             = var.encrypted
    # iops                = var.root_iops
    volume_size = var.root_volume_size
    volume_type = var.root_volume_type
  }
  source_dest_check      = var.source_dest_check
  subnet_id              = element(var.subnet_id, count.index)
  tenancy                = var.tenancy
  tags                   = merge(var.tags, ({ "Name" = format("%s%01d", var.name, count.index + 1) }))
  user_data              = var.user_data
  volume_tags            = merge(var.tags, ({ "Name" = format("%s%01d", var.name, count.index + 1) }))
  vpc_security_group_ids = var.vpc_security_group_ids

  lifecycle {
    ignore_changes = [ami, user_data]
  }
}

resource "aws_vpc_dhcp_options" "dc_dns" {
  count               = var.enable_dhcp_options ? 1 : 0
  domain_name_servers = aws_instance.ec2_instance[*].private_ip
  domain_name         = var.domain_name
  tags                = merge(var.tags, ({ "Name" = format("%s-dhcp-options", var.name) }))
}

resource "aws_vpc_dhcp_options_association" "dc_dns" {
  count           = var.enable_dhcp_options ? 1 : 0
  dhcp_options_id = aws_vpc_dhcp_options.dc_dns[0].id
  vpc_id          = var.vpc_id
}


###################################################
# CloudWatch Alarms
###################################################

#####################
# Status Check Failed Instance Metric
#####################

resource "aws_cloudwatch_metric_alarm" "instance" {
  actions_enabled     = true
  alarm_actions       = []
  alarm_description   = "EC2 instance StatusCheckFailed_Instance alarm"
  alarm_name          = format("%s-instance-alarm", element(aws_instance.ec2_instance.*.id, count.index))
  comparison_operator = "GreaterThanOrEqualToThreshold"
  count               = var.number
  datapoints_to_alarm = 2
  dimensions = {
    InstanceId = element(aws_instance.ec2_instance.*.id, count.index)
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
  actions_enabled     = true
  alarm_actions       = ["arn:aws:automate:${var.region}:ec2:recover"]
  alarm_description   = "EC2 instance StatusCheckFailed_System alarm"
  alarm_name          = format("%s-system-alarm", element(aws_instance.ec2_instance.*.id, count.index))
  comparison_operator = "GreaterThanOrEqualToThreshold"
  count               = var.number
  datapoints_to_alarm = 2
  dimensions = {
    InstanceId = element(aws_instance.ec2_instance.*.id, count.index)
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
