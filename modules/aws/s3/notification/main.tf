
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
