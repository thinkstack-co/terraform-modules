terraform {
  required_version = ">= 1.0.0"
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = ">= 4.0.0"
    }
  }
}

resource "aws_route53_zone" "zone" {
  comment           = var.comment
  delegation_set_id = var.delegation_set_id
  name              = var.name
  tags              = var.tags
}
