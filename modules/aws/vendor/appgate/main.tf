###############################################################################
# Appgate SDP AWS Gateway Module
#
# Deploys a complete Appgate SDP ZTNA gateway into a customer's existing
# AWS environment in a single module call. Covers the full Netcov
# "Appgate - AWS Gateway(s) Setup & Configuration" runbook.
#
# Call from: terraform-modules/customers/<client>/appgate.tf
# Stored at: terraform-modules/modules/aws/vendor/appgate-gateway/
###############################################################################

terraform {
  required_version = ">= 1.5.0"

  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = ">= 5.0"
    }
    appgatesdp = {
      source  = "appgate/appgatesdp"
      version = ">= 2.0"
    }
  }
}

###############################################################################
# Data Sources
###############################################################################

data "aws_region" "current" {}

data "aws_subnet" "this" {
  id = var.subnet_id
}

data "aws_ami" "appgate" {
  count       = var.ami_id == null ? 1 : 0
  most_recent = true
  owners      = ["aws-marketplace"]

  filter {
    name   = "name"
    values = ["Appgate SDP*BYOL*"]
  }

  filter {
    name   = "architecture"
    values = ["x86_64"]
  }

  filter {
    name   = "state"
    values = ["available"]
  }
}

###############################################################################
# Locals — Naming Conventions
###############################################################################

locals {
  region_short = replace(
    replace(
      replace(data.aws_region.current.name, "north", "n"),
      "south", "s"
    ),
    "/([a-z]{2})-([a-z])[a-z]*-([0-9])/", "$1$2$3"
  )

  az_short = replace(
    data.aws_subnet.this.availability_zone,
    data.aws_region.current.name,
    local.region_short
  )

  c  = lower(var.client_abbreviation)
  gw = format("%02d", var.gateway_index)
  sn = format("%02d", var.subnet_index)

  sg_name       = "${local.c}-${local.region_short}-${var.vpc_identifier}-appgate-sg${local.gw}"
  eni_name      = "${local.c}-${local.az_short}-pub-sn${local.sn}-aggw${local.gw}-eni${local.gw}"
  eip_name      = "${local.c}-${local.region_short}-aggw${local.gw}-eip${local.gw}"
  instance_name = "${upper(var.client_abbreviation)}-AGGW${local.gw}"
  volume_name   = "${local.c}-${local.az_short}-aggw-vol${local.gw}"

  ami_id = var.ami_id != null ? var.ami_id : data.aws_ami.appgate[0].id

  tags = merge(
    {
      "map-migrated" = var.map_migrated_value
      "ManagedBy"    = "Terraform"
      "Project"      = "Appgate-ZTNA"
      "Client"       = var.client_abbreviation
    },
    var.additional_tags
  )
}

###############################################################################
# 1. Security Group  (Runbook Steps 4–7)
#
#    Inbound rules:
#      - 443 TCP  (0.0.0.0/0)  — SDP client TLS + control plane
#      - 443 UDP  (0.0.0.0/0)  — SDP client DTLS data tunnel
#      - 53  UDP  (0.0.0.0/0)  — SDP client DNS resolution
#      - 22  TCP  (NetCov IP)  — SSH management
#      - 8443 TCP (NetCov IP)  — Appgate admin console
#      - 22 + 8443 (additional engineer IPs)
#    Outbound: all
###############################################################################

resource "aws_security_group" "this" {
  name        = local.sg_name
  description = "Appgate Gateway Security Group"
  vpc_id      = var.vpc_id

  tags = merge(local.tags, { Name = local.sg_name })
}

resource "aws_vpc_security_group_ingress_rule" "https" {
  security_group_id = aws_security_group.this.id
  description       = "Appgate 443 TCP Access"
  ip_protocol       = "tcp"
  from_port         = 443
  to_port           = 443
  cidr_ipv4         = "0.0.0.0/0"
}

resource "aws_vpc_security_group_ingress_rule" "dtls" {
  security_group_id = aws_security_group.this.id
  description       = "Appgate 443 UDP Access"
  ip_protocol       = "udp"
  from_port         = 443
  to_port           = 443
  cidr_ipv4         = "0.0.0.0/0"
}

resource "aws_vpc_security_group_ingress_rule" "dns" {
  security_group_id = aws_security_group.this.id
  description       = "Appgate 53 UDP SDP Client Access"
  ip_protocol       = "udp"
  from_port         = 53
  to_port           = 53
  cidr_ipv4         = "0.0.0.0/0"
}

resource "aws_vpc_security_group_ingress_rule" "ssh_netcov" {
  security_group_id = aws_security_group.this.id
  description       = "SSH NetCov Appgate IP Access"
  ip_protocol       = "tcp"
  from_port         = 22
  to_port           = 22
  cidr_ipv4         = "${var.netcov_appgate_ip}/32"
}

resource "aws_vpc_security_group_ingress_rule" "admin_netcov" {
  security_group_id = aws_security_group.this.id
  description       = "Admin NetCov Appgate IP Access"
  ip_protocol       = "tcp"
  from_port         = 8443
  to_port           = 8443
  cidr_ipv4         = "${var.netcov_appgate_ip}/32"
}

resource "aws_vpc_security_group_ingress_rule" "ssh_engineer" {
  for_each          = var.additional_admin_cidrs
  security_group_id = aws_security_group.this.id
  description       = "SSH Access - ${each.key}"
  ip_protocol       = "tcp"
  from_port         = 22
  to_port           = 22
  cidr_ipv4         = each.value
}

