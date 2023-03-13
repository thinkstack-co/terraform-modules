terraform {
  required_version = ">= 1.0.0"
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = ">= 4.0.0"
    }
  }
}

resource "aws_directory_service_directory" "microsoftad" {
  alias       = var.alias
  description = var.description
  edition     = var.edition
  enable_sso  = var.enable_sso
  name        = var.name
  password    = var.password
  short_name  = var.short_name
  size        = var.size
  tags        = var.tags
  type        = var.type

  vpc_settings {
    subnet_ids = var.subnet_ids
    vpc_id     = var.vpc_id
  }
}
