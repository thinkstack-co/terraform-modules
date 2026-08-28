terraform {
  required_version = ">= 1.0.0"
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = ">= 4.0.0, < 7.0.0"
    }
  }
}

# Purpose:    AWS Directory Service Simple AD directory.
# References: var.subnet_ids, var.vpc_id
resource "aws_directory_service_directory" "simple_ad" {
  alias       = var.alias
  description = var.description
  name        = var.name
  password    = var.password
  size        = var.size
  tags        = var.tags
  type        = var.type

  vpc_settings {
    subnet_ids = var.subnet_ids
    vpc_id     = var.vpc_id
  }
}
