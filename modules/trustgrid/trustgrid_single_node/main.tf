terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = ">= 2.7.0"
    }
  }
}

data "aws_ami" "trustgrid-node-ami" {
  owners      = [ "079972220921" ]
  most_recent      = true
  filter {
    name = "name"
    values = ["trustgrid-agent*"]
  }
}

data "aws_region" "current" {}

data "template_cloudinit_config" "cloud_init" {
  gzip          = true
  base64_encode = true

  part {
    content_type = "text/cloud-config"
    filename     = "bootstrap.cfg"
    content      = templatefile("${path.module}/templates/cloud-init.yaml.tpl", 
    { 
      license = var.license, 
      trustgrid_log_group_name = var.trustgrid_log_group_name, 
      trustgrid_log_stream_name = aws_cloudwatch_log_stream.trustgrid_log_stream.name,
      syslog_log_group_name = var.syslog_log_group_name,
      syslog_log_stream_name = aws_cloudwatch_log_stream.syslog_log_stream.name 
      })
  }

  part {
    content_type = "text/x-shellscript"
    filename     = "bootstrap.sh"
    content      = templatefile("${path.module}/scripts/bootstrap.sh.tpl", { region = data.aws_region.current.name})
  }
}

resource "aws_cloudwatch_log_stream" "trustgrid_log_stream" {
  name           = var.name
  log_group_name = var.trustgrid_log_group_name
}

resource "aws_cloudwatch_log_stream" "syslog_log_stream" {
  name           = var.name
  log_group_name = var.syslog_log_group_name
}

data "aws_iam_policy_document" "log_stream_policy" {
  statement {
      actions = ["logs:DescribeLogStreams"]
      resources = ["*"]
  }

  statement {
      actions = ["logs:PutLogEvents"]
      resources = [
        "${aws_cloudwatch_log_stream.trustgrid_log_stream.arn}:*",
        aws_cloudwatch_log_stream.trustgrid_log_stream.arn
      ]
  }

    statement {
      actions = ["logs:PutLogEvents"]
      resources = [
        "${aws_cloudwatch_log_stream.syslog_log_stream.arn}:*",
        aws_cloudwatch_log_stream.syslog_log_stream.arn
      ]
  }
}

resource "aws_iam_role_policy" "node-log-policy" {
    name_prefix = "${var.name}-trustgrid-log-policy"
    policy = data.aws_iam_policy_document.log_stream_policy.json
    role = var.instance_profile_name
    lifecycle {
      ignore_changes = [policy]
    }
}

data "aws_subnet" "mgmt_subnet" {
  id = var.management_subnet_id
}

resource "aws_security_group" "node_mgmt_sg" {
  name_prefix = "${var.name}-mgmt-sg"
  description = "Additional rules for Trustgrid nodes mgmt/wan interface"
  vpc_id      = var.vpc_id
}

resource "aws_security_group_rule" "tcp_8443" {
  count = var.is_tggateway ? 1 : 0
  type              = "ingress"
  from_port         = 8443
  to_port           = 8443
  protocol          = "tcp"
  cidr_blocks       = [ "0.0.0.0/0" ]
  security_group_id = aws_security_group.node_mgmt_sg.id
  description       = "Trustgrid TCP Tunnel"
}

resource "aws_security_group_rule" "udp_8443" {
  count = var.is_tggateway ? 1 : 0
  type              = "ingress"
  from_port         = 8443
  to_port           = 8443
  protocol          = "udp"
  cidr_blocks        = [ "0.0.0.0/0" ]
  security_group_id = aws_security_group.node_mgmt_sg.id
  description       = "Trustgrid UDP Tunnel"
}

resource "aws_security_group_rule" "udp_51820" {
  count = var.is_wggateway ? 1 : 0
  type              = "ingress"
  from_port         = 51820
  to_port           = 51820
  protocol          = "udp"
  cidr_blocks        = [ "0.0.0.0/0" ]
  security_group_id = aws_security_group.node_mgmt_sg.id
  description       = "Wireguard UDP Tunnel"
}

resource "aws_security_group_rule" "tcp_443" {
  count = var.is_appgateway ? 1 : 0
  type              = "ingress"
  from_port         = 443
  to_port           = 443
  protocol          = "tcp"
  cidr_blocks        = [ "0.0.0.0/0" ]
  security_group_id = aws_security_group.node_mgmt_sg.id
  description       = "Trustgrid App Gateway"
}

resource "aws_network_interface" "management_eni" {
  subnet_id         = var.management_subnet_id
  security_groups   = concat ( var.management_security_group_ids, [ aws_security_group.node_mgmt_sg.id ] )
  source_dest_check = false

  tags = {
    Name = "${var.name}-mgmt-nic"
  }
}

resource "aws_network_interface" "data_eni" {
  subnet_id         = var.data_subnet_id
  security_groups   = var.data_security_group_ids
#  private_ips       = [var.data_ip]
  source_dest_check = false

  tags = {
    Name = "${var.name}-data-nic"
  }
}

resource "aws_eip" "mgmt_ip" {
  vpc = true
  network_interface = aws_network_interface.management_eni.id

  tags = {
    Name = "${var.name}-mgmt-ip"
  }
}

resource "aws_instance" "node" {
  ami           = data.aws_ami.trustgrid-node-ami.id
  instance_type = var.instance_type
  key_name = var.key_pair_name

  user_data              = data.template_cloudinit_config.cloud_init.rendered
  iam_instance_profile   = var.instance_profile_name

  network_interface {
    network_interface_id = aws_network_interface.management_eni.id
    device_index = 0
  }

  network_interface {
    network_interface_id = aws_network_interface.data_eni.id
    device_index = 1
  }

  tags = {
    Name = var.name
  }

  root_block_device {
    encrypted = var.root_block_device_encrypt
    volume_size = var.root_block_device_size
  }

  lifecycle {
    ignore_changes = all
  }
}
