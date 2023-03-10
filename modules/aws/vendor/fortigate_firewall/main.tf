terraform {
  required_version = ">= 1.0.0"
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = ">= 4.0.0"
    }
  }
}

resource "aws_security_group" "fortigate_fw_sg" {
  name        = var.sg_name
  description = "Security group applied to all fortigate firewalls"
  vpc_id      = var.vpc_id

  ingress {
    description = "All traffic"
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    # Fortigate Firewall requires communication from all devices
    #tfsec:ignore:aws-ec2-no-public-ingress-sgr
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    description = "All traffic"
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    # Fortigate Firewall requires communication to the internet
    #tfsec:ignore:aws-ec2-no-public-egress-sgr
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = merge(var.tags, ({ "Name" = format("%s", var.sg_name) }))
}

resource "aws_eip" "external_ip" {
  vpc   = true
  count = var.number

  lifecycle {
    prevent_destroy = true
  }
}

resource "aws_eip_association" "fw_external_ip" {
  count                = var.number
  allocation_id        = element(aws_eip.external_ip[*].id, count.index)
  network_interface_id = element(aws_network_interface.fw_public_nic[*].id, count.index)
}

resource "aws_network_interface" "fw_public_nic" {
  count             = var.number
  description       = var.public_nic_description
  private_ips       = var.wan_private_ips
  security_groups   = [aws_security_group.fortigate_fw_sg.id]
  source_dest_check = var.source_dest_check
  subnet_id         = element(var.public_subnet_id, count.index)
  tags              = merge(var.tags, ({ "Name" = format("%s%d_public", var.instance_name_prefix, count.index + 1) }))

  lifecycle {
    ignore_changes = [subnet_id]
  }
}

resource "aws_network_interface" "fw_private_nic" {
  count             = var.number
  description       = var.private_nic_description
  private_ips       = [element(var.lan_private_ips, count.index)]
  security_groups   = [aws_security_group.fortigate_fw_sg.id]
  source_dest_check = var.source_dest_check
  subnet_id         = element(var.private_subnet_id, count.index)
  tags              = merge(var.tags, ({ "Name" = format("%s%d_private", var.instance_name_prefix, count.index + 1) }))

  attachment {
    instance     = element(aws_instance.ec2_instance[*].id, count.index)
    device_index = 1
  }

  lifecycle {
    ignore_changes = [subnet_id]
  }
}

resource "aws_network_interface" "fw_dmz_nic" {
  count             = var.enable_dmz ? var.number : 0
  description       = var.dmz_nic_description
  private_ips       = [element(var.dmz_private_ips, count.index)]
  security_groups   = [aws_security_group.fortigate_fw_sg.id]
  source_dest_check = var.source_dest_check
  subnet_id         = element(var.dmz_subnet_id, count.index)
  tags              = merge(var.tags, ({ "Name" = format("%s%d_dmz", var.instance_name_prefix, count.index + 1) }))

  attachment {
    instance     = element(aws_instance.ec2_instance[*].id, count.index)
    device_index = 2
  }

  lifecycle {
    ignore_changes = [subnet_id]
  }
}

resource "aws_instance" "ec2_instance" {
  ami                  = var.ami_id
  count                = var.number
  ebs_optimized        = var.ebs_optimized
  iam_instance_profile = var.iam_instance_profile
  instance_type        = var.instance_type
  key_name             = var.key_name
  monitoring           = var.monitoring
  volume_tags          = merge(var.tags, ({ "Name" = format("%s%d", var.instance_name_prefix, count.index + 1) }))
  tags                 = merge(var.tags, ({ "Name" = format("%s%d", var.instance_name_prefix, count.index + 1) }))

  metadata_options {
    http_endpoint = var.http_endpoint
    http_tokens   = var.http_tokens
  }

  network_interface {
    network_interface_id = element(aws_network_interface.fw_public_nic[*].id, count.index)
    device_index         = 0
  }

  root_block_device {
    delete_on_termination = var.root_delete_on_termination
    encrypted             = var.encrypted
    volume_type           = var.root_volume_type
    volume_size           = var.root_volume_size
  }
  ebs_block_device {
    device_name = var.ebs_device_name
    volume_type = var.ebs_volume_type
    volume_size = var.ebs_volume_size
    encrypted   = var.ebs_volume_encrypted
  }

  lifecycle {
    ignore_changes = [ami, ebs_block_device]
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
  alarm_name          = format("%s-instance-alarm", element(aws_instance.ec2_instance[*].id, count.index))
  comparison_operator = "GreaterThanOrEqualToThreshold"
  count               = var.number
  datapoints_to_alarm = 2
  dimensions = {
    InstanceId = element(aws_instance.ec2_instance[*].id, count.index)
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
  alarm_name          = format("%s-system-alarm", element(aws_instance.ec2_instance[*].id, count.index))
  comparison_operator = "GreaterThanOrEqualToThreshold"
  count               = var.number
  datapoints_to_alarm = 2
  dimensions = {
    InstanceId = element(aws_instance.ec2_instance[*].id, count.index)
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
