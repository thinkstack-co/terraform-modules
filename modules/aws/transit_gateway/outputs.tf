output "arn" {
  value = aws_ec2_transit_gateway.transit_gateway.arn
}

output "association_default_route_table_id" {
  value = aws_ec2_transit_gateway.transit_gateway.association_default_route_table_id
}

output "id" {
  value = aws_ec2_transit_gateway.transit_gateway.id
}

output "propagation_default_route_table_id" {
  value = aws_ec2_transit_gateway.transit_gateway.propagation_default_route_table_id
}
