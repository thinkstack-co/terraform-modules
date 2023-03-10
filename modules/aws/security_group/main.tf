terraform {
  required_version = ">= 1.0.0"
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = ">= 4.0.0"
    }
  }
}

resource "aws_security_group" "sg" {
  description = var.description
  name        = var.name
  tags        = merge(var.tags, ({ "Name" = format("%s", var.name) }))
  vpc_id      = var.vpc_id
}
