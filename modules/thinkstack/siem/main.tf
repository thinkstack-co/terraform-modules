terraform {
  required_version = ">= 0.12.0"
}

###########################
# VPC
###########################

resource "aws_vpc" "vpc" {
  cidr_block           = var.vpc_cidr
  enable_dns_hostnames = var.enable_dns_hostnames
  enable_dns_support   = var.enable_dns_support
  instance_tenancy     = var.instance_tenancy
  tags                 = merge(var.tags, map("Name", format("%s", var.name)))
}

###########################
# VPC - Subnets
###########################

resource "aws_subnet" "private_subnets" {
  vpc_id            = aws_vpc.vpc.id
  cidr_block        = var.private_subnets_list[count.index]
  availability_zone = element(list(format("%sa", var.region), format("%sb", var.region), format("%sc", var.region)), count.index)
  count             = length(var.private_subnets_list)
  tags              = merge(var.tags, map("Name", format("%s-subnet-private-%s", var.name, element(var.azs, count.index))))
}

resource "aws_subnet" "public_subnets" {
  vpc_id                  = aws_vpc.vpc.id
  cidr_block              = var.public_subnets_list[count.index]
  availability_zone       = element(var.azs, count.index)
  map_public_ip_on_launch = var.map_public_ip_on_launch
  count                   = length(var.public_subnets_list)
  tags                    = merge(var.tags, map("Name", format("%s-subnet-public-%s", var.name, element(var.azs, count.index))))
}

###########################
# VPC - Gateways
###########################

resource "aws_eip" "nateip" {
  count = var.enable_nat_gateway ? (var.single_nat_gateway ? 1 : length(var.azs)) : 0
  vpc   = true
}

resource "aws_internet_gateway" "igw" {
  tags   = merge(var.tags, map("Name", format("%s-igw", var.name)))
  vpc_id = aws_vpc.vpc.id
}

resource "aws_nat_gateway" "natgw" {
  depends_on    = [aws_internet_gateway.igw]

  allocation_id = element(aws_eip.nateip.*.id, (var.single_nat_gateway ? 0 : count.index))
  count         = var.enable_nat_gateway ? (var.single_nat_gateway ? 1 : length(var.azs)) : 0
  subnet_id     = element(aws_subnet.public_subnets.*.id, (var.single_nat_gateway ? 0 : count.index))
}

###########################
# VPC - Routes
###########################

resource "aws_route_table" "public_route_table" {
  propagating_vgws = var.public_propagating_vgws
  tags             = merge(var.tags, map("Name", format("%s-rt-public", var.name)))
  vpc_id           = aws_vpc.vpc.id
}

resource "aws_route" "public_default_route" {
  destination_cidr_block = "0.0.0.0/0"
  gateway_id             = aws_internet_gateway.igw.id
  route_table_id         = aws_route_table.public_route_table.id
}

resource "aws_route_table" "private_route_table" {
  count            = length(var.azs)
  propagating_vgws = var.private_propagating_vgws
  tags             = merge(var.tags, map("Name", format("%s-rt-private-%s", var.name, element(var.azs, count.index))))
  vpc_id           = aws_vpc.vpc.id
}

resource "aws_route" "private_default_route_natgw" {
  count                  = var.enable_firewall ? 0 : length(var.azs)
  destination_cidr_block = "0.0.0.0/0"
  nat_gateway_id         = element(aws_nat_gateway.natgw.*.id, count.index)
  route_table_id         = element(aws_route_table.private_route_table.*.id, count.index)
}

resource "aws_route_table_association" "private" {
  count          = length(var.private_subnets_list)
  route_table_id = element(aws_route_table.private_route_table.*.id, count.index)
  subnet_id      = element(aws_subnet.private_subnets.*.id, count.index)
}

resource "aws_route_table_association" "public" {
  count          = length(var.public_subnets_list)
  route_table_id = aws_route_table.public_route_table.id
  subnet_id      = element(aws_subnet.public_subnets.*.id, count.index)
}

###########################
# VPC - Peering
###########################

resource "aws_vpc_peering_connection" "peer" {
  count         = var.enable_vpc_peering
  auto_accept   = var.auto_accept
  peer_owner_id = var.peer_owner_id
  peer_region   = var.peer_region
  peer_vpc_id   = var.peer_vpc_id
  tags          = var.tags
  vpc_id        = aws_vpc.vpc.id

  accepter {
    allow_remote_vpc_dns_resolution = var.allow_remote_vpc_dns_resolution
  }

  requester {
    allow_remote_vpc_dns_resolution = var.allow_remote_vpc_dns_resolution
  }
}


###########################
# VPC - VPN
###########################

resource "aws_vpn_gateway" "vpn_gateway" {
  vpc_id            = aws_vpc.vpc.id
  tags              = merge(var.tags, map("Name", format("%s_vpn_gw", var.name)))
}

resource "aws_customer_gateway" "customer_gateway" {
  bgp_asn          = var.bgp_asn
  count            = length(var.vpn_peer_ip_address)
  ip_address       = var.vpn_peer_ip_address[count.index]
  type             = var.vpn_type
  tags             = merge(var.tags, map("Name", format("%s_customer_gw", var.customer_gw_name[count.index])))
}

resource "aws_vpn_connection" "vpn_connection" {
  count                 = length(var.vpn_peer_ip_address)
  customer_gateway_id   = element(aws_customer_gateway.customer_gateway.*.id, count.index)
  static_routes_only    = var.static_routes_only
  tags                  = merge(var.tags, map("Name", format("%s_vpn_connection", var.name)))
  type                  = var.vpn_type
  vpn_gateway_id        = aws_vpn_gateway.vpn_gateway.id
}

