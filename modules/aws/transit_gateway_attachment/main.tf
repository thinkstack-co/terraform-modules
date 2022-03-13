resource "aws_ec2_transit_gateway_vpc_attachment" "this" {
  appliance_mode_support = var.appliance_mode_support
  dns_support            = var.dns_support
  ipv6_support           = var.ipv6_support
  subnet_ids             = var.subnet_ids
  tags                   = merge(tomap({Name = var.name}),var.tags)
  transit_gateway_id     = var.transit_gateway_id
  vpc_id                 = var.vpc_id
}