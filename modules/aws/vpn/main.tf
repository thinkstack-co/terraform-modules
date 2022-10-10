terraform {
  required_version = ">= 1.0.0"
}

##############################
# VPN Gateway
##############################

resource "aws_vpn_gateway" "vpn_gateway" {
  count             = var.enable_transit_gateway_attachment ? 0 : 1
  vpc_id            = var.vpc_id
  availability_zone = var.availability_zone
  tags              = merge(var.tags, ({ "Name" = format("%s_vpn_gw", var.name) }))
  amazon_side_asn   = var.amazon_side_asn
}

##############################
# Customer Gateway
##############################

resource "aws_customer_gateway" "customer_gateway" {
  bgp_asn         = var.bgp_asn
  count           = length(var.ip_address)
  certificate_arn = var.certificate_arn
  ip_address      = var.ip_address[count.index]
  type            = var.vpn_type
  tags            = merge(var.tags, ({ "Name" = format("%s_customer_gw", var.customer_gw_name[count.index]) }))
}

##############################
# VPN Connection
##############################

# Used if enable_transit_gateway_attachment == true
resource "aws_vpn_connection" "vpn_connection_transit_gateway_attachment" {
  count               = var.enable_transit_gateway_attachment ? length(var.ip_address) : 0
  customer_gateway_id = element(aws_customer_gateway.customer_gateway.*.id, count.index)
  static_routes_only  = var.static_routes_only
  tags                = merge(var.tags, ({ "Name" = format("%s_vpn_connection", var.name) }))
  type                = var.vpn_type
  transit_gateway_id  = var.transit_gateway_id

  # Tunnel Settings
  tunnel1_ike_versions = var.tunnel_ike_versions
  tunnel2_ike_versions = var.tunnel_ike_versions
  # Phase 1
  tunnel1_phase1_dh_group_numbers      = var.tunnel_phase1_dh_group_numbers
  tunnel2_phase1_dh_group_numbers      = var.tunnel_phase1_dh_group_numbers
  tunnel1_phase1_encryption_algorithms = var.tunnel_phase1_encryption_algorithms
  tunnel2_phase1_encryption_algorithms = var.tunnel_phase1_encryption_algorithms
  tunnel1_phase1_integrity_algorithms  = var.tunnel_phase1_integrity_algorithms
  tunnel2_phase1_integrity_algorithms  = var.tunnel_phase1_integrity_algorithms
  ## Phase 2
  tunnel1_phase2_dh_group_numbers      = var.tunnel_phase2_dh_group_numbers
  tunnel2_phase2_dh_group_numbers      = var.tunnel_phase2_dh_group_numbers
  tunnel1_phase2_encryption_algorithms = var.tunnel_phase2_encryption_algorithms
  tunnel2_phase2_encryption_algorithms = var.tunnel_phase2_encryption_algorithms
  tunnel1_phase2_integrity_algorithms  = var.tunnel_phase2_integrity_algorithms
  tunnel2_phase2_integrity_algorithms  = var.tunnel_phase2_integrity_algorithms
  ## Tunnel Startup
  tunnel1_startup_action               = var.tunnel_startup_action
  tunnel2_startup_action               = var.tunnel_startup_action
}

# Used if enable_transit_gateway_attachment == false
resource "aws_vpn_connection" "vpn_connection_vpn_gateway_attachment" {
  count               = var.enable_transit_gateway_attachment ? 0 : length(var.ip_address)
  customer_gateway_id = element(aws_customer_gateway.customer_gateway.*.id, count.index)
  static_routes_only  = var.static_routes_only
  tags                = merge(var.tags, ({ "Name" = format("%s_vpn_connection", var.name) }))
  type                = var.vpn_type
  vpn_gateway_id      = aws_vpn_gateway.vpn_gateway[0].id
}