resource "aws_vpn_connection_route" "vpn_route" {
  count                  = length(var.vpn_route_cidr_blocks)
  destination_cidr_block = var.vpn_route_cidr_blocks[count.index]
  vpn_connection_id      = aws_vpn_connection.vpn_connection[count.index]
}

###########################
# EC2 - Keypair
###########################

resource "aws_key_pair" "deployer_key" {
    key_name_prefix =   var.key_name_prefix
    public_key      =   var.public_key
}

###########################
# EC2 - Instance
###########################

resource "aws_instance" "ec2" {
  ami                                  = var.ami
  associate_public_ip_address          = var.associate_public_ip_address
  availability_zone                    = element(aws_subnet.private_subnets.*.availability_zone, count.index)
  count                                = var.instance_count
  disable_api_termination              = var.disable_api_termination
  ebs_optimized                        = var.ebs_optimized
  iam_instance_profile                 = var.iam_instance_profile
  instance_initiated_shutdown_behavior = var.instance_initiated_shutdown_behavior
  instance_type                        = var.instance_type
  ipv6_address_count                   = var.ipv6_address_count
  ipv6_addresses                       = var.ipv6_addresses
  key_name                             = aws_key_pair.deployer_key.id
  monitoring                           = var.monitoring
  placement_group                      = var.placement_group
  private_ip                           = var.private_ip
  root_block_device                    = {
    delete_on_termination = var.root_delete_on_termination
    volume_type           = var.root_volume_type
    volume_size           = var.root_volume_size
  }
  source_dest_check      = var.source_dest_check
  subnet_id              = aws_subnet.private_subnets[count.index]
  tags                   = merge(var.tags, map("Name", format("%s%d", var.name, count.index + 1)))
  tenancy                = var.tenancy
  user_data              = var.user_data
  volume_tags            = merge(var.tags, map("Name", format("%s%d", var.name, count.index + 1)))
  vpc_security_group_ids = [aws_security_group.sg.id]
}

###################################################
# EC2 - CloudWatch Alarms
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
  count                     = length(aws_instance.ec2.id)
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
  count                     = length(aws_instance.ec2.id)
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
}

###########################
# EC2 - Security Group
###########################

resource "aws_security_group" "sg" {
    description = var.security_group_description
    name        = var.security_group_name
    tags        = merge(var.tags, map("Name", format("%s", var.security_group_name)))
    vpc_id      = aws_vpc.vpc.id
}

###########################
# EC2 - Security Group Rules
###########################

resource "aws_security_group_rule" "allow_all_outbound" {
    type                = "egress"
    from_port           = 0
    to_port             = 0
    protocol            = "-1"
    cidr_blocks         = ["0.0.0.0/0"]

    security_group_id   = aws_security_group.sg.id
}

resource "aws_security_group_rule" "allow_icmp_inbound" {
    type                = "ingress"
    from_port           = -1
    to_port             = -1
    protocol            = "icmp"
    cidr_blocks         = var.sg_cidr_blocks

    security_group_id   = aws_security_group.sg.id
}

resource "aws_security_group_rule" "tcp_22_inbound" {
    type                = "ingress"
    from_port           = 22
    to_port             = 22
    protocol            = "tcp"
    cidr_blocks         = var.sg_cidr_blocks

    security_group_id   = aws_security_group.sg.id
}

resource "aws_security_group_rule" "udp_161_inbound" {
    type                = "ingress"
    from_port           = 161
    to_port             = 161
    protocol            = "udp"
    cidr_blocks         = var.sg_cidr_blocks

    security_group_id   = aws_security_group.sg.id
}

resource "aws_security_group_rule" "udp_162_inbound" {
    type                = "ingress"
    from_port           = 162
    to_port             = 162
    protocol            = "udp"
    cidr_blocks         = var.sg_cidr_blocks

    security_group_id   = aws_security_group.sg.id
}

resource "aws_security_group_rule" "tcp_135_inbound" {
    type                = "ingress"
    from_port           = 135
    to_port             = 135
    protocol            = "tcp"
    cidr_blocks         = var.sg_cidr_blocks

    security_group_id   = aws_security_group.sg.id
}

resource "aws_security_group_rule" "tcp_443_inbound" {
    type                = "ingress"
    from_port           = 443
    to_port             = 443
    protocol            = "tcp"
    cidr_blocks         = var.sg_cidr_blocks

    security_group_id   = aws_security_group.sg.id
}

resource "aws_security_group_rule" "udp_514_inbound" {
    type                = "ingress"
    from_port           = 514
    to_port             = 514
    protocol            = "udp"
    cidr_blocks         = var.sg_cidr_blocks

    security_group_id   = aws_security_group.sg.id
}

resource "aws_security_group_rule" "udp_5480_inbound" {
    type                = "ingress"
    from_port           = 5480
    to_port             = 5480
    protocol            = "udp"
    cidr_blocks         = var.sg_cidr_blocks

    security_group_id   = aws_security_group.sg.id
}

resource "aws_security_group_rule" "tcp_5480_inbound" {
    type                = "ingress"
    from_port           = 5480
    to_port             = 5480
    protocol            = "tcp"
    cidr_blocks         = var.sg_cidr_blocks

    security_group_id   = aws_security_group.sg.id
}

