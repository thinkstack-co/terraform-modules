terraform {
  required_version = ">= 1.0.0"

  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = ">= 4.0.0"
    }
  }
}

###########################
# KMS Encryption Key
###########################

resource "aws_kms_key" "s3" {
  count                    = var.enable_kms_key ? 1 : 0
  customer_master_key_spec = var.key_customer_master_key_spec
  description              = var.key_description
  deletion_window_in_days  = var.key_deletion_window_in_days
  enable_key_rotation      = var.key_enable_key_rotation
  key_usage                = var.key_usage
  is_enabled               = var.key_is_enabled
  policy                   = var.key_policy
  tags                     = var.tags
}

resource "aws_kms_alias" "s3" {
  count         = var.enable_kms_key ? 1 : 0
  name_prefix   = var.key_name_prefix
  target_key_id = aws_kms_key.s3[0].key_id
}

###########################
# S3 Bucket
###########################

resource "aws_s3_bucket" "this" {
  bucket_prefix       = var.bucket_prefix
  force_destroy       = var.bucket_force_destroy
  object_lock_enabled = var.bucket_object_lock_enabled
  tags                = var.tags
}

resource "aws_s3_bucket_intelligent_tiering_configuration" "this" {
  count  = var.enable_intelligent_tiering ? 1 : 0
  bucket = aws_s3_bucket.this.id
  name   = var.intelligent_tiering_name
  status = var.intelligent_tiering_status

  dynamic "filter" {
    for_each = var.intelligent_tiering_filter == null ? [] : [var.intelligent_tiering_filter]
    content {
      prefix = try(filter.value.prefix, null)
      tags   = try(filter.value.tags, null)
    }
  }

  tiering {
    access_tier = var.intelligent_tiering_access_tier
    days        = var.intelligent_tiering_days
  }
}

resource "aws_s3_bucket_lifecycle_configuration" "this" {
  count                 = var.lifecycle_rules == null ? 0 : 1
  bucket                = aws_s3_bucket.this.id
  expected_bucket_owner = var.expected_bucket_owner

  dynamic "rule" {
    for_each = var.lifecycle_rules
    content {
      id     = rule.value.id
      status = rule.value.status

      dynamic "abort_incomplete_multipart_upload" {
        for_each = try(flatten([rule.value.abort_incomplete_multipart_upload]), [])
        content {
          days_after_initiation = try(abort_incomplete_multipart_upload.value.days_after_initiation, null)
        }
      }

      dynamic "expiration" {
        for_each = try(flatten([rule.value.expiration]), [])
        content {
          date                         = try(expiration.value.date, null)
          days                         = try(expiration.value.days, null)
          expired_object_delete_marker = try(expiration.value.expired_object_delete_marker, null)
        }
      }

      dynamic "filter" {
        for_each = try(flatten([rule.value.filter]), [])
        content {
          object_size_greater_than = try(filter.value.object_size_greater_than, null)
          object_size_less_than    = try(filter.value.object_size_less_than, null)
          prefix                   = try(filter.value.prefix, null)
          dynamic "tag" {
            for_each = try(rule.value.filter.tag, [])
            content {
              key   = tag.value.key
              value = tag.value.value
            }
          }
        }
      }

      dynamic "noncurrent_version_expiration" {
        for_each = try(flatten([rule.value.noncurrent_version_expiration]), [])
        content {
          newer_noncurrent_versions = try(noncurrent_version_expiration.value.newer_noncurrent_versions, null)
          noncurrent_days           = try(noncurrent_version_expiration.value.noncurrent_days, null)
        }
      }

      dynamic "noncurrent_version_transition" {
        for_each = try(rule.value.noncurrent_version_transition, [])
        content {
          newer_noncurrent_versions = try(noncurrent_version_transition.value.newer_noncurrent_versions, null)
          noncurrent_days           = try(noncurrent_version_transition.value.noncurrent_days, null)
          storage_class             = try(noncurrent_version_transition.value.storage_class, null)
        }
      }

      dynamic "transition" {
        for_each = try(rule.value.transition, [])
        content {
          date          = try(transition.value.date, null)
          days          = try(transition.value.days, null)
          storage_class = try(transition.value.storage_class, null)
        }
      }
    }
  }
}

resource "aws_s3_bucket_logging" "this" {
  count         = var.enable_s3_bucket_logging ? 1 : 0
  bucket        = aws_s3_bucket.this.id
  target_bucket = var.logging_target_bucket
  target_prefix = var.logging_target_prefix
}

resource "aws_s3_bucket_policy" "this" {
  count  = var.bucket_policy == null ? 0 : 1
  bucket = aws_s3_bucket.this.id
  policy = var.bucket_policy
}

resource "aws_s3_bucket_public_access_block" "this" {
  bucket                  = aws_s3_bucket.this.id
  block_public_acls       = var.block_public_acls
  block_public_policy     = var.block_public_policy
  ignore_public_acls      = var.ignore_public_acls
  restrict_public_buckets = var.restrict_public_buckets
}

resource "aws_s3_bucket_server_side_encryption_configuration" "this" {
  bucket                = aws_s3_bucket.this.bucket
  expected_bucket_owner = var.expected_bucket_owner

  rule {
    bucket_key_enabled = var.bucket_key_enabled
    apply_server_side_encryption_by_default {
      kms_master_key_id = var.enable_kms_key ? aws_kms_key.s3[0].arn : null
      sse_algorithm     = var.sse_algorithm
    }
  }
}

resource "aws_s3_bucket_versioning" "this" {
  count                 = var.versioning_status == "Enabled" ? 1 : 0
  bucket                = aws_s3_bucket.this.id
  expected_bucket_owner = var.expected_bucket_owner
  versioning_configuration {
    status     = var.versioning_status
    mfa_delete = var.mfa_delete
  }
}
