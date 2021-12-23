terraform {
  required_version = ">= 0.12.0"
}

#################
# Security Group
#################

resource "aws_security_group" "silverpeak_sg" {
  name        = var.sg_name
  description = var.sg_description
  vpc_id      = var.vpc_id

  ingress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = merge(var.tags, ({ "Name" = format("%s", var.sg_name) }))
}

#######################
# ENI
#######################

resource "aws_network_interface" "wan0_nic" {
  count             = var.count
  description       = var.wan0_description
  private_ips       = var.wan0_private_ips
  security_groups   = [aws_security_group.silverpeak_sg.id]
  source_dest_check = var.source_dest_check
  subnet_id         = element(var.dmz_subnet_id, count.index)
  tags              = merge(var.tags, ({ "Name" = format("%s%d_wan0", var.name, count.index + 1) }))

  attachment {
    instance     = element(aws_instance.ec2.*.id, count.index)
    device_index = 1
  }
}

resource "aws_network_interface" "lan0_nic" {
  count             = var.count
  description       = var.lan0_description
  private_ips       = var.lan0_private_ips
  security_groups   = [aws_security_group.silverpeak_sg.id]
  source_dest_check = var.source_dest_check
  subnet_id         = element(var.private_subnet_id, count.index)
  tags              = merge(var.tags, ({ "Name" = format("%s%d_lan0", var.name, count.index + 1) }))

  attachment {
    instance     = element(aws_instance.ec2.*.id, count.index)
    device_index = 2
  }
}

resource "aws_network_interface" "mgmt0_nic" {
  count             = var.count
  description       = var.mgmt0_description
  private_ips       = var.mgmt0_private_ips
  security_groups   = [aws_security_group.silverpeak_sg.id]
  source_dest_check = var.source_dest_check
  subnet_id         = element(var.mgmt_subnet_id, count.index)
  tags              = merge(var.tags, ({ "Name" = format("%s%d_mgmt0", var.name, count.index + 1) }))
}

#######################
# EC2 instance Module
#######################
resource "aws_instance" "ec2" {
  ami                                  = var.ami
  availability_zone                    = var.availability_zone
  count                                = var.count
  disable_api_termination              = var.disable_api_termination
  ebs_optimized                        = var.ebs_optimized
  ephemeral_block_device               = var.ephemeral_block_device
  iam_instance_profile                 = var.iam_instance_profile
  instance_initiated_shutdown_behavior = var.instance_initiated_shutdown_behavior
  instance_type                        = var.instance_type
  key_name                             = var.key_name
  monitoring                           = var.monitoring

  network_interface {
    network_interface_id = aws_network_interface.mgmt0_nic.id
    device_index         = 0
  }

  placement_group = var.placement_group

  root_block_device = {
    delete_on_termination = var.root_delete_on_termination
    volume_type           = var.root_volume_type
    volume_size           = var.root_volume_size
  }

  tags        = merge(var.tags, ({ "Name" = format("%s%d", var.name, count.index + 1) }))
  tenancy     = var.tenancy
  user_data   = var.user_data
  volume_tags = merge(var.tags, ({ "Name" = format("%s%d", var.name, count.index + 1) }))
}
