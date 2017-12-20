resource "aws_route" "route" {
  count                       = "${length(var.route_table_id)}"
  destination_cidr_block      = "${var.destination_cidr_block}"
  destination_ipv6_cidr_block = "${var.destination_ipv6_cidr_block}"
  egress_only_gateway_id      = "${var.egress_only_gateway_id}"
  gateway_id                  = "${var.gateway_id}"
  # instance_id                 = "${var.instance_id}"
  nat_gateway_id              = "${var.nat_gateway_id}"
  network_interface_id        = "${element(var.network_interface_id, count.index)}"
  route_table_id              = "${element(var.route_table_id, count.index)}"
  vpc_peering_connection_id   = "${var.vpc_peering_connection_id}"
}
