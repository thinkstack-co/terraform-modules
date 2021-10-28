terraform {
  required_version = ">= 0.12.0"
}

resource "aws_route" "route" {
  #carrier_gateway_id          = var.carrier_gateway_id
  count                       = length(flatten(var.route_table_id))
  destination_cidr_block      = var.destination_cidr_block
  destination_ipv6_cidr_block = var.destination_ipv6_cidr_block
  egress_only_gateway_id      = var.egress_only_gateway_id
  gateway_id                  = var.gateway_id
  instance_id                 = var.instance_id
  local_gateway_id            = var.local_gateway_id
  nat_gateway_id              = var.nat_gateway_id
  #network_interface_id        = var.network_interface_id
  # This was utilized to select the item in the variable
  #network_interface_id        = length(var.network_interface_id) > 0 ? element(concat(var.network_interface_id, list("")), count.index) : ""
  transit_gateway_id          = var.transit_gateway_id
  route_table_id              = element(flatten(var.route_table_id), count.index)
  vpc_endpoint_id             = var.vpc_endpoint_id
  vpc_peering_connection_id   = var.vpc_peering_connection_id
}
