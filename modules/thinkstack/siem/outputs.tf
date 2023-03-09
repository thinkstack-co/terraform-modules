output "private_subnet_ids" {
  value = [aws_subnet.private_subnets[*].id]
}

output "public_subnet_ids" {
  value = [aws_subnet.public_subnets[*].id]
}

output "private_subnets" {
  value = [aws_subnet.private_subnets[*].cidr_block]
}

output "public_subnets" {
  value = [aws_subnet.public_subnets[*].cidr_block]
}

output "vpc_id" {
  value = aws_vpc.vpc.id
}

output "vpc_cidr_block" {
  value = aws_vpc.vpc.cidr_block
}

output "public_route_table_ids" {
  value = [aws_route_table.public_route_table[*].id]
}

output "private_route_table_ids" {
  value = [aws_route_table.private_route_table[*].id]
}

output "default_security_group_id" {
  value = aws_vpc.vpc.default_security_group_id
}

output "nat_eips" {
  value = [aws_eip.nateip[*].id]
}

output "nat_eips_public_ips" {
  value = [aws_eip.nateip[*].public_ip]
}

output "natgw_ids" {
  value = [aws_nat_gateway.natgw[*].id]
}

output "igw_id" {
  value = aws_internet_gateway.igw.id
}

output "availability_zone" {
  value = [aws_subnet.private_subnets[*].availability_zone]
}

output "accept_status" {
  value = aws_vpc_peering_connection.peer[*].accept_status
}

output "vpc_peering_id" {
  value = aws_vpc_peering_connection.peer[*].id
}

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

output "instance_id" {
  description = "List of IDs of instances"
  value       = [aws_instance.ec2[*].id]
}

output "public_dns" {
  description = "List of public DNS names assigned to the instances. For EC2-VPC, this is only available if you've enabled DNS hostnames for your VPC"
  value       = [aws_instance.ec2[*].public_dns]
}

output "public_ip" {
  description = "List of public IP addresses assigned to the instances, if applicable"
  value       = [aws_instance.ec2[*].public_ip]
}

output "primary_network_interface_id" {
  description = "List of IDs of the primary network interface of instances"
  value       = [aws_instance.ec2[*].primary_network_interface_id]
}

output "private_dns" {
  description = "List of private DNS names assigned to the instances. Can only be used inside the Amazon EC2, and only available if you've enabled DNS hostnames for your VPC"
  value       = [aws_instance.ec2[*].private_dns]
}

output "private_ip" {
  description = "List of private IP addresses assigned to the instances"
  value       = [aws_instance.ec2[*].private_ip]
}
