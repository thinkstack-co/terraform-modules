resource "aws_ec2_transit_gateway_connect_peer" "peer" {
  bgp_asn                       = var.bgp_asn
  inside_cidr_blocks            = var.inside_cidr_blocks
  peer_address                  = var.peer_address
  tags                          = merge(tomap({Name = var.name}),var.tags)
  transit_gateway_attachment_id = var.transit_gateway_attachment_id
  transit_gateway_address       = var.transit_gateway_address
}
