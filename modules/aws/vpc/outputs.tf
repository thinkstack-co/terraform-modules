output "private_subnet_ids" {
  value = aws_subnet.private_subnets[*].id
}

output "public_subnet_ids" {
  value = aws_subnet.public_subnets[*].id
}

output "db_subnet_ids" {
  value = aws_subnet.db_subnets[*].id
}

output "dmz_subnet_ids" {
  value = aws_subnet.dmz_subnets[*].id
}

output "mgmt_subnet_ids" {
  value = aws_subnet.mgmt_subnets[*].id
}

output "private_subnets" {
  value = aws_subnet.private_subnets[*].cidr_block
}

output "public_subnets" {
  value = aws_subnet.public_subnets[*].cidr_block
}

output "workspaces_subnet_ids" {
  value = aws_subnet.workspaces_subnets[*].id
}

output "vpc_id" {
  value = aws_vpc.vpc.id
}

output "vpc_cidr_block" {
  value = aws_vpc.vpc.cidr_block
}

output "public_route_table_ids" {
  value = aws_route_table.public_route_table[*].id
}

output "private_route_table_ids" {
  value = aws_route_table.private_route_table[*].id
}

output "db_route_table_ids" {
  value = aws_route_table.db_route_table[*].id
}

output "dmz_route_table_ids" {
  value = aws_route_table.dmz_route_table[*].id
}

output "mgmt_route_table_ids" {
  value = aws_route_table.mgmt_route_table[*].id
}

output "workspaces_route_table_ids" {
  value = aws_route_table.workspaces_route_table[*].id
}

output "default_security_group_id" {
  value = aws_vpc.vpc[*].default_security_group_id
}

output "nat_eips" {
  value = aws_eip.nateip[*].id
}

output "nat_eips_public_ips" {
  value = aws_eip.nateip[*].public_ip
}

output "natgw_ids" {
  value = aws_nat_gateway.natgw[*].id
}

output "igw_id" {
  value = aws_internet_gateway.igw[*].id
}

output "availability_zone" {
  value = aws_subnet.private_subnets[*].availability_zone
}
