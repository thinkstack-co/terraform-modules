terraform {
  required_version = ">= 1.0.0"
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = ">= 4.0.0"
    }
  }
}

resource "aws_key_pair" "deployer_key" {
  key_name_prefix = var.key_name_prefix
  public_key      = var.public_key
}
