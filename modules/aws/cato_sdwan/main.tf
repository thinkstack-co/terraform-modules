terraform {
  required_version = ">= 1.0.0"
}

############################################
# Data Sources
############################################
data "aws_caller_identity" "current" {}
data "aws_region" "current" {}

############################################
# Security Groups
############################################

resource "aws_security_group" "cato_wan_mgmt_sg" {
  name        = var.wan_mgmt_sg_name
  description = "Security group applied to Cato SDWAN instance WAN and MGMT NICs for Cato Cloud communication"
  vpc_id      = var.vpc_id

  egress {
    from_port   = 443
    to_port     = 443
    protocol    = "TCP"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port   = 443
    to_port     = 443
    protocol    = "UDP"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = merge(var.tags, ({ "Name" = format("%s", var.wan_mgmt_sg_name) }))
}

resource "aws_security_group" "cato_lan_sg" {
  name        = var.lan_sg_name
  description = "Security group applied to Cato SDWAN instance LAN NICs for SDWAN communication"
  vpc_id      = var.vpc_id

  ingress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = var.cato_lan_cidr_blocks
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = merge(var.tags, ({ "Name" = format("%s", var.lan_sg_name) }))
}

############################################
# EIP
############################################

resource "aws_eip" "wan_external_ip" {
  vpc   = true
  count = var.number
}

resource "aws_eip_association" "wan_external_ip" {
  count                = var.number
  allocation_id        = element(aws_eip.wan_external_ip.*.id, count.index)
  network_interface_id = element(aws_network_interface.public_nic.*.id, count.index)
}

############################################
# ENI
############################################

resource "aws_network_interface" "mgmt_nic" {
  count             = var.number
  description       = var.mgmt_nic_description
  private_ips       = var.mgmt_ips
  security_groups   = [aws_security_group.cato_wan_mgmt_sg.id]
  subnet_id         = element(var.mgmt_subnet_id, count.index)
  tags              = merge(var.tags, ({ "Name" = format("%s%d_mgmt", var.instance_name_prefix, count.index + 1) }))
}

resource "aws_network_interface" "public_nic" {
  count             = var.number
  description       = var.public_nic_description
  private_ips       = [element(var.public_ips, count.index)]
  security_groups   = [aws_security_group.cato_wan_mgmt_sg.id]
  subnet_id         = element(var.public_subnet_id, count.index)
  tags              = merge(var.tags, ({ "Name" = format("%s%d_public", var.instance_name_prefix, count.index + 1) }))

  attachment {
    instance     = element(aws_instance.ec2_instance.*.id, count.index)
    device_index = 1
  }
}

resource "aws_network_interface" "private_nic" {
  count             = var.number
  description       = var.private_nic_description
  private_ips       = [element(var.private_ips, count.index)]
  security_groups   = [aws_security_group.cato_lan_sg.id]
  source_dest_check = var.source_dest_check
  subnet_id         = element(var.private_subnet_id, count.index)
  tags              = merge(var.tags, ({ "Name" = format("%s%d_private", var.instance_name_prefix, count.index + 1) }))

  attachment {
    instance     = element(aws_instance.ec2_instance.*.id, count.index)
    device_index = 2
  }
}

############################################
# EC2 Instance
############################################

resource "aws_instance" "ec2_instance" {
  ami                  = var.ami
  # availability_zone    = var.availability_zone
  count                = var.number
  ebs_optimized        = var.ebs_optimized
  iam_instance_profile = var.iam_instance_profile
  instance_type        = var.instance_type
  key_name             = var.key_name
  monitoring           = var.monitoring
  volume_tags          = merge(var.tags, ({ "Name" = format("%s%d", var.instance_name_prefix, count.index + 1) }))
  tags                 = merge(var.tags, ({ "Name" = format("%s%d", var.instance_name_prefix, count.index + 1) }))
  user_data            = var.user_data

  network_interface {
    network_interface_id = element(aws_network_interface.mgmt_nic.*.id, count.index)
    device_index         = 0
  }

  root_block_device {
    volume_type = var.root_volume_type
    volume_size = var.root_volume_size
    encrypted   = var.root_ebs_volume_encrypted
  }
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
  alarm_actions       = ["arn:aws:automate:${data.aws_region.current.name}:ec2:recover"]
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
