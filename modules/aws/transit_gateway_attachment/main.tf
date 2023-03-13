terraform {
  required_version = ">= 1.0.0"
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = ">= 4.0.0"
    }
  }
}

resource "aws_ec2_transit_gateway_vpc_attachment" "this" {
  appliance_mode_support                          = var.appliance_mode_support
  dns_support                                     = var.dns_support
  ipv6_support                                    = var.ipv6_support
  subnet_ids                                      = var.subnet_ids
  tags                                            = merge(tomap({ Name = var.name }), var.tags)
  transit_gateway_id                              = var.transit_gateway_id
  transit_gateway_default_route_table_association = var.transit_gateway_default_route_table_association
  transit_gateway_default_route_table_propagation = var.transit_gateway_default_route_table_propagation
  vpc_id                                          = var.vpc_id
}
