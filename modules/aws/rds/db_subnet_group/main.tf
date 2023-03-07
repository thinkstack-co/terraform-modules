terraform {
  required_version = ">= 1.0.0"
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = ">= 4.0.0"
    }
  }
}

resource "aws_db_subnet_group" "group" {
  description = var.description
  name        = var.name
  subnet_ids  = var.subnet_ids
  tags        = var.tags
}
