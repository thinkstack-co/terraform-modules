terraform {
  required_version = ">= 1.0.0"
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = ">= 4.0.0"
    }
  }
}

resource "aws_route" "route" {
  count                       = length(flatten(var.route_table_id))
  destination_cidr_block      = var.destination_cidr_block
  destination_ipv6_cidr_block = var.destination_ipv6_cidr_block
  transit_gateway_id          = var.transit_gateway_id
  route_table_id              = element(flatten(var.route_table_id), count.index)
}
