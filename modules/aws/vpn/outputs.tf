output "vpn_gateway_id" {
  value = aws_vpn_gateway.vpn_gateway[*].id
}

output "customer_gateway_id" {
  value = aws_customer_gateway.customer_gateway[*].id
}

output "customer_gateway_type" {
  value = aws_customer_gateway.customer_gateway[*].type
}
