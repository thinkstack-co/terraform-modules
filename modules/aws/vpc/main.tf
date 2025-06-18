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
  service_name = "com.amazonaws.${data.aws_region.current.name}.s3"
}

###########################
# VPC
###########################

resource "aws_vpc" "vpc" {
  cidr_block           = var.vpc_cidr
  enable_dns_hostnames = var.enable_dns_hostnames
  enable_dns_support   = var.enable_dns_support
  instance_tenancy     = var.instance_tenancy
  tags                 = merge(tomap({ Name = var.name }), var.tags)
}

###########################
# VPC Endpoints
###########################

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
    # Allow SSM outbound traffic to SSM endpoint
    #tfsec:ignore:aws-ec2-no-public-egress-sgr
    cidr_blocks = ["0.0.0.0/0"]
  }
}


resource "aws_vpc_endpoint" "ec2messages" {
  count               = var.enable_ssm_vpc_endpoints ? 1 : 0
  vpc_id              = aws_vpc.vpc.id
  service_name        = "com.amazonaws.${data.aws_region.current.name}.ec2messages"
  security_group_ids  = [aws_security_group.security_group.id]
  vpc_endpoint_type   = "Interface"
  private_dns_enabled = true
  subnet_ids          = [aws_subnet.private_subnets[*].id[0]]
  tags                = merge(tomap({ Name = var.name }), var.tags)
}

resource "aws_vpc_endpoint" "kms" {
  count               = var.enable_ssm_vpc_endpoints ? 1 : 0
  vpc_id              = aws_vpc.vpc.id
  service_name        = "com.amazonaws.${data.aws_region.current.name}.kms"
  security_group_ids  = [aws_security_group.security_group.id]
  vpc_endpoint_type   = "Interface"
  private_dns_enabled = true
  subnet_ids          = [aws_subnet.private_subnets[*].id[0]]
  tags                = merge(tomap({ Name = var.name }), var.tags)
}

resource "aws_vpc_endpoint" "ssm" {
  count               = var.enable_ssm_vpc_endpoints ? 1 : 0
  vpc_id              = aws_vpc.vpc.id
  service_name        = "com.amazonaws.${data.aws_region.current.name}.ssm"
  security_group_ids  = [aws_security_group.security_group.id]
  vpc_endpoint_type   = "Interface"
  private_dns_enabled = true
  subnet_ids          = [aws_subnet.private_subnets[*].id[0]]
  tags                = merge(tomap({ Name = var.name }), var.tags)
}

resource "aws_vpc_endpoint" "ssm-contacts" {
  count               = var.enable_ssm_vpc_endpoints ? 1 : 0
  vpc_id              = aws_vpc.vpc.id
  service_name        = "com.amazonaws.${data.aws_region.current.name}.ssm-contacts"
  security_group_ids  = [aws_security_group.security_group.id]
  vpc_endpoint_type   = "Interface"
  private_dns_enabled = true
  subnet_ids          = [aws_subnet.private_subnets[*].id[0]]
  tags                = merge(tomap({ Name = var.name }), var.tags)
}

resource "aws_vpc_endpoint" "ssm-incidents" {
  count               = var.enable_ssm_vpc_endpoints ? 1 : 0
  vpc_id              = aws_vpc.vpc.id
  service_name        = "com.amazonaws.${data.aws_region.current.name}.ssm-incidents"
  security_group_ids  = [aws_security_group.security_group.id]
  vpc_endpoint_type   = "Interface"
  private_dns_enabled = true
  subnet_ids          = [aws_subnet.private_subnets[*].id[0]]
  tags                = merge(tomap({ Name = var.name }), var.tags)
}

resource "aws_vpc_endpoint" "ssmmessages" {
  count               = var.enable_ssm_vpc_endpoints ? 1 : 0
  vpc_id              = aws_vpc.vpc.id
  service_name        = "com.amazonaws.${data.aws_region.current.name}.ssmmessages"
  security_group_ids  = [aws_security_group.security_group.id]
  vpc_endpoint_type   = "Interface"
  private_dns_enabled = true
  subnet_ids          = [aws_subnet.private_subnets[*].id[0]]
  tags                = merge(tomap({ Name = var.name }), var.tags)
}

###########################
# Subnets
###########################

