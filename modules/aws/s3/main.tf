terraform {
  required_version = ">= 0.12.0"
}

resource "aws_s3_bucket" "s3_bucket" {
  acl           = var.acl
  bucket_prefix = var.bucket_prefix
  policy        = var.policy

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
  server_side_encryption_configuration {
    rule {
      apply_server_side_encryption_by_default {
        kms_master_key_id = var.kms_master_key_id
        sse_algorithm     = var.sse_algorithm
      }
    }
  }

  tags = var.tags
}
