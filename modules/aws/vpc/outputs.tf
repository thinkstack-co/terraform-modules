# ─── Subnet IDs ────────────────────────────────────────────────────────────
# Per-subnet-type list outputs preserved for backwards compatibility with
# existing callers. Map outputs (*_by_az) added so consumers can look up a
# subnet by AZ name without relying on positional ordering. List outputs are
# sorted by AZ name (Terraform iterates maps in lexical key order) so callers
# that index by [0]/[1]/[2] continue to see stable ordering.

output "private_subnet_ids" {
  description = "List of private subnet IDs ordered by AZ name. Empty when private subnets are disabled or all private AZs are disabled."
  value       = [for s in aws_subnet.private_subnets : s.id]
}

output "private_subnets_by_az" {
  description = "Map of AZ name to private subnet ID."
  value       = { for az, s in aws_subnet.private_subnets : az => s.id }
}

output "public_subnet_ids" {
  description = "List of public subnet IDs ordered by AZ name."
  value       = [for s in aws_subnet.public_subnets : s.id]
}

output "public_subnets_by_az" {
  description = "Map of AZ name to public subnet ID."
  value       = { for az, s in aws_subnet.public_subnets : az => s.id }
}

output "db_subnet_ids" {
  description = "List of database subnet IDs ordered by AZ name. Typically consumed by aws_db_subnet_group."
  value       = [for s in aws_subnet.db_subnets : s.id]
}

output "db_subnets_by_az" {
  description = "Map of AZ name to database subnet ID."
  value       = { for az, s in aws_subnet.db_subnets : az => s.id }
}

output "dmz_subnet_ids" {
  description = "List of DMZ subnet IDs ordered by AZ name."
  value       = [for s in aws_subnet.dmz_subnets : s.id]
}

output "dmz_subnets_by_az" {
  description = "Map of AZ name to DMZ subnet ID."
  value       = { for az, s in aws_subnet.dmz_subnets : az => s.id }
}

output "mgmt_subnet_ids" {
  description = "List of management subnet IDs ordered by AZ name."
  value       = [for s in aws_subnet.mgmt_subnets : s.id]
}

output "mgmt_subnets_by_az" {
  description = "Map of AZ name to management subnet ID."
  value       = { for az, s in aws_subnet.mgmt_subnets : az => s.id }
}

output "workspaces_subnet_ids" {
  description = "List of Workspaces subnet IDs ordered by AZ name."
  value       = [for s in aws_subnet.workspaces_subnets : s.id]
}

output "workspaces_subnets_by_az" {
  description = "Map of AZ name to Workspaces subnet ID."
  value       = { for az, s in aws_subnet.workspaces_subnets : az => s.id }
}

# ─── Subnet CIDRs ──────────────────────────────────────────────────────────

output "private_subnets" {
  description = "List of private subnet CIDR blocks ordered by AZ name."
  value       = [for s in aws_subnet.private_subnets : s.cidr_block]
}

output "public_subnets" {
  description = "List of public subnet CIDR blocks ordered by AZ name."
  value       = [for s in aws_subnet.public_subnets : s.cidr_block]
}

# ─── VPC ───────────────────────────────────────────────────────────────────

output "vpc_id" {
  description = "The ID of the VPC."
  value       = aws_vpc.vpc.id
}

output "vpc_cidr_block" {
  description = "The CIDR block of the VPC."
  value       = aws_vpc.vpc.cidr_block
}

output "default_security_group_id" {
  description = "The ID of the VPC's default security group, created automatically by AWS when the VPC is created."
  value       = aws_vpc.vpc.default_security_group_id
}

# ─── Route Tables ──────────────────────────────────────────────────────────

output "public_route_table_ids" {
  description = "List containing the single public route table ID. Returned as a list to match the shape of the other route-table outputs."
  value       = [aws_route_table.public_route_table.id]
}

output "private_route_table_ids" {
  description = "List of private route table IDs ordered by AZ name."
  value       = [for r in aws_route_table.private_route_table : r.id]
}

output "private_route_tables_by_az" {
  description = "Map of AZ name to private route table ID."
  value       = { for az, r in aws_route_table.private_route_table : az => r.id }
}

output "db_route_table_ids" {
  description = "List of database route table IDs ordered by AZ name."
  value       = [for r in aws_route_table.db_route_table : r.id]
}

output "db_route_tables_by_az" {
  description = "Map of AZ name to database route table ID."
  value       = { for az, r in aws_route_table.db_route_table : az => r.id }
}

output "dmz_route_table_ids" {
  description = "List of DMZ route table IDs ordered by AZ name."
  value       = [for r in aws_route_table.dmz_route_table : r.id]
}

output "dmz_route_tables_by_az" {
  description = "Map of AZ name to DMZ route table ID."
  value       = { for az, r in aws_route_table.dmz_route_table : az => r.id }
}

output "mgmt_route_table_ids" {
  description = "List of management route table IDs ordered by AZ name."
  value       = [for r in aws_route_table.mgmt_route_table : r.id]
}

output "mgmt_route_tables_by_az" {
  description = "Map of AZ name to management route table ID."
  value       = { for az, r in aws_route_table.mgmt_route_table : az => r.id }
}

output "workspaces_route_table_ids" {
  description = "List of Workspaces route table IDs ordered by AZ name."
  value       = [for r in aws_route_table.workspaces_route_table : r.id]
}

output "workspaces_route_tables_by_az" {
  description = "Map of AZ name to Workspaces route table ID."
  value       = { for az, r in aws_route_table.workspaces_route_table : az => r.id }
}

# ─── NAT / IGW ─────────────────────────────────────────────────────────────

output "nat_eips" {
  description = "List of NAT gateway EIP allocation IDs ordered by AZ name."
  value       = [for e in aws_eip.nateip : e.id]
}

output "nat_eips_public_ips" {
  description = "List of NAT gateway public IPs ordered by AZ name."
  value       = [for e in aws_eip.nateip : e.public_ip]
}

output "natgw_ids" {
  description = "List of NAT gateway IDs ordered by AZ name."
  value       = [for n in aws_nat_gateway.natgw : n.id]
}

output "natgws_by_az" {
  description = "Map of AZ name to NAT gateway ID."
  value       = { for az, n in aws_nat_gateway.natgw : az => n.id }
}

output "igw_id" {
  description = "List containing the single internet gateway ID. Returned as a list for backwards compatibility with the previous output shape."
  value       = [aws_internet_gateway.igw.id]
}

# ─── Misc ──────────────────────────────────────────────────────────────────

output "availability_zone" {
  description = "List of AZ names that have an enabled private subnet, ordered by AZ name."
  value       = [for s in aws_subnet.private_subnets : s.availability_zone]
}