resource "aws_subnet" "private_subnets" {
  vpc_id            = aws_vpc.vpc.id
  cidr_block        = var.private_subnets_list[count.index]
  availability_zone = element(var.azs, count.index)
  count             = length(var.private_subnets_list)
  tags              = merge(var.tags, ({ "Name" = format("%s-subnet-private-%s", var.name, element(var.azs, count.index)) }))
}

resource "aws_subnet" "public_subnets" {
  vpc_id            = aws_vpc.vpc.id
  cidr_block        = var.public_subnets_list[count.index]
  availability_zone = element(var.azs, count.index)
  # Allow public IP assignment for public subnets and zone
  #tfsec:ignore:aws-ec2-no-public-ip-subnet
  map_public_ip_on_launch = var.map_public_ip_on_launch
  count                   = length(var.public_subnets_list)
  tags                    = merge(var.tags, ({ "Name" = format("%s-subnet-public-%s", var.name, element(var.azs, count.index)) }))
}

resource "aws_subnet" "dmz_subnets" {
  vpc_id            = aws_vpc.vpc.id
  cidr_block        = var.dmz_subnets_list[count.index]
  availability_zone = element(var.azs, count.index)
  count             = length(var.dmz_subnets_list)
  tags              = merge(var.tags, ({ "Name" = format("%s-subnet-dmz-%s", var.name, element(var.azs, count.index)) }))
}

resource "aws_subnet" "db_subnets" {
  vpc_id            = aws_vpc.vpc.id
  cidr_block        = var.db_subnets_list[count.index]
  availability_zone = element(var.azs, count.index)
  count             = length(var.db_subnets_list)
  tags              = merge(var.tags, ({ "Name" = format("%s-subnet-db-%s", var.name, element(var.azs, count.index)) }))
}

resource "aws_subnet" "mgmt_subnets" {
  vpc_id            = aws_vpc.vpc.id
  cidr_block        = var.mgmt_subnets_list[count.index]
  availability_zone = element(var.azs, count.index)
  count             = length(var.mgmt_subnets_list)
  tags              = merge(var.tags, ({ "Name" = format("%s-subnet-mgmt-%s", var.name, element(var.azs, count.index)) }))
}

resource "aws_subnet" "workspaces_subnets" {
  vpc_id            = aws_vpc.vpc.id
  cidr_block        = var.workspaces_subnets_list[count.index]
  availability_zone = element(var.azs, count.index)
  count             = length(var.workspaces_subnets_list)
  tags              = merge(var.tags, ({ "Name" = format("%s-subnet-workspaces-%s", var.name, element(var.azs, count.index)) }))
}

###########################
# Gateways
###########################

resource "aws_internet_gateway" "igw" {
  tags   = merge(var.tags, ({ "Name" = format("%s-igw", var.name) }))
  vpc_id = aws_vpc.vpc.id
}

resource "aws_route_table" "public_route_table" {
  propagating_vgws = var.public_propagating_vgws
  tags             = merge(var.tags, ({ "Name" = format("%s-rt-public", var.name) }))
  vpc_id           = aws_vpc.vpc.id
}

resource "aws_route" "public_default_route" {
  destination_cidr_block = "0.0.0.0/0"
  gateway_id             = aws_internet_gateway.igw.id
  route_table_id         = aws_route_table.public_route_table.id
}

resource "aws_eip" "nateip" {
  count  = var.enable_nat_gateway ? (var.single_nat_gateway ? 1 : length(var.azs)) : 0
  domain = "vpc"
}

resource "aws_nat_gateway" "natgw" {
  depends_on = [aws_internet_gateway.igw]

  allocation_id = element(aws_eip.nateip[*].id, (var.single_nat_gateway ? 0 : count.index))
  count         = var.enable_nat_gateway ? (var.single_nat_gateway ? 1 : length(var.azs)) : 0
  subnet_id     = element(aws_subnet.public_subnets[*].id, (var.single_nat_gateway ? 0 : count.index))
}

###########################
# Route Tables and Associations
###########################

resource "aws_route_table" "private_route_table" {
  count            = length(var.azs)
  propagating_vgws = var.private_propagating_vgws
  tags             = merge(var.tags, ({ "Name" = format("%s-rt-private-%s", var.name, element(var.azs, count.index)) }))
  vpc_id           = aws_vpc.vpc.id
}

