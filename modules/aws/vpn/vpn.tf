resource "aws_vpn_gateway" "vpn_gateway" {
  vpc_id            = "${var.vpc_id}"
  # availability_zone = "${var.availability_zone}"
  tags              = "${merge(var.tags, map("Name", format("%s_vpn_gateway", var.name)))}"
}

resource "aws_customer_gateway" "customer_gateway" {
  bgp_asn       = "${var.bgp_asn}"
  ip_address    = "${var.ip_address}"
  type          = "${var.vpn_type}"
  tags          = "${merge(var.tags, map("Name", format("%s_customer_gateway", var.name)))}"
}

resource "aws_vpn_connection" "vpn_connection" {
  customer_gateway_id   = "${aws_customer_gateway.customer_gateway.id}"
  static_routes_only    = "${var.static_routes_only}"
  tags                  = "${merge(var.tags, map("Name", format("%s", var.name)))}"
  type                  = "${var.vpn_type}"
  vpn_gateway_id        = "${aws_vpn_gateway.vpn_gateway.id}"
}
