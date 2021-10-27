terraform {
  required_version = ">= 0.12.0"
}

resource "aws_vpn_gateway" "vpn_gateway" {
  vpc_id = var.vpc_id
  # availability_zone = var.availability_zone
  tags = merge(var.tags, ({ "Name" = format("%s_vpn_gw", var.name) }))
}

resource "aws_customer_gateway" "customer_gateway" {
  bgp_asn    = var.bgp_asn
  count      = length(var.ip_address)
  ip_address = var.ip_address[count.index]
  type       = var.vpn_type
  tags       = merge(var.tags, ({ "Name" = format("%s_customer_gw", var.customer_gw_name[count.index]) }))
}

resource "aws_vpn_connection" "vpn_connection" {
  count               = length(var.ip_address)
  customer_gateway_id = element(aws_customer_gateway.customer_gateway.*.id, count.index)
  static_routes_only  = var.static_routes_only
  tags                = merge(var.tags, ({ "Name" = format("%s_vpn_connection", var.name) }))
  type                = var.vpn_type
  vpn_gateway_id      = aws_vpn_gateway.vpn_gateway.id
}
