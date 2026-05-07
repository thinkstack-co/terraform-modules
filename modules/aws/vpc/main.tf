terraform {
  required_version = ">= 1.0.0"
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = ">= 4.0.0"
    }
  }
}

###########################
# Data Sources
###########################
data "aws_caller_identity" "current" {}
data "aws_region" "current" {}

locals {
  service_name = "com.amazonaws.${data.aws_region.current.id}.s3"

  # ─── Per-subnet-type AZ→CIDR maps ──────────────────────────────────────────
  # Zip var.azs with var.*_subnets_list to produce {az_name => cidr_block}
  # maps. An AZ is included in a map only when:
  #   1. the subnet group is not globally disabled (var.*_subnet_disabled)
  #   2. a CIDR exists at the AZ's index in var.*_subnets_list
  #   3. the AZ is not in var.disabled_azs (global cascade)
  #   4. the AZ is not in var.*_subnet_disabled_azs (per-type override)
  # These maps drive every for_each below — disabling an AZ here cascades
  # into every dependent subnet, route table, NAT GW, EIP, association,
  # and S3 endpoint RT association tied to that AZ.
  private_subnets_map = {
    for idx, az in var.azs : az => var.private_subnets_list[idx]
    if !var.private_subnet_disabled &&
    idx < length(var.private_subnets_list) &&
    !contains(var.disabled_azs, az) &&
    !contains(var.private_subnet_disabled_azs, az)
  }
  public_subnets_map = {
    for idx, az in var.azs : az => var.public_subnets_list[idx]
    if !var.public_subnet_disabled &&
    idx < length(var.public_subnets_list) &&
    !contains(var.disabled_azs, az) &&
    !contains(var.public_subnet_disabled_azs, az)
  }
  dmz_subnets_map = {
    for idx, az in var.azs : az => var.dmz_subnets_list[idx]
    if !var.dmz_subnet_disabled &&
    idx < length(var.dmz_subnets_list) &&
    !contains(var.disabled_azs, az) &&
    !contains(var.dmz_subnet_disabled_azs, az)
  }
  db_subnets_map = {
    for idx, az in var.azs : az => var.db_subnets_list[idx]
    if !var.db_subnet_disabled &&
    idx < length(var.db_subnets_list) &&
    !contains(var.disabled_azs, az) &&
    !contains(var.db_subnet_disabled_azs, az)
  }
  mgmt_subnets_map = {
    for idx, az in var.azs : az => var.mgmt_subnets_list[idx]
    if !var.mgmt_subnet_disabled &&
    idx < length(var.mgmt_subnets_list) &&
    !contains(var.disabled_azs, az) &&
    !contains(var.mgmt_subnet_disabled_azs, az)
  }
  workspaces_subnets_map = {
    for idx, az in var.azs : az => var.workspaces_subnets_list[idx]
    if !var.workspaces_subnet_disabled &&
    idx < length(var.workspaces_subnets_list) &&
    !contains(var.disabled_azs, az) &&
    !contains(var.workspaces_subnet_disabled_azs, az)
  }

  # Group-level creation flags. True when the corresponding map has at least
  # one enabled AZ. Preserves the previous create_* semantics for downstream
  # gating (SSM endpoints, NAT gateway).
  create_private_subnets    = length(local.private_subnets_map) > 0
  create_public_subnets     = length(local.public_subnets_map) > 0
  create_dmz_subnets        = length(local.dmz_subnets_map) > 0
  create_db_subnets         = length(local.db_subnets_map) > 0
  create_mgmt_subnets       = length(local.mgmt_subnets_map) > 0
  create_workspaces_subnets = length(local.workspaces_subnets_map) > 0
  create_ssm_vpc_endpoints  = var.enable_ssm_vpc_endpoints && local.create_private_subnets
  create_nat_gateway        = var.enable_nat_gateway && local.create_public_subnets

  # ─── NAT gateway placement ─────────────────────────────────────────────────
  # NAT GWs live only in AZs that have a public subnet. With
  # var.single_nat_gateway, a single NAT GW is placed in the alphabetically
  # first public AZ — sort() guarantees stable selection across plans.
  single_nat_gateway_az = (
    var.single_nat_gateway && local.create_public_subnets
    ? sort(keys(local.public_subnets_map))[0]
    : null
  )
  nat_gateway_azs_set = local.create_nat_gateway ? (
    var.single_nat_gateway
    ? toset([local.single_nat_gateway_az])
    : toset(keys(local.public_subnets_map))
  ) : toset([])

  # ─── Positional AZ index lookup ────────────────────────────────────────────
  # Maps each AZ name to its 0-based position in var.azs. Used only to look
  # up firewall network interface IDs from the positional
  # var.fw_network_interface_id and var.fw_dmz_network_interface_id lists
  # (kept positional to preserve the existing variable interface). Customers
  # passing fewer ENIs than AZs must ensure the index for every enabled AZ
  # exists in their ENI list.
  az_index = { for idx, az in var.azs : az => idx }

  # ─── Route table propagation ───────────────────────────────────────────────
  # Apply route propagation only when explicitly enabled at the module level.
  # null means "do not manage this argument" so external propagation
  # resources can own it.
  effective_public_propagating_vgws     = var.enable_route_table_propagation ? var.public_propagating_vgws : null
  effective_private_propagating_vgws    = var.enable_route_table_propagation ? var.private_propagating_vgws : null
  effective_db_propagating_vgws         = var.enable_route_table_propagation ? var.db_propagating_vgws : null
  effective_dmz_propagating_vgws        = var.enable_route_table_propagation ? var.dmz_propagating_vgws : null
  effective_mgmt_propagating_vgws       = var.enable_route_table_propagation ? var.mgmt_propagating_vgws : null
  effective_workspaces_propagating_vgws = var.enable_route_table_propagation ? var.workspaces_propagating_vgws : null
}

