output "id" {
  value = aws_ec2_transit_gateway_vpc_attachment.this.id
}

output "vpc_owner_id" {
  value = aws_ec2_transit_gateway_vpc_attachment.this.vpc_owner_id
}
