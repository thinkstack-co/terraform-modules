terraform {
  required_version = ">= 0.12.0"
}

#######################
# Security Group
#######################

resource "aws_security_group" "corelight_sg" {
  name        = var.sg_name
  description = var.sg_description
  vpc_id      = var.vpc_id

  ingress {
      from_port   = 4789
      to_port     = 4789
      protocol    = "udp"
      cidr_blocks = var.vxlan_cidr_blocks
  }

  ingress {
      from_port   = 22
      to_port     = 22
      protocol    = "tcp"
      cidr_blocks = var.mgmt_cidr_blocks
  }

  ingress {
      from_port   = 443
      to_port     = 443
      protocol    = "tcp"
      cidr_blocks = var.mgmt_cidr_blocks
  }

  egress {
    from_port       = 0
    to_port         = 0
    protocol        = "-1"
    cidr_blocks     = ["0.0.0.0/0"]
  }

  tags            = merge(var.tags, map("Name", format("%s", var.sg_name)))
}

#######################
# ENI
#######################

resource "aws_network_interface" "listener_nic" {
    count               = var.number
    description         = var.listener_nic_description
    private_ips         = var.listener_nic_private_ips
    security_groups     = [aws_security_group.corelight_sg.id]
    source_dest_check   = var.source_dest_check
    subnet_id           = element(var.subnet_id, count.index)
    tags                = merge(var.tags, map("Name", format("%s%d_listener", var.name, count.index + 1)))

    attachment {
        instance        = element(aws_instance.ec2.*.id, count.index)
        device_index    = 1
    }
}

resource "aws_network_interface" "mgmt_nic" {
    count               = var.number
    description         = var.mgmt_description
    private_ips         = var.mgmt_private_ips
    security_groups     = [aws_security_group.corelight_sg.id]
    source_dest_check   = var.source_dest_check
    subnet_id           = element(var.mgmt_subnet_id, count.index)
    tags                = merge(var.tags, map("Name", format("%s%d_mgmt", var.name, count.index + 1)))
}

#######################
# EC2 instance Module
#######################
resource "aws_instance" "ec2" {
  ami                                  = var.ami
  associate_public_ip_address          = var.associate_public_ip_address
  availability_zone                    = var.availability_zone
  count                                = var.number
  disable_api_termination              = var.disable_api_termination
  ebs_optimized                        = var.ebs_optimized
  iam_instance_profile                 = var.iam_instance_profile
  instance_initiated_shutdown_behavior = var.instance_initiated_shutdown_behavior
  instance_type                        = var.instance_type
  key_name                             = var.key_name
  monitoring                           = var.monitoring
  placement_group                      = var.placement_group

  network_interface {
        network_interface_id = aws_network_interface.mgmt_nic.id
        device_index         = 0
    }
  
  root_block_device {
    delete_on_termination = var.root_delete_on_termination
    encrypted             = var.encrypted
    volume_type           = var.root_volume_type
    volume_size           = var.root_volume_size
  }

  source_dest_check      = var.source_dest_check
  tags                   = merge(var.tags, map("Name", format("%s%d", var.name, count.index + 1)))
  tenancy                = var.tenancy
  user_data              = var.user_data
  volume_tags            = merge(var.tags, map("Name", format("%s%d", var.name, count.index + 1)))

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
  alarm_name                = format("%s-instance-alarm", aws_instance.ec2[count.index].id)
  comparison_operator       = "GreaterThanOrEqualToThreshold"
  count                     = var.number
  datapoints_to_alarm       = 2
  dimensions                = {
    InstanceId = aws_instance.ec2[count.index].id
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
  alarm_name                = format("%s-system-alarm", aws_instance.ec2[count.index].id)
  comparison_operator       = "GreaterThanOrEqualToThreshold"
  count                     = var.number
  datapoints_to_alarm       = 2
  dimensions                = {
    InstanceId = aws_instance.ec2[count.index].id
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
