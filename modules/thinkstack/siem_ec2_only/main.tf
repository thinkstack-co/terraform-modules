
###########################
# EC2 - Instance
###########################

data "aws_region" "current" {}

resource "aws_instance" "ec2" {
  ami                                  = var.ami
  associate_public_ip_address          = var.associate_public_ip_address
  availability_zone                    = var.availability_zone
  count                                = var.instance_count
  disable_api_termination              = var.disable_api_termination
  ebs_optimized                        = var.ebs_optimized
  iam_instance_profile                 = var.iam_instance_profile
  instance_initiated_shutdown_behavior = var.instance_initiated_shutdown_behavior
  instance_type                        = var.instance_type
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
    volume_type           = var.root_volume_type
    volume_size           = var.root_volume_size
  }
  source_dest_check      = var.source_dest_check
  subnet_id              = var.subnet_id
  tags                   = merge(var.tags, ({ "Name" = format("%s%d", var.name, count.index + 1) }))
  tenancy                = var.instance_tenancy
  user_data              = var.user_data #file("${path.module}/snypr_centos_script.sh")
  volume_tags            = merge(var.tags, ({ "Name" = format("%s%d", var.name, count.index + 1) }))
  vpc_security_group_ids = concat([aws_security_group.sg.id], [var.additional_sg_id])

  lifecycle {
    ignore_changes = [user_data]
  }
}

######################
# EBS Volume for logs
######################

# resource "aws_ebs_volume" "log_volume" {
#   availability_zone = var.availability_zone
#   count             = var.instance_count
#   encrypted         = var.encrypted
#   size              = var.log_volume_size
#   type              = var.log_volume_type
#   tags              = merge(var.tags, ({ "Name" = format("%s%d", var.name, count.index + 1) }))
# }

# resource "aws_volume_attachment" "log_volume_attachment" {
#   count       = var.instance_count
#   device_name = var.log_volume_device_name
#   instance_id = aws_instance.ec2[count.index].id
#   volume_id   = aws_ebs_volume.log_volume[count.index].id
# }

###################################################
# EC2 - CloudWatch Alarms
###################################################

#####################
# Status Check Failed Instance Metric
#####################

resource "aws_cloudwatch_metric_alarm" "instance" {
  actions_enabled     = true
  alarm_actions       = []
  alarm_description   = "EC2 instance StatusCheckFailed_Instance alarm"
  alarm_name          = format("%s-instance-alarm", aws_instance.ec2[count.index].id)
  comparison_operator = "GreaterThanOrEqualToThreshold"
  count               = var.instance_count
  datapoints_to_alarm = 2
  dimensions = {
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
}

#####################
# Status Check Failed System Metric
#####################

resource "aws_cloudwatch_metric_alarm" "system" {
  actions_enabled     = true
  alarm_actions       = ["arn:aws:automate:${data.aws_region.current.name}:ec2:recover"]
  alarm_description   = "EC2 instance StatusCheckFailed_System alarm"
  alarm_name          = format("%s-system-alarm", aws_instance.ec2[count.index].id)
  comparison_operator = "GreaterThanOrEqualToThreshold"
  count               = var.instance_count
  datapoints_to_alarm = 2
  dimensions = {
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
}

###########################
# EC2 - Security Group
###########################

  /* 
########################################
# Port Mappings
########################################
Port            | Description
----------------------------------------
icmp            - ICMP/Ping
162 udp         - SNMP Trap Ingester Port
13001-13020 tcp - RIN Syslog Ingester Ports
30149 udp       - Windows DHCP Ingestion
30181 tcp       - Windows DNS Ingestion
30216 udp       - MS Sysmon Ingestion
30261 udp       - Fortinet Syslog
30463 tcp       - Windows Events Ingestion
30465 tcp       - Powershell Ingestion TCP
30514 udp       - Syslog Ingestion
5985-5986 tcp   - WinRM-HTTPS
 */

resource "aws_security_group" "sg" {
  description = var.security_group_description
  name        = var.security_group_name
  tags        = merge(var.tags, ({ "Name" = format("%s", var.security_group_name) }))
  vpc_id      = var.vpc_id

  ingress {
    from_port   = -1
    to_port     = -1
    protocol    = "icmp"
    cidr_blocks = var.sg_cidr_blocks
    description = "Allow ICMP"
  }

  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = var.mgmt_cidr_blocks
    description = "Allow SSH"
  }

  ingress {
    from_port   = 162
    to_port     = 162
    protocol    = "udp"
    cidr_blocks = var.sg_cidr_blocks
    description = "SNMP Trap Ingester Port"
  }


  ingress {
    from_port   = 13001
    to_port     = 13020
    protocol    = "tcp"
    cidr_blocks = var.sg_cidr_blocks
    description = "RIN Syslog Ingester Ports"
  }

  ingress {
    from_port   = 30149
    to_port     = 30149
    protocol    = "udp"
    cidr_blocks = var.sg_cidr_blocks
    description = "Windows DHCP Ingestion"
  }

  ingress {
    from_port   = 30181
    to_port     = 30181
    protocol    = "tcp"
    cidr_blocks = var.sg_cidr_blocks
    description = "Windows DNS Ingestion"
  }

  ingress {
    from_port   = 30216
    to_port     = 30216
    protocol    = "udp"
    cidr_blocks = var.sg_cidr_blocks
    description = "MS Sysmon Ingestion"
  }

  ingress {
    from_port   = 30261
    to_port     = 30261
    protocol    = "udp"
    cidr_blocks = var.sg_cidr_blocks
    description = "Fortinet Syslog"
  }

  ingress {
    from_port   = 30463
    to_port     = 30463
    protocol    = "tcp"
    cidr_blocks = var.sg_cidr_blocks
    description = "Windows Events Ingestion"
  }

  ingress {
    from_port   = 30465
    to_port     = 30465
    protocol    = "tcp"
    cidr_blocks = var.sg_cidr_blocks
    description = "Powershell Ingestion TCP"
  }

  ingress {
    from_port   = 30514
    to_port     = 30514
    protocol    = "udp"
    cidr_blocks = var.sg_cidr_blocks
    description = "Syslog Ingestion"
  }

  ingress {
    from_port   = 5985
    to_port     = 5986
    protocol    = "tcp"
    cidr_blocks = var.sg_cidr_blocks
    description = "WinRM-HTTPS"
  }

  egress {
    description = "Allow all outbound traffic"
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    #tfsec:ignore:aws-ec2-no-public-egress-sgr
    cidr_blocks = ["0.0.0.0/0"]
  }
}
