terraform {
  required_version = ">= 0.12.0"
}

resource "aws_s3_bucket" "s3_bucket" {
    acl             = var.acl
    bucket_prefix   = var.bucket_prefix
    policy          = var.policy
    region          = var.region

    /*logging {
        target_bucket = var.target_bucket
        target_prefix = var.target_prefix
    }*/

    lifecycle_rule {
    id      = var.id
    enabled = var.lifecycle_enabled

    prefix = var.prefix

    tags = var.tags

    transition {
      days          = var.days
      storage_class = var.storage_class # or "ONEZONE_IA"
    }

    transition {
      days          = var.days
      storage_class = var.storage_class
    }

    expiration {
      days = var.days
    }
  }

    versioning {
        enabled     = var.versioning
        mfa_delete  = var.mfa_delete
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

    tags            = var.tags
}
