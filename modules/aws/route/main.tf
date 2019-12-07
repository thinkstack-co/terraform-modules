terraform {
  required_version = ">= 0.12.0"
}

resource "aws_route" "route" {
  count                       = length(var.route_table_id)
  destination_cidr_block      = var.destination_cidr_block
  destination_ipv6_cidr_block = var.destination_ipv6_cidr_block
  egress_only_gateway_id      = var.egress_only_gateway_id
  gateway_id                  = var.gateway_id
  # Causing resources to recompute the id when using a network interface
  # instance_id                 = var.instance_id
  nat_gateway_id              = var.nat_gateway_id
  network_interface_id        = length(var.network_interface_id) > 0 ? element(concat(var.network_interface_id, list("")), count.index) : ""
  route_table_id              = [
    for route_table_id in var.route_table_id:
    route_table_id
  ]
  # route_table_id              = element(var.route_table_id, count.index)
  vpc_peering_connection_id   = var.vpc_peering_connection_id
}
