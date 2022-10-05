resource "aws_ec2_transit_gateway_connect" "connect_attachment" {
  protocol                                        = var.protocol
  tags                                            = merge(tomap({Name = var.name}),var.tags)
  transit_gateway_default_route_table_association = var.transit_gateway_default_route_table_association
  transit_gateway_default_route_table_propagation = var.transit_gateway_default_route_table_propagation
  transport_attachment_id                         = var.transport_attachment_id
  transit_gateway_id                              = var.transit_gateway_id
}