resource "aws_vpc_security_group_ingress_rule" "admin_engineer" {
  for_each          = var.additional_admin_cidrs
  security_group_id = aws_security_group.this.id
  description       = "Admin 8443 Access - ${each.key}"
  ip_protocol       = "tcp"
  from_port         = 8443
  to_port           = 8443
  cidr_ipv4         = each.value
}

resource "aws_vpc_security_group_egress_rule" "all" {
  security_group_id = aws_security_group.this.id
  description       = "Allow all outbound"
  ip_protocol       = "-1"
  cidr_ipv4         = "0.0.0.0/0"
}

###############################################################################
# 2. Network Interface  (Runbook Steps 22–26)
###############################################################################

resource "aws_network_interface" "this" {
  subnet_id       = var.subnet_id
  description     = "${local.instance_name} network interface"
  security_groups = [aws_security_group.this.id]

  tags = merge(local.tags, { Name = local.eni_name })
}

###############################################################################
# 3. Elastic IP  (Runbook Steps 27–31)
###############################################################################

resource "aws_eip" "this" {
  domain = "vpc"
  tags   = merge(local.tags, { Name = local.eip_name })
}

resource "aws_eip_association" "this" {
  allocation_id        = aws_eip.this.id
  network_interface_id = aws_network_interface.this.id
}

###############################################################################
# 4. EC2 Instance  (Runbook Steps 33–45)
#
#    - Appgate SDP BYOL AMI (auto-discovered or explicit)
#    - Existing key pair from customer environment
#    - 100 GiB gp3 encrypted root volume
#    - Attached to pre-created ENI (carries SG + EIP)
###############################################################################

resource "aws_instance" "this" {
  ami                    = local.ami_id
  instance_type          = var.instance_type
  key_name               = var.key_pair_name
  subnet_id              = var.subnet_id
  vpc_security_group_ids = [aws_security_group.this.id]

  root_block_device {
    volume_size           = var.root_volume_size
    volume_type           = "gp3"
    iops                  = var.root_volume_iops
    throughput            = var.root_volume_throughput
    encrypted             = true
    kms_key_id            = var.kms_key_id
    delete_on_termination = true
    tags                  = merge(local.tags, { Name = local.volume_name })
  }

  metadata_options {
    http_endpoint               = "enabled"
    http_tokens                 = "required"
    http_put_response_hop_limit = 2
  }

  tags        = merge(local.tags, { Name = local.instance_name })
  volume_tags = merge(local.tags, { Name = local.volume_name })

  lifecycle {
    ignore_changes = [ami]
  }
}

###############################################################################
# 4b. Attach ENI to Instance
#
#    Uses a dedicated attachment resource instead of the deprecated inline
#    network_interface block on aws_instance.
###############################################################################

resource "aws_network_interface_attachment" "this" {
  instance_id          = aws_instance.this.id
  network_interface_id = aws_network_interface.this.id
  device_index         = 1
}

###############################################################################
# 5. Appgate SDP — Appliance Registration  (Runbook Steps 48–54)
#
#    Creates the gateway entry in the Appgate controller, assigns it to
#    the customer site, and configures which subnets are reachable through
#    the client tunnel.
###############################################################################

resource "appgatesdp_appliance" "this" {
  count = var.manage_appgate_appliance ? 1 : 0

  name     = "${var.customer_name} - ${local.instance_name}"
  notes    = "${var.customer_name} Gateway (AWS)"
  hostname = aws_eip.this.public_ip

  client_interface {
    hostname   = aws_eip.this.public_ip
    https_port = 443
    dtls_port  = 443

    allow_sources {
      address = "0.0.0.0"
      netmask = 0
      nic     = "eth0"
    }
  }

  networking {
    nics {
      enabled = true
      name    = "eth0"

      ipv4 {
        dhcp {
          enabled = true
          dns     = true
          routers = true
          ntp     = true
        }
      }
    }
  }

  gateway {
    enabled = true

    vpn {
      weight = 100

      dynamic "allow_destinations" {
        for_each = var.tunnel_destinations
        content {
          address = allow_destinations.value.address
          netmask = allow_destinations.value.netmask
          nic     = "eth0"
        }
      }
    }
  }

  site = var.appgate_site_id
  tags = var.appgate_tags

  lifecycle {
    ignore_changes = [seed]
  }
}

###############################################################################
# 6. Seed Provisioning via SSH  (Runbook Steps 55–65)
#
#    SSHs into the appliance as 'cz', writes the seed.json file.
#    The Appgate appliance auto-detects and processes it, transitioning
#    from Inactive → Active in the controller (~2 min).
#
#    Only runs if both appgate_seed_json and private_key_pem are provided.
###############################################################################

resource "terraform_data" "seed" {
  count = var.manage_appgate_appliance && var.appgate_seed_json != null && var.private_key_pem != null ? 1 : 0

  triggers_replace = [
    aws_instance.this.id,
    md5(var.appgate_seed_json)
  ]

  provisioner "remote-exec" {
    connection {
      type        = "ssh"
      user        = "cz"
      private_key = var.private_key_pem
      host        = aws_eip.this.public_ip
      timeout     = "10m"
    }

    inline = [
      "echo '${base64encode(var.appgate_seed_json)}' | base64 -d > /home/cz/seed.json",
      "echo 'Seed file written — appliance will process automatically.'",
      "sleep 10"
    ]
  }

  depends_on = [
    aws_instance.this,
    aws_eip_association.this
  ]
}
