output "transit_gateway_attachment_id" {
    value = aws_ec2_transit_gateway_vpc_attachment.transit_gateway_vpc_attachment.id
}

output "transit_gateway_attachment_vpc_owner_id" {
    value = aws_ec2_transit_gateway_vpc_attachment.transit_gateway_vpc_attachment.vpc_owner_id
}
