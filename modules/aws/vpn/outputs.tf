output "vpn_gateway_id" {
  value = aws_vpn_gateway.vpn_gateway[*].id
}

output "customer_gateway_id" {
  value = aws_customer_gateway.customer_gateway[*].id
}

output "customer_gateway_type" {
  value = aws_customer_gateway.customer_gateway[*].type
}

# Expose VPN connection IDs for downstream route modules.
output "vpn_connection_id" {
  value = concat(
    aws_vpn_connection.vpn_connection_transit_gateway_attachment[*].id,
    aws_vpn_connection.vpn_connection_vpn_gateway_attachment[*].id
  )
}