###########################
# VPC
###########################

# Purpose:       The VPC itself. All other resources in this module attach to
#                it directly or through subnets/route tables.
# Referenced by: every resource in this module that takes vpc_id
# References:    var.vpc_cidr, var.tags, var.name
resource "aws_vpc" "vpc" {
  cidr_block           = var.vpc_cidr
  enable_dns_hostnames = var.enable_dns_hostnames
  enable_dns_support   = var.enable_dns_support
  instance_tenancy     = var.instance_tenancy
  tags                 = merge(tomap({ Name = var.name }), var.tags)
}

# Purpose:       Lock down the VPC's auto-created default security group so
#                no resource can attach to it and inadvertently get
#                intra-SG-allow-all traffic.
# Referenced by: nothing — callers should never attach to the default SG
# References:    aws_vpc.vpc
# Why:           Managing the default SG with no ingress/egress blocks
#                strips all rules (default SG normally allows all
#                intra-SG traffic) and prevents AWS from recreating it
#                with permissive defaults.
resource "aws_default_security_group" "default" {
  vpc_id = aws_vpc.vpc.id
  tags   = merge(var.tags, ({ "Name" = format("%s-default-sg-locked", var.name) }))
}

###########################
# VPC Endpoints
###########################

# Purpose:       Security group attached to interface VPC endpoints (SSM
#                family). Allows TCP/UDP 443 ingress from within the VPC and
#                unrestricted egress back out.
# Referenced by: aws_vpc_endpoint.ec2messages, .kms, .ssm, .ssm-contacts,
#                .ssm-incidents, .ssmmessages
# References:    aws_vpc.vpc, var.vpc_cidr
resource "aws_security_group" "security_group" {
  description = "SSM VPC service endpoint SG."
  name        = "ssm_vpc_endpoint_sg"
  tags        = var.tags
  vpc_id      = aws_vpc.vpc.id

  ingress {
    description = "SSM Communication over HTTPS"
    from_port   = 443
    to_port     = 443
    protocol    = "tcp"
    cidr_blocks = [var.vpc_cidr]
  }

  ingress {
    description = "SSM Communication over HTTPS"
    from_port   = 443
    to_port     = 443
    protocol    = "udp"
    cidr_blocks = [var.vpc_cidr]
  }

  egress {
    description = "All traffic"
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

# Purpose:       Interface VPC endpoint for the EC2 messages service. Required
#                for SSM Session Manager / agent communication when private
#                subnets have no NAT egress.
# Referenced by: nothing in this module — consumed by SSM-managed instances
# References:    aws_vpc.vpc, aws_security_group.security_group,
#                aws_subnet.private_subnets (all enabled private AZs)
# Why:           subnet_ids built via for-expression because aws_subnet is
#                keyed by AZ (for_each), so [*] splat does not apply.
resource "aws_vpc_endpoint" "ec2messages" {
  count               = local.create_ssm_vpc_endpoints ? 1 : 0
  vpc_id              = aws_vpc.vpc.id
  service_name        = "com.amazonaws.${data.aws_region.current.id}.ec2messages"
  security_group_ids  = [aws_security_group.security_group.id]
  vpc_endpoint_type   = "Interface"
  private_dns_enabled = true
  subnet_ids          = [for s in aws_subnet.private_subnets : s.id]
  tags                = merge(tomap({ Name = var.name }), var.tags)
}

# Purpose:       Interface VPC endpoint for KMS. Allows private-subnet
#                workloads to call KMS without internet egress.
# Referenced by: nothing in this module
# References:    aws_vpc.vpc, aws_security_group.security_group,
#                aws_subnet.private_subnets
resource "aws_vpc_endpoint" "kms" {
  count               = local.create_ssm_vpc_endpoints ? 1 : 0
  vpc_id              = aws_vpc.vpc.id
  service_name        = "com.amazonaws.${data.aws_region.current.id}.kms"
  security_group_ids  = [aws_security_group.security_group.id]
  vpc_endpoint_type   = "Interface"
  private_dns_enabled = true
  subnet_ids          = [for s in aws_subnet.private_subnets : s.id]
  tags                = merge(tomap({ Name = var.name }), var.tags)
}

# Purpose:       Interface VPC endpoint for SSM core API.
# Referenced by: nothing in this module
# References:    aws_vpc.vpc, aws_security_group.security_group,
#                aws_subnet.private_subnets
resource "aws_vpc_endpoint" "ssm" {
  count               = local.create_ssm_vpc_endpoints ? 1 : 0
  vpc_id              = aws_vpc.vpc.id
  service_name        = "com.amazonaws.${data.aws_region.current.id}.ssm"
  security_group_ids  = [aws_security_group.security_group.id]
  vpc_endpoint_type   = "Interface"
  private_dns_enabled = true
  subnet_ids          = [for s in aws_subnet.private_subnets : s.id]
  tags                = merge(tomap({ Name = var.name }), var.tags)
}

# Purpose:       Interface VPC endpoint for SSM Contacts (Incident Manager).
# Referenced by: nothing in this module
# References:    aws_vpc.vpc, aws_security_group.security_group,
#                aws_subnet.private_subnets
resource "aws_vpc_endpoint" "ssm-contacts" {
  count               = local.create_ssm_vpc_endpoints ? 1 : 0
  vpc_id              = aws_vpc.vpc.id
  service_name        = "com.amazonaws.${data.aws_region.current.id}.ssm-contacts"
  security_group_ids  = [aws_security_group.security_group.id]
  vpc_endpoint_type   = "Interface"
  private_dns_enabled = true
  subnet_ids          = [for s in aws_subnet.private_subnets : s.id]
  tags                = merge(tomap({ Name = var.name }), var.tags)
}

# Purpose:       Interface VPC endpoint for SSM Incidents (Incident Manager).
# Referenced by: nothing in this module
# References:    aws_vpc.vpc, aws_security_group.security_group,
#                aws_subnet.private_subnets
resource "aws_vpc_endpoint" "ssm-incidents" {
  count               = local.create_ssm_vpc_endpoints ? 1 : 0
  vpc_id              = aws_vpc.vpc.id
  service_name        = "com.amazonaws.${data.aws_region.current.id}.ssm-incidents"
  security_group_ids  = [aws_security_group.security_group.id]
  vpc_endpoint_type   = "Interface"
  private_dns_enabled = true
  subnet_ids          = [for s in aws_subnet.private_subnets : s.id]
  tags                = merge(tomap({ Name = var.name }), var.tags)
}

# Purpose:       Interface VPC endpoint for SSM Messages (Session Manager
#                shell traffic).
# Referenced by: nothing in this module
# References:    aws_vpc.vpc, aws_security_group.security_group,
#                aws_subnet.private_subnets
resource "aws_vpc_endpoint" "ssmmessages" {
  count               = local.create_ssm_vpc_endpoints ? 1 : 0
  vpc_id              = aws_vpc.vpc.id
  service_name        = "com.amazonaws.${data.aws_region.current.id}.ssmmessages"
  security_group_ids  = [aws_security_group.security_group.id]
  vpc_endpoint_type   = "Interface"
  private_dns_enabled = true
  subnet_ids          = [for s in aws_subnet.private_subnets : s.id]
  tags                = merge(tomap({ Name = var.name }), var.tags)
}

###########################
# Subnets
###########################

# Purpose:       Private subnets, one per enabled AZ. Workloads with no direct
#                internet exposure live here.
# Referenced by: aws_route_table_association.private,
#                aws_vpc_endpoint.* (SSM family),
#                aws_route.private_default_route_*
# References:    aws_vpc.vpc, local.private_subnets_map
# Why:           for_each keyed by AZ so disabling an AZ removes only that
#                AZ's subnet without recreating its peers.
resource "aws_subnet" "private_subnets" {
  for_each          = local.private_subnets_map
  vpc_id            = aws_vpc.vpc.id
  cidr_block        = each.value
  availability_zone = each.key
  tags              = merge(var.tags, ({ "Name" = format("%s-subnet-private-%s", var.name, each.key) }))
}

# Purpose:       Public subnets, one per enabled AZ. Hosts NAT gateways and
#                public-facing load balancers. map_public_ip_on_launch is
#                controlled by var.map_public_ip_on_launch.
# Referenced by: aws_route_table_association.public, aws_nat_gateway.natgw
# References:    aws_vpc.vpc, local.public_subnets_map
# Why:           for_each keyed by AZ for selective AZ disable.
resource "aws_subnet" "public_subnets" {
  for_each                = local.public_subnets_map
  vpc_id                  = aws_vpc.vpc.id
  cidr_block              = each.value
  availability_zone       = each.key
  map_public_ip_on_launch = var.map_public_ip_on_launch
  tags                    = merge(var.tags, ({ "Name" = format("%s-subnet-public-%s", var.name, each.key) }))
}

# Purpose:       DMZ subnets, one per enabled AZ. Used for firewall data-plane
#                interfaces or other inspection zones.
# Referenced by: aws_route_table_association.dmz,
#                aws_route.dmz_default_route_*
# References:    aws_vpc.vpc, local.dmz_subnets_map
resource "aws_subnet" "dmz_subnets" {
  for_each          = local.dmz_subnets_map
  vpc_id            = aws_vpc.vpc.id
  cidr_block        = each.value
  availability_zone = each.key
  tags              = merge(var.tags, ({ "Name" = format("%s-subnet-dmz-%s", var.name, each.key) }))
}

# Purpose:       Database subnets, one per enabled AZ. Typically consumed by
#                aws_db_subnet_group in the calling module.
# Referenced by: aws_route_table_association.db,
#                aws_route.db_default_route_*
# References:    aws_vpc.vpc, local.db_subnets_map
resource "aws_subnet" "db_subnets" {
  for_each          = local.db_subnets_map
  vpc_id            = aws_vpc.vpc.id
  cidr_block        = each.value
  availability_zone = each.key
  tags              = merge(var.tags, ({ "Name" = format("%s-subnet-db-%s", var.name, each.key) }))
}

# Purpose:       Management subnets, one per enabled AZ. Reserved for jump
#                hosts, agent infrastructure, or other operational tooling.
# Referenced by: aws_route.mgmt_default_route_*
# References:    aws_vpc.vpc, local.mgmt_subnets_map
resource "aws_subnet" "mgmt_subnets" {
  for_each          = local.mgmt_subnets_map
  vpc_id            = aws_vpc.vpc.id
  cidr_block        = each.value
  availability_zone = each.key
  tags              = merge(var.tags, ({ "Name" = format("%s-subnet-mgmt-%s", var.name, each.key) }))
}

# Purpose:       Workspaces subnets, one per enabled AZ. Sized for AWS
#                Workspaces ENI density.
# Referenced by: aws_route_table_association.workspaces,
#                aws_route.workspaces_default_route_*
# References:    aws_vpc.vpc, local.workspaces_subnets_map
resource "aws_subnet" "workspaces_subnets" {
  for_each          = local.workspaces_subnets_map
  vpc_id            = aws_vpc.vpc.id
  cidr_block        = each.value
  availability_zone = each.key
  tags              = merge(var.tags, ({ "Name" = format("%s-subnet-workspaces-%s", var.name, each.key) }))
}

###########################
# Gateways
###########################

# Purpose:       Internet gateway for the VPC. Single resource, always
#                created (independent of public subnet enablement).
# Referenced by: aws_route.public_default_route, aws_nat_gateway.natgw
#                (depends_on)
# References:    aws_vpc.vpc
resource "aws_internet_gateway" "igw" {
  tags   = merge(var.tags, ({ "Name" = format("%s-igw", var.name) }))
  vpc_id = aws_vpc.vpc.id
}

# Purpose:       Single shared route table for all public subnets.
# Referenced by: aws_route.public_default_route,
#                aws_route_table_association.public,
#                aws_vpc_endpoint_route_table_association.public_s3
# References:    aws_vpc.vpc, local.effective_public_propagating_vgws
resource "aws_route_table" "public_route_table" {
  propagating_vgws = local.effective_public_propagating_vgws
  tags             = merge(var.tags, ({ "Name" = format("%s-rt-public", var.name) }))
  vpc_id           = aws_vpc.vpc.id
}

# Purpose:       Default route on the public RT pointing at the IGW.
# Referenced by: nothing
# References:    aws_internet_gateway.igw, aws_route_table.public_route_table
resource "aws_route" "public_default_route" {
  destination_cidr_block = "0.0.0.0/0"
  gateway_id             = aws_internet_gateway.igw.id
  route_table_id         = aws_route_table.public_route_table.id
}

# Purpose:       Elastic IPs for NAT gateways. One per AZ that hosts a NAT
#                GW (or one total, in single-NAT mode).
# Referenced by: aws_nat_gateway.natgw
# References:    local.nat_gateway_azs_set
resource "aws_eip" "nateip" {
  for_each = local.nat_gateway_azs_set
  domain   = "vpc"
  tags     = merge(var.tags, ({ "Name" = format("%s-eip-natgw-%s", var.name, each.value) }))
}

# Purpose:       NAT gateways. One per AZ that hosts a public subnet, or one
#                total in single-NAT mode. Each places into the matching AZ's
#                public subnet.
# Referenced by: aws_route.*_default_route_natgw (every non-public subnet
#                type's NAT route)
# References:    aws_eip.nateip, aws_subnet.public_subnets,
#                local.nat_gateway_azs_set, aws_internet_gateway.igw
# Why:           depends_on IGW because NAT GW creation fails if the IGW is
#                still attaching at the same time.
resource "aws_nat_gateway" "natgw" {
  depends_on = [aws_internet_gateway.igw]

  for_each      = local.nat_gateway_azs_set
  allocation_id = aws_eip.nateip[each.key].id
  subnet_id     = aws_subnet.public_subnets[each.key].id
  tags          = merge(var.tags, ({ "Name" = format("%s-natgw-%s", var.name, each.value) }))
}

###########################
# Route Tables and Associations
###########################

# Purpose:       Per-AZ private route tables. One per enabled private AZ so
#                each AZ's egress can target its local NAT GW (avoiding
#                cross-AZ data transfer charges).
# Referenced by: aws_route.private_default_route_natgw,
#                aws_route.private_default_route_fw,
#                aws_route_table_association.private,
#                aws_vpc_endpoint_route_table_association.private_s3
# References:    aws_vpc.vpc, local.private_subnets_map,
#                local.effective_private_propagating_vgws
resource "aws_route_table" "private_route_table" {
  for_each         = local.private_subnets_map
  propagating_vgws = local.effective_private_propagating_vgws
  tags             = merge(var.tags, ({ "Name" = format("%s-rt-private-%s", var.name, each.key) }))
  vpc_id           = aws_vpc.vpc.id
}

# Purpose:       Default route on each private RT pointing at the NAT GW.
#                In single-NAT mode every private RT points at the lone NAT
#                GW; otherwise each points at the NAT GW in its own AZ.
# Referenced by: nothing
# References:    aws_route_table.private_route_table, aws_nat_gateway.natgw
# Why:           for_each is filtered to private AZs that have a reachable
#                NAT GW. In per-AZ mode that means the AZ must have its own
#                public subnet + NAT GW; in single-NAT mode any private AZ
#                qualifies as long as one NAT GW exists.
resource "aws_route" "private_default_route_natgw" {
  for_each = {
    for az in keys(local.private_subnets_map) : az => az
    if local.create_nat_gateway && (
      var.single_nat_gateway || contains(local.nat_gateway_azs_set, az)
    )
  }
  destination_cidr_block = "0.0.0.0/0"
  nat_gateway_id = aws_nat_gateway.natgw[
    var.single_nat_gateway ? local.single_nat_gateway_az : each.key
  ].id
  route_table_id = aws_route_table.private_route_table[each.key].id
}

# Purpose:       Default route on each private RT pointing at a firewall ENI.
#                Mutually exclusive with the NAT route (caller chooses one).
# Referenced by: nothing
# References:    aws_route_table.private_route_table,
#                var.fw_network_interface_id, local.az_index
# Why:           Firewall ENIs are a positional list indexed by var.azs
#                position. Caller is responsible for ensuring the list has an
#                entry at the index of every enabled private AZ.
resource "aws_route" "private_default_route_fw" {
  for_each               = var.enable_firewall ? local.private_subnets_map : {}
  destination_cidr_block = "0.0.0.0/0"
  network_interface_id   = var.fw_network_interface_id[local.az_index[each.key]]
  route_table_id         = aws_route_table.private_route_table[each.key].id
}

# Purpose:       Per-AZ database route tables.
# Referenced by: aws_route.db_default_route_*,
#                aws_route_table_association.db,
#                aws_vpc_endpoint_route_table_association.db_s3
# References:    aws_vpc.vpc, local.db_subnets_map,
#                local.effective_db_propagating_vgws
resource "aws_route_table" "db_route_table" {
  for_each         = local.db_subnets_map
  propagating_vgws = local.effective_db_propagating_vgws
  tags             = merge(var.tags, ({ "Name" = format("%s-rt-db-%s", var.name, each.key) }))
  vpc_id           = aws_vpc.vpc.id
}

# Purpose:       NAT default route on each db RT.
# Referenced by: nothing
# References:    aws_route_table.db_route_table, aws_nat_gateway.natgw
resource "aws_route" "db_default_route_natgw" {
  for_each = {
    for az in keys(local.db_subnets_map) : az => az
    if local.create_nat_gateway && (
      var.single_nat_gateway || contains(local.nat_gateway_azs_set, az)
    )
  }
  destination_cidr_block = "0.0.0.0/0"
  nat_gateway_id = aws_nat_gateway.natgw[
    var.single_nat_gateway ? local.single_nat_gateway_az : each.key
  ].id
  route_table_id = aws_route_table.db_route_table[each.key].id
}

# Purpose:       Firewall default route on each db RT.
# Referenced by: nothing
# References:    aws_route_table.db_route_table, var.fw_network_interface_id,
#                local.az_index
resource "aws_route" "db_default_route_fw" {
  for_each               = var.enable_firewall ? local.db_subnets_map : {}
  destination_cidr_block = "0.0.0.0/0"
  network_interface_id   = var.fw_network_interface_id[local.az_index[each.key]]
  route_table_id         = aws_route_table.db_route_table[each.key].id
}

# Purpose:       Per-AZ DMZ route tables.
# Referenced by: aws_route.dmz_default_route_*,
#                aws_route_table_association.dmz,
#                aws_vpc_endpoint_route_table_association.dmz_s3
# References:    aws_vpc.vpc, local.dmz_subnets_map,
#                local.effective_dmz_propagating_vgws
resource "aws_route_table" "dmz_route_table" {
  for_each         = local.dmz_subnets_map
  propagating_vgws = local.effective_dmz_propagating_vgws
  tags             = merge(var.tags, ({ "Name" = format("%s-rt-dmz-%s", var.name, each.key) }))
  vpc_id           = aws_vpc.vpc.id
}

# Purpose:       NAT default route on each DMZ RT.
# Referenced by: nothing
# References:    aws_route_table.dmz_route_table, aws_nat_gateway.natgw
resource "aws_route" "dmz_default_route_natgw" {
  for_each = {
    for az in keys(local.dmz_subnets_map) : az => az
    if local.create_nat_gateway && (
      var.single_nat_gateway || contains(local.nat_gateway_azs_set, az)
    )
  }
  destination_cidr_block = "0.0.0.0/0"
  nat_gateway_id = aws_nat_gateway.natgw[
    var.single_nat_gateway ? local.single_nat_gateway_az : each.key
  ].id
  route_table_id = aws_route_table.dmz_route_table[each.key].id
}

# Purpose:       Firewall default route on each DMZ RT.
# Referenced by: nothing
# References:    aws_route_table.dmz_route_table,
#                var.fw_dmz_network_interface_id, local.az_index
# Why:           DMZ uses a separate ENI list (fw_dmz_network_interface_id)
#                because firewall data-plane interfaces are different from
#                management/inside interfaces.
resource "aws_route" "dmz_default_route_fw" {
  for_each               = var.enable_firewall ? local.dmz_subnets_map : {}
  destination_cidr_block = "0.0.0.0/0"
  network_interface_id   = var.fw_dmz_network_interface_id[local.az_index[each.key]]
  route_table_id         = aws_route_table.dmz_route_table[each.key].id
}

# Purpose:       Per-AZ management route tables.
# Referenced by: aws_route.mgmt_default_route_*,
#                aws_vpc_endpoint_route_table_association.mgmt_s3
# References:    aws_vpc.vpc, local.mgmt_subnets_map,
#                local.effective_mgmt_propagating_vgws
resource "aws_route_table" "mgmt_route_table" {
  for_each         = local.mgmt_subnets_map
  propagating_vgws = local.effective_mgmt_propagating_vgws
  tags             = merge(var.tags, ({ "Name" = format("%s-rt-mgmt-%s", var.name, each.key) }))
  vpc_id           = aws_vpc.vpc.id
}

# Purpose:       NAT default route on each mgmt RT.
# Referenced by: nothing
# References:    aws_route_table.mgmt_route_table, aws_nat_gateway.natgw
resource "aws_route" "mgmt_default_route_natgw" {
  for_each = {
    for az in keys(local.mgmt_subnets_map) : az => az
    if local.create_nat_gateway && (
      var.single_nat_gateway || contains(local.nat_gateway_azs_set, az)
    )
  }
  destination_cidr_block = "0.0.0.0/0"
  nat_gateway_id = aws_nat_gateway.natgw[
    var.single_nat_gateway ? local.single_nat_gateway_az : each.key
  ].id
  route_table_id = aws_route_table.mgmt_route_table[each.key].id
}

# Purpose:       Firewall default route on each mgmt RT.
# Referenced by: nothing
# References:    aws_route_table.mgmt_route_table,
#                var.fw_network_interface_id, local.az_index
resource "aws_route" "mgmt_default_route_fw" {
  for_each               = var.enable_firewall ? local.mgmt_subnets_map : {}
  destination_cidr_block = "0.0.0.0/0"
  network_interface_id   = var.fw_network_interface_id[local.az_index[each.key]]
  route_table_id         = aws_route_table.mgmt_route_table[each.key].id
}

# Purpose:       Per-AZ Workspaces route tables.
# Referenced by: aws_route.workspaces_default_route_*,
#                aws_route_table_association.workspaces,
#                aws_vpc_endpoint_route_table_association.workspaces_s3
# References:    aws_vpc.vpc, local.workspaces_subnets_map,
#                local.effective_workspaces_propagating_vgws
resource "aws_route_table" "workspaces_route_table" {
  for_each         = local.workspaces_subnets_map
  propagating_vgws = local.effective_workspaces_propagating_vgws
  tags             = merge(var.tags, ({ "Name" = format("%s-rt-workspaces-%s", var.name, each.key) }))
  vpc_id           = aws_vpc.vpc.id
}

# Purpose:       NAT default route on each Workspaces RT.
# Referenced by: nothing
# References:    aws_route_table.workspaces_route_table, aws_nat_gateway.natgw
resource "aws_route" "workspaces_default_route_natgw" {
  for_each = {
    for az in keys(local.workspaces_subnets_map) : az => az
    if local.create_nat_gateway && (
      var.single_nat_gateway || contains(local.nat_gateway_azs_set, az)
    )
  }
  destination_cidr_block = "0.0.0.0/0"
  nat_gateway_id = aws_nat_gateway.natgw[
    var.single_nat_gateway ? local.single_nat_gateway_az : each.key
  ].id
  route_table_id = aws_route_table.workspaces_route_table[each.key].id
}

# Purpose:       Firewall default route on each Workspaces RT.
# Referenced by: nothing
# References:    aws_route_table.workspaces_route_table,
#                var.fw_network_interface_id, local.az_index
resource "aws_route" "workspaces_default_route_fw" {
  for_each               = var.enable_firewall ? local.workspaces_subnets_map : {}
  destination_cidr_block = "0.0.0.0/0"
  network_interface_id   = var.fw_network_interface_id[local.az_index[each.key]]
  route_table_id         = aws_route_table.workspaces_route_table[each.key].id
}

# Purpose:       S3 gateway VPC endpoint. Provides free in-region S3 access
#                without traversing NAT gateways.
# Referenced by: aws_vpc_endpoint_route_table_association.*_s3
# References:    aws_vpc.vpc, local.service_name
resource "aws_vpc_endpoint" "s3" {
  count        = var.enable_s3_endpoint ? 1 : 0
  vpc_id       = aws_vpc.vpc.id
  service_name = local.service_name
  tags         = merge(tomap({ Name = "${var.name}-s3-endpoint" }), var.tags)
}

# Purpose:       Bind the S3 gateway endpoint to each private RT so private
#                workloads pick up the prefix-list route to S3.
# Referenced by: nothing
# References:    aws_vpc_endpoint.s3, aws_route_table.private_route_table
resource "aws_vpc_endpoint_route_table_association" "private_s3" {
  for_each        = var.enable_s3_endpoint ? local.private_subnets_map : {}
  vpc_endpoint_id = aws_vpc_endpoint.s3[0].id
  route_table_id  = aws_route_table.private_route_table[each.key].id
}

# Purpose:       Bind the S3 gateway endpoint to the single public RT.
# Referenced by: nothing
# References:    aws_vpc_endpoint.s3, aws_route_table.public_route_table
# Why:           One association per (endpoint, RT). Public RT is a single
#                resource shared by all public subnets, so this is a single
#                count regardless of how many public AZs exist.
resource "aws_vpc_endpoint_route_table_association" "public_s3" {
  count           = var.enable_s3_endpoint && local.create_public_subnets ? 1 : 0
  vpc_endpoint_id = aws_vpc_endpoint.s3[0].id
  route_table_id  = aws_route_table.public_route_table.id
}

# Purpose:       Bind S3 gateway endpoint to each db RT.
# Referenced by: nothing
# References:    aws_vpc_endpoint.s3, aws_route_table.db_route_table
resource "aws_vpc_endpoint_route_table_association" "db_s3" {
  for_each        = var.enable_s3_endpoint ? local.db_subnets_map : {}
  vpc_endpoint_id = aws_vpc_endpoint.s3[0].id
  route_table_id  = aws_route_table.db_route_table[each.key].id
}

# Purpose:       Bind S3 gateway endpoint to each DMZ RT.
# Referenced by: nothing
# References:    aws_vpc_endpoint.s3, aws_route_table.dmz_route_table
resource "aws_vpc_endpoint_route_table_association" "dmz_s3" {
  for_each        = var.enable_s3_endpoint ? local.dmz_subnets_map : {}
  vpc_endpoint_id = aws_vpc_endpoint.s3[0].id
  route_table_id  = aws_route_table.dmz_route_table[each.key].id
}

# Purpose:       Bind S3 gateway endpoint to each mgmt RT.
# Referenced by: nothing
# References:    aws_vpc_endpoint.s3, aws_route_table.mgmt_route_table
resource "aws_vpc_endpoint_route_table_association" "mgmt_s3" {
  for_each        = var.enable_s3_endpoint ? local.mgmt_subnets_map : {}
  vpc_endpoint_id = aws_vpc_endpoint.s3[0].id
  route_table_id  = aws_route_table.mgmt_route_table[each.key].id
}

# Purpose:       Bind S3 gateway endpoint to each Workspaces RT.
# Referenced by: nothing
# References:    aws_vpc_endpoint.s3, aws_route_table.workspaces_route_table
resource "aws_vpc_endpoint_route_table_association" "workspaces_s3" {
  for_each        = var.enable_s3_endpoint ? local.workspaces_subnets_map : {}
  vpc_endpoint_id = aws_vpc_endpoint.s3[0].id
  route_table_id  = aws_route_table.workspaces_route_table[each.key].id
}

# Purpose:       Associate each private subnet with its AZ's private RT.
# Referenced by: nothing
# References:    aws_route_table.private_route_table,
#                aws_subnet.private_subnets
resource "aws_route_table_association" "private" {
  for_each       = local.private_subnets_map
  route_table_id = aws_route_table.private_route_table[each.key].id
  subnet_id      = aws_subnet.private_subnets[each.key].id
}

# Purpose:       Associate each public subnet with the single public RT.
# Referenced by: nothing
# References:    aws_route_table.public_route_table, aws_subnet.public_subnets
resource "aws_route_table_association" "public" {
  for_each       = local.public_subnets_map
  route_table_id = aws_route_table.public_route_table.id
  subnet_id      = aws_subnet.public_subnets[each.key].id
}

# Purpose:       Associate each db subnet with its AZ's db RT.
# Referenced by: nothing
# References:    aws_route_table.db_route_table, aws_subnet.db_subnets
resource "aws_route_table_association" "db" {
  for_each       = local.db_subnets_map
  route_table_id = aws_route_table.db_route_table[each.key].id
  subnet_id      = aws_subnet.db_subnets[each.key].id
}

# Purpose:       Associate each DMZ subnet with its AZ's DMZ RT.
# Referenced by: nothing
# References:    aws_route_table.dmz_route_table, aws_subnet.dmz_subnets
resource "aws_route_table_association" "dmz" {
  for_each       = local.dmz_subnets_map
  route_table_id = aws_route_table.dmz_route_table[each.key].id
  subnet_id      = aws_subnet.dmz_subnets[each.key].id
}

# Purpose:       Associate each Workspaces subnet with its AZ's Workspaces RT.
# Referenced by: nothing
# References:    aws_route_table.workspaces_route_table,
#                aws_subnet.workspaces_subnets
resource "aws_route_table_association" "workspaces" {
  for_each       = local.workspaces_subnets_map
  route_table_id = aws_route_table.workspaces_route_table[each.key].id
  subnet_id      = aws_subnet.workspaces_subnets[each.key].id
}

######################################################
# VPC Flow Logs
######################################################

###########################
# KMS Encryption Key
###########################

# Purpose:       KMS CMK for encrypting flow log CloudWatch log group at rest.
# Referenced by: aws_kms_alias.alias, aws_cloudwatch_log_group.log_group
# References:    data.aws_caller_identity.current, data.aws_region.current
# Why:           Policy includes a logs.<region>.amazonaws.com grant scoped
#                via kms:EncryptionContext to the log group ARN, so only
#                CloudWatch Logs in this account/region can use the key.
resource "aws_kms_key" "key" {
  count                    = (var.enable_vpc_flow_logs == true ? 1 : 0)
  customer_master_key_spec = var.key_customer_master_key_spec
  description              = var.key_description
  deletion_window_in_days  = var.key_deletion_window_in_days
  enable_key_rotation      = var.key_enable_key_rotation
  key_usage                = var.key_usage
  is_enabled               = var.key_is_enabled
  tags                     = var.tags
  policy = jsonencode({
    "Version" = "2012-10-17",
    "Statement" = [
      {
        "Sid"    = "Enable IAM User Permissions",
        "Effect" = "Allow",
        "Principal" = {
          "AWS" = "arn:aws:iam::${data.aws_caller_identity.current.account_id}:root"
        },
        "Action"   = "kms:*",
        "Resource" = "*"
      },
      {
        "Effect" = "Allow",
        "Principal" = {
          "Service" = "logs.${data.aws_region.current.id}.amazonaws.com"
        },
        "Action" = [
          "kms:Encrypt*",
          "kms:Decrypt*",
          "kms:ReEncrypt*",
          "kms:GenerateDataKey*",
          "kms:Describe*"
        ],
        "Resource" = "*",
        "Condition" = {
          "ArnEquals" = {
            "kms:EncryptionContext:aws:logs:arn" : "arn:aws:logs:${data.aws_region.current.id}:${data.aws_caller_identity.current.account_id}:log-group:*"
          }
        }
      }
    ]
  })
}

# Purpose:       Friendly alias for the flow logs KMS key.
# Referenced by: nothing
# References:    aws_kms_key.key
resource "aws_kms_alias" "alias" {
  count         = (var.enable_vpc_flow_logs == true ? 1 : 0)
  name_prefix   = var.key_name_prefix
  target_key_id = aws_kms_key.key[0].key_id
}

###########################
# CloudWatch Log Group
###########################

# Purpose:       Destination log group for VPC flow logs.
# Referenced by: aws_iam_policy.policy, aws_flow_log.vpc_flow
# References:    aws_kms_key.key
resource "aws_cloudwatch_log_group" "log_group" {
  count             = (var.enable_vpc_flow_logs == true ? 1 : 0)
  kms_key_id        = aws_kms_key.key[0].arn
  name_prefix       = var.cloudwatch_name_prefix
  retention_in_days = var.cloudwatch_retention_in_days
  tags              = var.tags
}

###########################
# IAM Policy
###########################

# Purpose:       IAM policy granting flow logs role write access to the log
#                group.
# Referenced by: aws_iam_role_policy_attachment.role_attach
# References:    aws_cloudwatch_log_group.log_group
resource "aws_iam_policy" "policy" {
  count       = (var.enable_vpc_flow_logs == true ? 1 : 0)
  description = var.iam_policy_description
  name_prefix = var.iam_policy_name_prefix
  path        = var.iam_policy_path
  tags        = var.tags
  policy = jsonencode({
    Version = "2012-10-17",
    Statement = [{
      Effect = "Allow",
      Action = [
        "logs:CreateLogGroup",
        "logs:CreateLogStream",
        "logs:PutLogEvents",
        "logs:DescribeLogGroups",
        "logs:DescribeLogStreams"
      ],
      Resource = [
        "${aws_cloudwatch_log_group.log_group[0].arn}:*"
      ]
    }]
  })
}

###########################
# IAM Role
###########################

# Purpose:       Service role assumed by VPC Flow Logs to write to CloudWatch.
# Referenced by: aws_iam_role_policy_attachment.role_attach,
#                aws_flow_log.vpc_flow
# References:    var.iam_role_assume_role_policy
resource "aws_iam_role" "role" {
  count                 = (var.enable_vpc_flow_logs == true ? 1 : 0)
  assume_role_policy    = var.iam_role_assume_role_policy
  description           = var.iam_role_description
  force_detach_policies = var.iam_role_force_detach_policies
  max_session_duration  = var.iam_role_max_session_duration
  name_prefix           = var.iam_role_name_prefix
  permissions_boundary  = var.iam_role_permissions_boundary
}

# Purpose:       Attach the flow logs IAM policy to the flow logs IAM role.
# Referenced by: nothing
# References:    aws_iam_role.role, aws_iam_policy.policy
resource "aws_iam_role_policy_attachment" "role_attach" {
  count      = (var.enable_vpc_flow_logs == true ? 1 : 0)
  role       = aws_iam_role.role[0].name
  policy_arn = aws_iam_policy.policy[0].arn
}


###########################
# VPC Flow Log
###########################

# Purpose:       Captures VPC-level network telemetry to CloudWatch Logs.
# Referenced by: nothing
# References:    aws_iam_role.role, aws_cloudwatch_log_group.log_group,
#                aws_vpc.vpc
resource "aws_flow_log" "vpc_flow" {
  count                    = (var.enable_vpc_flow_logs == true ? 1 : 0)
  iam_role_arn             = aws_iam_role.role[0].arn
  log_destination_type     = var.flow_log_destination_type
  log_destination          = aws_cloudwatch_log_group.log_group[0].arn
  max_aggregation_interval = var.flow_max_aggregation_interval
  tags                     = var.tags
  traffic_type             = var.flow_traffic_type
  vpc_id                   = aws_vpc.vpc.id
}
