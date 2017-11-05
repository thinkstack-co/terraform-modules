resource "aws_vpc" "vpc" {
  cidr_block           = "${var.vpc_cidr}"
  instance_tenancy     = "${var.instance_tenancy}"
  enable_dns_hostnames = "${var.enable_dns_hostnames}"
  enable_dns_support   = "${var.enable_dns_support}"
  tags                 = "${merge(var.tags, map("Name", format("%s", var.name)))}"

  lifecycle {
    prevent_destroy   = true
  }
}

resource "aws_subnet" "private_subnets" {
  vpc_id            = "${aws_vpc.vpc.id}"
  cidr_block        = "${var.private_subnets_list[count.index]}"
  availability_zone = "${element(var.azs, count.index)}"
  count             = "${length(var.private_subnets_list)}"
  tags              = "${merge(var.tags, var.private_subnet_tags, map("Name", format("%s_subnet_private_%s", var.name, element(var.azs, count.index))))}"
}

resource "aws_subnet" "public_subnets" {
  vpc_id            = "${aws_vpc.vpc.id}"
  cidr_block        = "${var.public_subnets_list[count.index]}"
  availability_zone = "${element(var.azs, count.index)}"
  map_public_ip_on_launch = "${var.map_public_ip_on_launch}"
  count             = "${length(var.public_subnets_list)}"
  tags              = "${merge(var.tags, var.public_subnet_tags, map("Name", format("%s_subnet_public_%s", var.name, element(var.azs, count.index))))}"
}

resource "aws_internet_gateway" "igw" {
  vpc_id = "${aws_vpc.vpc.id}"
  tags   = "${merge(var.tags, map("Name", format("%s_igw", var.name)))}"
}

resource "aws_route_table" "public_route_table" {
  vpc_id           = "${aws_vpc.vpc.id}"
  propagating_vgws = ["${var.public_propagating_vgws}"]
  tags             = "${merge(var.tags, map("Name", format("%s_rt_public", var.name)))}"
}

resource "aws_route" "public_default_route" {
  route_table_id         = "${aws_route_table.public_route_table.id}"
  destination_cidr_block = "0.0.0.0/0"
  gateway_id             = "${aws_internet_gateway.igw.id}"
}

resource "aws_eip" "nateip" {
  vpc   = true
  count = "${var.enable_nat_gateway ? (var.single_nat_gateway ? 1 : length(var.azs)) : 0}"
}

resource "aws_nat_gateway" "natgw" {
  allocation_id = "${element(aws_eip.nateip.*.id, (var.single_nat_gateway ? 0 : count.index))}"
  subnet_id     = "${element(aws_subnet.public_subnets.*.id, (var.single_nat_gateway ? 0 : count.index))}"
  count         = "${var.enable_nat_gateway ? (var.single_nat_gateway ? 1 : length(var.azs)) : 0}"

  depends_on = ["aws_internet_gateway.igw"]
}

resource "aws_route_table" "private_route_table" {
  vpc_id           = "${aws_vpc.vpc.id}"
  propagating_vgws = ["${var.private_propagating_vgws}"]
  count            = "${length(var.azs)}"
  tags             = "${merge(var.tags, map("Name", format("%s_rt_private_%s", var.name, element(var.azs, count.index))))}"
}

resource "aws_route" "private_default_route" {
  count                   = "${length(var.azs)}"
  route_table_id          = "${element(aws_route_table.private_route_table.*.id, count.index)}"
  destination_cidr_block  = "0.0.0.0/0"
  # nat_gateway_id         = "${element(aws_nat_gateway.natgw.*.id, count.index)}"
  network_interface_id    = "${element(var.fw_network_interface_id, count.index)}"
  # count                   = "${var.enable_nat_gateway ? length(var.azs) : 0}"
}

data "aws_vpc_endpoint_service" "s3" {
  service = "s3"
}

resource "aws_vpc_endpoint" "ep" {
  vpc_id       = "${aws_vpc.vpc.id}"
  service_name = "${data.aws_vpc_endpoint_service.s3.service_name}"
  count        = "${var.enable_s3_endpoint}"
}

resource "aws_vpc_endpoint_route_table_association" "private_s3" {
  count           = "${var.enable_s3_endpoint ? length(var.private_subnets_list) : 0}"
  vpc_endpoint_id = "${aws_vpc_endpoint.ep.id}"
  route_table_id = "${element(aws_route_table.private_route_table.*.id, count.index)}"
}

resource "aws_vpc_endpoint_route_table_association" "public_s3" {
  count           = "${var.enable_s3_endpoint ? length(var.public_subnets_list) : 0}"
  vpc_endpoint_id = "${aws_vpc_endpoint.ep.id}"
  route_table_id  = "${aws_route_table.public_route_table.id}"
}

resource "aws_route_table_association" "private" {
  count          = "${length(var.private_subnets_list)}"
  subnet_id      = "${element(aws_subnet.private_subnets.*.id, count.index)}"
  route_table_id = "${element(aws_route_table.private_route_table.*.id, count.index)}"
}

resource "aws_route_table_association" "public" {
  count          = "${length(var.public_subnets_list)}"
  subnet_id      = "${element(aws_subnet.public_subnets.*.id, count.index)}"
  route_table_id = "${aws_route_table.public_route_table.id}"
}
