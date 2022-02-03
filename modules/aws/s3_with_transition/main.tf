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

resource "aws_s3control_bucket_lifecycle_configuration" "lifecycle_expiration" {
  bucket = aws_s3control_bucket.example.arn
  status = var.lifecycle_expiration_status

  dynamic "expiration" {
    for_each = var.lifecycle_expiration_status ? [1] : []
    rule {
      expiration {
        days = var.expiration
        date = var.deletion_date
        expired_object_delete_marker = var.expired_object_delete_marker
      }

      filter {
        prefix = var.filter_prefix
        tags   = var.filter_tags
      }

      id = var.id
    }
  }
}

resource "aws_s3control_bucket_lifecycle_configuration" "lifecycle_transition" {
  bucket = aws_s3control_bucket.example.arn

  lifecycle_rule {
    id      = "transition-to-infrequent-access-storage"
    enabled = var.lifecycle_infrequent_storage_transition_enabled
    prefix  = var.lifecycle_infrequent_storage_object_prefix
    transition {
      days          = var.lifecycle_days_to_infrequent_storage_transition
      storage_class = "STANDARD_IA"
    }
  }

  lifecycle_rule {
    id      = "transition-to-glacier"
    enabled = var.lifecycle_glacier_transition_enabled
    prefix  = var.lifecycle_glacier_object_prefix
    transition {
      days          = var.lifecycle_days_to_glacier_transition
      storage_class = "GLACIER"
    }
  }

  lifecycle_rule {
    id      = "transition-to-deep-archive"
    enabled = var.lifecycle_deep_archive_transition_enabled
    prefix  = var.lifecycle_deep_archive_object_prefix
    transition {
      days          = var.lifecycle_days_to_deep_archive_transition
      storage_class = "DEEP_ARCHIVE"
    }
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
}