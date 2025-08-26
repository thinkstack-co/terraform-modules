output "dhcp_options_id" {
  value = aws_vpc_dhcp_options.dc_dns[*].id
}
