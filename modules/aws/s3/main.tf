terraform {
  required_version = ">= 1.0.0"
}

resource "aws_s3_bucket" "this" {
  bucket_prefix = var.bucket_prefix
  tags          = var.tags
}

resource "aws_s3_bucket_public_access_block" "this" {
  bucket                  = aws_s3_bucket.this.id
  block_public_acls       = var.block_public_acls
  block_public_policy     = var.block_public_policy
  ignore_public_acls      = var.ignore_public_acls
  restrict_public_buckets = var.restrict_public_buckets
}

resource "aws_s3_bucket_lifecycle_configuration" "rule" {
  count  = var.enable_lifecycle_rule == true ? 1 : 0
  bucket = aws_s3_bucket.this.id

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

resource "aws_s3_bucket_versioning" "this" {
  bucket = aws_s3_bucket.this.id
  versioning_configuration {
    status     = var.versioning_status
    mfa_delete = var.mfa_delete
  }
}

resource "aws_s3_bucket_server_side_encryption_configuration" "this" {
  bucket = aws_s3_bucket.this.bucket

  rule {
    bucket_key_enabled = var.bucket_key_enabled
    apply_server_side_encryption_by_default {
      kms_master_key_id = aws_kms_key.bucket.arn
      sse_algorithm     = var.sse_algorithm
    }
  }
}

resource "aws_s3_bucket_policy" "this" {
  bucket = aws_s3_bucket.this.id
  policy = var.policy
}

resource "aws_s3_bucket_notification" "this" {
  count  = var.enable_s3_bucket_notification ? 1 : 0
  bucket = aws_s3_bucket.this.id

  lambda_function {
    lambda_function_arn = var.lambda_function_arn
    events              = var.lambda_function_events
    filter_prefix       = var.lambda_function_filter_prefix
    filter_suffix       = var.lambda_function_filter_suffix
  }
}

resource "aws_s3_bucket_logging" "this" {
  count         = var.enable_s3_bucket_logging ? 1 : 0
  bucket        = aws_s3_bucket.this.id
  target_bucket = var.target_bucket
  target_prefix = var.target_prefix
}
