terraform {
  required_version = ">= 0.12.0"
}

resource "aws_vpc" "vpc" {
  cidr_block           = var.vpc_cidr
  enable_dns_hostnames = var.enable_dns_hostnames
  enable_dns_support   = var.enable_dns_support
  instance_tenancy     = var.instance_tenancy
  tags                 = merge(var.tags, map("Name", format("%s", var.name)))
}

resource "aws_subnet" "private_subnets" {
  vpc_id            = aws_vpc.vpc.id
  cidr_block        = var.private_subnets_list[count.index]
  availability_zone = element(var.azs, count.index)
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

resource "aws_subnet" "dmz_subnets" {
  vpc_id            = aws_vpc.vpc.id
  cidr_block        = var.dmz_subnets_list[count.index]
  availability_zone = element(var.azs, count.index)
  count             = length(var.dmz_subnets_list)
  tags              = merge(var.tags, map("Name", format("%s-subnet-dmz-%s", var.name, element(var.azs, count.index))))
}

resource "aws_subnet" "db_subnets" {
  vpc_id            = aws_vpc.vpc.id
  cidr_block        = var.db_subnets_list[count.index]
  availability_zone = element(var.azs, count.index)
  count             = length(var.db_subnets_list)
  tags              = merge(var.tags, map("Name", format("%s-subnet-db-%s", var.name, element(var.azs, count.index))))
}

resource "aws_subnet" "mgmt_subnets" {
  vpc_id            = aws_vpc.vpc.id
  cidr_block        = var.mgmt_subnets_list[count.index]
  availability_zone = element(var.azs, count.index)
  count             = length(var.mgmt_subnets_list)
  tags              = merge(var.tags, map("Name", format("%s-subnet-mgmt-%s", var.name, element(var.azs, count.index))))
}

resource "aws_subnet" "workspaces_subnets" {
  vpc_id            = aws_vpc.vpc.id
  cidr_block        = var.workspaces_subnets_list[count.index]
  availability_zone = element(var.azs, count.index)
  count             = length(var.workspaces_subnets_list)
  tags              = merge(var.tags, map("Name", format("%s-subnet-workspaces-%s", var.name, element(var.azs, count.index))))
}

resource "aws_internet_gateway" "igw" {
  tags   = merge(var.tags, map("Name", format("%s-igw", var.name)))
  vpc_id = aws_vpc.vpc.id
}

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

resource "aws_eip" "nateip" {
  count = var.enable_nat_gateway ? (var.single_nat_gateway ? 1 : length(var.azs)) : 0
  vpc   = true
}

resource "aws_nat_gateway" "natgw" {
  depends_on    = [aws_internet_gateway.igw]

  allocation_id = element(aws_eip.nateip.*.id, (var.single_nat_gateway ? 0 : count.index))
  count         = var.enable_nat_gateway ? (var.single_nat_gateway ? 1 : length(var.azs)) : 0
  subnet_id     = element(aws_subnet.public_subnets.*.id, (var.single_nat_gateway ? 0 : count.index))
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

resource "aws_route" "private_default_route_fw" {
  count                  = var.enable_firewall ? length(var.azs) : 0
  destination_cidr_block = "0.0.0.0/0"
  network_interface_id   = element(var.fw_network_interface_id, count.index)
  route_table_id         = element(aws_route_table.private_route_table.*.id, count.index)
}

resource "aws_route_table" "db_route_table" {
  count            = length(var.azs)
  propagating_vgws = var.db_propagating_vgws
  tags             = merge(var.tags, map("Name", format("%s-rt-db-%s", var.name, element(var.azs, count.index))))
  vpc_id           = aws_vpc.vpc.id
}

resource "aws_route" "db_default_route_natgw" {
  count                  = var.enable_firewall ? 0 : length(var.azs)
  destination_cidr_block = "0.0.0.0/0"
  nat_gateway_id         = element(aws_nat_gateway.natgw.*.id, count.index)
  route_table_id         = element(aws_route_table.db_route_table.*.id, count.index)
}

resource "aws_route" "db_default_route_fw" {
  count                  = var.enable_firewall ? length(var.azs) : 0
  destination_cidr_block = "0.0.0.0/0"
  network_interface_id   = element(var.fw_network_interface_id, count.index)
  route_table_id         = element(aws_route_table.db_route_table.*.id, count.index)
}

resource "aws_route_table" "dmz_route_table" {
  count            = length(var.azs)
  propagating_vgws = var.dmz_propagating_vgws
  tags             = merge(var.tags, map("Name", format("%s-rt-dmz-%s", var.name, element(var.azs, count.index))))
  vpc_id           = aws_vpc.vpc.id
}

resource "aws_route" "dmz_default_route_natgw" {
  count                  = var.enable_firewall ? 0 : length(var.azs)
  destination_cidr_block = "0.0.0.0/0"
  nat_gateway_id         = element(aws_nat_gateway.natgw.*.id, count.index)
  route_table_id         = element(aws_route_table.dmz_route_table.*.id, count.index)
}

resource "aws_route" "dmz_default_route_fw" {
  count                  = var.enable_firewall ? length(var.azs) : 0
  destination_cidr_block = "0.0.0.0/0"
  network_interface_id   = element(var.fw_dmz_network_interface_id, count.index)
  route_table_id         = element(aws_route_table.dmz_route_table.*.id, count.index)
}

resource "aws_route_table" "mgmt_route_table" {
  count            = length(var.azs)
  propagating_vgws = var.mgmt_propagating_vgws
  tags             = merge(var.tags, map("Name", format("%s-rt-mgmt-%s", var.name, element(var.azs, count.index))))
  vpc_id           = aws_vpc.vpc.id
}

resource "aws_route" "mgmt_default_route_natgw" {
  count                  = var.enable_firewall ? 0 : length(var.azs)
  destination_cidr_block = "0.0.0.0/0"
  nat_gateway_id         = element(aws_nat_gateway.natgw.*.id, count.index)
  route_table_id         = element(aws_route_table.mgmt_route_table.*.id, count.index)
}

resource "aws_route" "mgmt_default_route_fw" {
  count                  = var.enable_firewall ? length(var.azs) : 0
  destination_cidr_block = "0.0.0.0/0"
  network_interface_id   = element(var.fw_network_interface_id, count.index)
  route_table_id         = element(aws_route_table.mgmt_route_table.*.id, count.index)
}

resource "aws_route_table" "workspaces_route_table" {
  count            = length(var.azs)
  propagating_vgws = var.workspaces_propagating_vgws
  tags             = merge(var.tags, map("Name", format("%s-rt-workspaces-%s", var.name, element(var.azs, count.index))))
  vpc_id           = aws_vpc.vpc.id
}

resource "aws_route" "workspaces_default_route_natgw" {
  count                  = var.enable_firewall ? 0 : length(var.azs)
  destination_cidr_block = "0.0.0.0/0"
  nat_gateway_id         = element(aws_nat_gateway.natgw.*.id, count.index)
  route_table_id         = element(aws_route_table.workspaces_route_table.*.id, count.index)
}

resource "aws_route" "workspaces_default_route_fw" {
  count                  = var.enable_firewall ? length(var.azs) : 0
  destination_cidr_block = "0.0.0.0/0"
  network_interface_id   = element(var.fw_network_interface_id, count.index)
  route_table_id         = element(aws_route_table.workspaces_route_table.*.id, count.index)
}

data "aws_vpc_endpoint_service" "s3" {
  service = "s3"
}

resource "aws_vpc_endpoint" "ep" {
  count        = var.enable_s3_endpoint ? 1 : 0
  vpc_id       = aws_vpc.vpc.id
  service_name = data.aws_vpc_endpoint_service.s3.service_name
}

resource "aws_vpc_endpoint_route_table_association" "private_s3" {
  count           = var.enable_s3_endpoint ? length(var.private_subnets_list) : 0
  vpc_endpoint_id = aws_vpc_endpoint.ep[count.index]
  route_table_id  = element(aws_route_table.private_route_table.*.id, count.index)
}

resource "aws_vpc_endpoint_route_table_association" "public_s3" {
  count           = var.enable_s3_endpoint ? length(var.public_subnets_list) : 0
  vpc_endpoint_id = aws_vpc_endpoint.ep[count.index]
  route_table_id  = aws_route_table.public_route_table.id
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

resource "aws_route_table_association" "db" {
  count          = length(var.db_subnets_list)
  route_table_id = element(aws_route_table.db_route_table.*.id, count.index)
  subnet_id      = element(aws_subnet.db_subnets.*.id, count.index)
}

resource "aws_route_table_association" "dmz" {
  count          = length(var.dmz_subnets_list)
  route_table_id = element(aws_route_table.dmz_route_table.*.id, count.index)
  subnet_id      = element(aws_subnet.dmz_subnets.*.id, count.index)
}

resource "aws_route_table_association" "workspaces" {
  count          = length(var.workspaces_subnets_list)
  route_table_id = element(aws_route_table.workspaces_route_table.*.id, count.index)
  subnet_id      = element(aws_subnet.workspaces_subnets.*.id, count.index)
}
