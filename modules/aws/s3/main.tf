terraform {
  required_version = ">= 0.13.0"
}

resource "aws_s3_bucket" "s3_bucket" {
  acl           = var.acl
  bucket_prefix = var.bucket_prefix
  policy        = var.policy

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
}

resource "aws_s3_bucket_lifecycle_configuration" "rule" {
  count  = var.enable_lifecycle_rule == true ? 1 : 0
  bucket = aws_s3_bucket.s3_bucket.id

  rule {
    id     = var.lifecycle_rule_id
    status = var.lifecycle_rule_enabled
    prefix = var.lifecycle_rule_prefix

    filter {}
    expiration {
      days = var.lifecycle_expiration_days
    }
  }
}


