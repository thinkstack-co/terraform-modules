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