resource "aws_route" "private_default_route_natgw" {
  count                  = var.enable_nat_gateway ? length(var.azs) : 0
  destination_cidr_block = "0.0.0.0/0"
  nat_gateway_id         = element(aws_nat_gateway.natgw[*].id, count.index)
  route_table_id         = element(aws_route_table.private_route_table[*].id, count.index)
}

resource "aws_route" "private_default_route_fw" {
  count                  = var.enable_firewall ? length(var.azs) : 0
  destination_cidr_block = "0.0.0.0/0"
  network_interface_id   = element(var.fw_network_interface_id, count.index)
  route_table_id         = element(aws_route_table.private_route_table[*].id, count.index)
}

resource "aws_route_table" "db_route_table" {
  count            = length(var.azs)
  propagating_vgws = var.db_propagating_vgws
  tags             = merge(var.tags, ({ "Name" = format("%s-rt-db-%s", var.name, element(var.azs, count.index)) }))
  vpc_id           = aws_vpc.vpc.id
}

resource "aws_route" "db_default_route_natgw" {
  count                  = var.enable_nat_gateway ? length(var.azs) : 0
  destination_cidr_block = "0.0.0.0/0"
  nat_gateway_id         = element(aws_nat_gateway.natgw[*].id, count.index)
  route_table_id         = element(aws_route_table.db_route_table[*].id, count.index)
}

resource "aws_route" "db_default_route_fw" {
  count                  = var.enable_firewall ? length(var.azs) : 0
  destination_cidr_block = "0.0.0.0/0"
  network_interface_id   = element(var.fw_network_interface_id, count.index)
  route_table_id         = element(aws_route_table.db_route_table[*].id, count.index)
}

resource "aws_route_table" "dmz_route_table" {
  count            = length(var.azs)
  propagating_vgws = var.dmz_propagating_vgws
  tags             = merge(var.tags, ({ "Name" = format("%s-rt-dmz-%s", var.name, element(var.azs, count.index)) }))
  vpc_id           = aws_vpc.vpc.id
}

resource "aws_route" "dmz_default_route_natgw" {
  count                  = var.enable_nat_gateway ? length(var.azs) : 0
  destination_cidr_block = "0.0.0.0/0"
  nat_gateway_id         = element(aws_nat_gateway.natgw[*].id, count.index)
  route_table_id         = element(aws_route_table.dmz_route_table[*].id, count.index)
}

resource "aws_route" "dmz_default_route_fw" {
  count                  = var.enable_firewall ? length(var.azs) : 0
  destination_cidr_block = "0.0.0.0/0"
  network_interface_id   = element(var.fw_dmz_network_interface_id, count.index)
  route_table_id         = element(aws_route_table.dmz_route_table[*].id, count.index)
}

resource "aws_route_table" "mgmt_route_table" {
  count            = length(var.azs)
  propagating_vgws = var.mgmt_propagating_vgws
  tags             = merge(var.tags, ({ "Name" = format("%s-rt-mgmt-%s", var.name, element(var.azs, count.index)) }))
  vpc_id           = aws_vpc.vpc.id
}

resource "aws_route" "mgmt_default_route_natgw" {
  count                  = var.enable_nat_gateway ? length(var.azs) : 0
  destination_cidr_block = "0.0.0.0/0"
  nat_gateway_id         = element(aws_nat_gateway.natgw[*].id, count.index)
  route_table_id         = element(aws_route_table.mgmt_route_table[*].id, count.index)
}

resource "aws_route" "mgmt_default_route_fw" {
  count                  = var.enable_firewall ? length(var.azs) : 0
  destination_cidr_block = "0.0.0.0/0"
  network_interface_id   = element(var.fw_network_interface_id, count.index)
  route_table_id         = element(aws_route_table.mgmt_route_table[*].id, count.index)
}

resource "aws_route_table" "workspaces_route_table" {
  count            = length(var.azs)
  propagating_vgws = var.workspaces_propagating_vgws
  tags             = merge(var.tags, ({ "Name" = format("%s-rt-workspaces-%s", var.name, element(var.azs, count.index)) }))
  vpc_id           = aws_vpc.vpc.id
}

resource "aws_route" "workspaces_default_route_natgw" {
  count                  = var.enable_nat_gateway ? length(var.azs) : 0
  destination_cidr_block = "0.0.0.0/0"
  nat_gateway_id         = element(aws_nat_gateway.natgw[*].id, count.index)
  route_table_id         = element(aws_route_table.workspaces_route_table[*].id, count.index)
}

