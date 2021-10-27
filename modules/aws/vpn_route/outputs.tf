output "vpn_connection_route" {
  value = aws_vpn_connection_route.vpn_route[*].destination_cidr_block
}
