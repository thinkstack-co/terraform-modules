terraform {
  required_version = ">= 1.0.0"
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = ">= 4.0.0"
    }
  }
}

resource "aws_s3_bucket" "s3_bucket" {
  acl    = var.acl
  bucket = var.bucket
  policy = var.policy

  /*logging {
        target_bucket = var.target_bucket
        target_prefix = var.target_prefix
    }*/

  versioning {
    enabled    = var.versioning
    mfa_delete = var.mfa_delete
  }

  lifecycle {
    prevent_destroy = true
  }

  tags = var.tags
}