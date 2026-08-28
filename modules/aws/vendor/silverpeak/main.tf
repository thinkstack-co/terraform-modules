terraform {
  required_version = ">= 1.0.0"
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = ">= 6.10.0, < 7.0.0"
    }
  }
}

#################
# Security Group
#################

# Purpose:       Security group applied to every Silverpeak appliance NIC.
# Referenced by: aws_network_interface.wan0_nic, .lan0_nic, .mgmt0_nic
# References:    var.vpc_id, var.ingress_cidr_blocks, var.egress_cidr_blocks
resource "aws_security_group" "silverpeak_sg" {
  name        = var.sg_name
  description = var.sg_description
  vpc_id      = var.vpc_id

  ingress {
    description = "All traffic"
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    # Silverpeak is a SDWAN device and requires communication from other SDWAN devices
    #tfsec:ignore:aws-ec2-no-public-ingress-sgr
    cidr_blocks = var.ingress_cidr_blocks
  }

  egress {
    description = "All traffic"
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    # Silverpeak is a SDWAN device and requires communication from other SDWAN devices
    #tfsec:ignore:aws-ec2-no-public-egress-sgr
    cidr_blocks = var.egress_cidr_blocks
  }

  tags = merge(var.tags, ({ "Name" = format("%s", var.sg_name) }))
}

#######################
# ENI
#######################

resource "aws_network_interface" "wan0_nic" {
  count             = var.instance_count
  description       = var.wan0_description
  private_ips       = var.wan0_private_ips
  security_groups   = [aws_security_group.silverpeak_sg.id]
  source_dest_check = var.source_dest_check
  subnet_id         = element(var.dmz_subnet_id, count.index)
  tags              = merge(var.tags, ({ "Name" = format("%s%d_wan0", var.name, count.index + 1) }))

  attachment {
    instance     = element(aws_instance.ec2[*].id, count.index)
    device_index = 1
  }
}

resource "aws_network_interface" "lan0_nic" {
  count             = var.instance_count
  description       = var.lan0_description
  private_ips       = var.lan0_private_ips
  security_groups   = [aws_security_group.silverpeak_sg.id]
  source_dest_check = var.source_dest_check
  subnet_id         = element(var.private_subnet_id, count.index)
  tags              = merge(var.tags, ({ "Name" = format("%s%d_lan0", var.name, count.index + 1) }))

  attachment {
    instance     = element(aws_instance.ec2[*].id, count.index)
    device_index = 2
  }
}

resource "aws_network_interface" "mgmt0_nic" {
  count             = var.instance_count
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
# Purpose:       Silverpeak SDWAN appliances; mgmt0 is the primary (device 0) NIC.
# Referenced by: aws_network_interface.wan0_nic, .lan0_nic (attach as devices 1 and 2)
# References:    aws_network_interface.mgmt0_nic, var.ami, var.instance_type
resource "aws_instance" "ec2" {
  ami                                  = var.ami
  availability_zone                    = var.availability_zone
  count                                = var.instance_count
  disable_api_termination              = var.disable_api_termination
  ebs_optimized                        = var.ebs_optimized
  iam_instance_profile                 = var.iam_instance_profile
  instance_initiated_shutdown_behavior = var.instance_initiated_shutdown_behavior
  instance_type                        = var.instance_type
  key_name                             = var.key_name
  monitoring                           = var.monitoring

  metadata_options {
    http_endpoint = var.http_endpoint
    http_tokens   = var.http_tokens
  }

  primary_network_interface {
    network_interface_id = aws_network_interface.mgmt0_nic[count.index].id
  }

  placement_group = var.placement_group

  root_block_device {
    delete_on_termination = var.root_delete_on_termination
    encrypted             = var.encrypted
    volume_type           = var.root_volume_type
    volume_size           = var.root_volume_size
  }

  tags        = merge(var.tags, ({ "Name" = format("%s%d", var.name, count.index + 1) }))
  tenancy     = var.tenancy
  user_data   = var.user_data
  volume_tags = merge(var.tags, ({ "Name" = format("%s%d", var.name, count.index + 1) }))
}
