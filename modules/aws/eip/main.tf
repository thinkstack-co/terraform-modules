terraform {
  required_version = ">= 1.0.0"
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = ">= 4.0.0"
    }
  }
}

#############
# EIP Module
#############

resource "aws_eip" "eip" {
  associate_with_private_ip = var.associate_with_private_ip
  instance                  = var.instance
  network_interface         = var.network_interface
  tags                      = var.tags
  vpc                       = var.vpc
}
