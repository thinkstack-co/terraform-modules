terraform {
  required_version = ">= 1.3.0"
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = ">= 4.0.0"
    }
  }
}

###########################
# Direct Connect Connection
###########################

resource "aws_dx_connection" "dxc" {
  name      = var.name
  bandwidth = var.bandwidth
  location  = var.location
  tags      = var.tags
}
