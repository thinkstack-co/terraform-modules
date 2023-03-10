terraform {
  required_version = ">= 1.0.0"
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = ">= 4.0.0"
    }
  }
}

resource "aws_vpc_peering_connection_accepter" "peer" {
  auto_accept               = var.auto_accept
  tags                      = var.tags
  vpc_peering_connection_id = var.vpc_peering_connection_id
}