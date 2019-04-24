resource "aws_vpn_connection_route" "vpn_route" {
  count                   = "${length(var.vpn_connection_id)}"
  destination_cidr_block  = "${var.vpn_route_cidr_block}"
  vpn_connection_id       = "${element(var.vpn_connection_id, count.index)}"
}
