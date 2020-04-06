output "vpn_gateway_id" {
    value = aws_vpn_gateway.vpn_gateway[*].id
}

output "customer_gateway_id" {
    value = aws_customer_gateway.customer_gateway[*].id
}

output "customer_gateway_bgp_asn" {
    value = aws_customer_gateway.customer_gateway[*].bgp_asn
}

output "customer_gateway_ip_address" {
    value = aws_customer_gateway.customer_gateway[*].ip_address
}

output "customer_gateway_type" {
    value = aws_customer_gateway.customer_gateway[*].type
}

output "vpn_connection_id" {
    value = aws_vpn_connection.vpn_connection[*].id
}

output "vpn_connection_tunnel1_address" {
    value = aws_vpn_connection.vpn_connection[*].tunnel1_address
}

output "vpn_connection_tunnel2_address" {
    value = aws_vpn_connection.vpn_connection[*].tunnel2_address
}