resource "aws_route" "workspaces_default_route_fw" {
  count                  = var.enable_firewall ? length(var.azs) : 0
  destination_cidr_block = "0.0.0.0/0"
  network_interface_id   = element(var.fw_network_interface_id, count.index)
  route_table_id         = element(aws_route_table.workspaces_route_table[*].id, count.index)
}

resource "aws_vpc_endpoint" "s3" {
  count        = var.enable_s3_endpoint ? 1 : 0
  vpc_id       = aws_vpc.vpc.id
  service_name = local.service_name
}

resource "aws_vpc_endpoint_route_table_association" "private_s3" {
  count           = var.enable_s3_endpoint ? length(var.private_subnets_list) : 0
  vpc_endpoint_id = aws_vpc_endpoint.s3[count.index]
  route_table_id  = element(aws_route_table.private_route_table[*].id, count.index)
}

resource "aws_vpc_endpoint_route_table_association" "public_s3" {
  count           = var.enable_s3_endpoint ? length(var.public_subnets_list) : 0
  vpc_endpoint_id = aws_vpc_endpoint.s3[count.index]
  route_table_id  = aws_route_table.public_route_table.id
}

resource "aws_route_table_association" "private" {
  count          = length(var.private_subnets_list)
  route_table_id = element(aws_route_table.private_route_table[*].id, count.index)
  subnet_id      = element(aws_subnet.private_subnets[*].id, count.index)
}

resource "aws_route_table_association" "public" {
  count          = length(var.public_subnets_list)
  route_table_id = aws_route_table.public_route_table.id
  subnet_id      = element(aws_subnet.public_subnets[*].id, count.index)
}

resource "aws_route_table_association" "db" {
  count          = length(var.db_subnets_list)
  route_table_id = element(aws_route_table.db_route_table[*].id, count.index)
  subnet_id      = element(aws_subnet.db_subnets[*].id, count.index)
}

resource "aws_route_table_association" "dmz" {
  count          = length(var.dmz_subnets_list)
  route_table_id = element(aws_route_table.dmz_route_table[*].id, count.index)
  subnet_id      = element(aws_subnet.dmz_subnets[*].id, count.index)
}

resource "aws_route_table_association" "workspaces" {
  count          = length(var.workspaces_subnets_list)
  route_table_id = element(aws_route_table.workspaces_route_table[*].id, count.index)
  subnet_id      = element(aws_subnet.workspaces_subnets[*].id, count.index)
}

######################################################
# VPC Flow Logs
######################################################

###########################
# KMS Encryption Key
###########################

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
          "Service" = "logs.${data.aws_region.current.name}.amazonaws.com"
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
            "kms:EncryptionContext:aws:logs:arn" : "arn:aws:logs:${data.aws_region.current.name}:${data.aws_caller_identity.current.account_id}:log-group:*"
          }
        }
      }
    ]
  })
}

resource "aws_kms_alias" "alias" {
  count         = (var.enable_vpc_flow_logs == true ? 1 : 0)
  name_prefix   = var.key_name_prefix
  target_key_id = aws_kms_key.key[0].key_id
}

###########################
# CloudWatch Log Group
###########################

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
resource "aws_iam_policy" "policy" {
  count       = (var.enable_vpc_flow_logs == true ? 1 : 0)
  description = var.iam_policy_description
  name_prefix = var.iam_policy_name_prefix
  path        = var.iam_policy_path
  tags        = var.tags
  #tfsec:ignore:aws-iam-no-policy-wildcards
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

resource "aws_iam_role" "role" {
  count                 = (var.enable_vpc_flow_logs == true ? 1 : 0)
  assume_role_policy    = var.iam_role_assume_role_policy
  description           = var.iam_role_description
  force_detach_policies = var.iam_role_force_detach_policies
  max_session_duration  = var.iam_role_max_session_duration
  name_prefix           = var.iam_role_name_prefix
  permissions_boundary  = var.iam_role_permissions_boundary
}

resource "aws_iam_role_policy_attachment" "role_attach" {
  count      = (var.enable_vpc_flow_logs == true ? 1 : 0)
  role       = aws_iam_role.role[0].name
  policy_arn = aws_iam_policy.policy[0].arn
}


###########################
# VPC Flow Log
###########################

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
