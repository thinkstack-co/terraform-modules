terraform {
  required_version = ">= 1.0.0"
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = ">= 4.0.0"
    }
  }
}

resource "aws_rds_cluster_parameter_group" "group" {
  description = var.description
  family      = var.family
  name        = var.name
  tags        = var.tags
}
