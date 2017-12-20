resource "aws_route" "route" {
  count                       = "${length(var.route_table_id)}"
  destination_cidr_block      = "${var.destination_cidr_block}"
  destination_ipv6_cidr_block = "${var.destination_ipv6_cidr_block}"
  egress_only_gateway_id      = "${element(var.egress_only_gateway_id), count.index}"
  gateway_id                  = "${element(var.gateway_id), count.index}"
  instance_id                 = "${element(var.instance_id), count.index}"
  nat_gateway_id              = "${element(var.nat_gateway_id), count.index}"
  network_interface_id        = "${element(var.network_interface_id), count.index}"
  route_table_id              = "${element(var.route_table_id), count.index}"
  vpc_peering_connection_id   = "${var.vpc_peering_connection_id}"
}
