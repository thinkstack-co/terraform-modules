terraform {
  required_version = ">= 0.12.0"
}

resource "aws_db_parameter_group" "group" {
  description = var.description
  family      = var.family
  name        = var.name
  tags        = var.tags
}
