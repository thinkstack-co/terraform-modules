terraform {
  required_version = ">= 1.0.0"
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = ">= 4.0.0"
    }
  }
}

resource "aws_vpn_connection_route" "vpn_route" {
  #count                   = length(var.vpn_connection_id)
  destination_cidr_block = var.vpn_route_cidr_block
  vpn_connection_id      = var.vpn_connection_id
}
