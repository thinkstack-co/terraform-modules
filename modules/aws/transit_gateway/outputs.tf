output "transit_gateway_arn" {
    value = aws_transit_gateway.transit_gateway.arn
}

output "transit_gateway_route_table_id" {
    value = aws_ec2_transit_gateway.transit_gateway.association_default_route_table_id
}

output "transit_gateway_id" {
    value = aws_ec2_transit_gateway.transit_gateway.id
}

output "transit_gateway_propagation_default_route_table_id" {
    value = aws_ec2_transit_gateway.transit_gateway.propagation_default_route_table_id
}
