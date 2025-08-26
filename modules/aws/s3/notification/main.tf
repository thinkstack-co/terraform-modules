terraform {
  required_version = ">= 1.0.0"
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = ">= 4.0.0"
    }
  }
}

resource "aws_s3_bucket_notification" "this" {
  count  = var.enable_s3_bucket_notification ? 1 : 0
  bucket = var.s3_bucket_id

  lambda_function {
    lambda_function_arn = var.lambda_function_arn
    events              = var.lambda_function_events
    filter_prefix       = var.lambda_function_filter_prefix
    filter_suffix       = var.lambda_function_filter_suffix
  }
  depends_on = [aws_lambda_permission.allow_s3]
}

resource "aws_lambda_permission" "allow_s3" {
  count         = var.enable_s3_bucket_notification ? 1 : 0
  statement_id  = var.lambda_permission_statement_id
  action        = "lambda:InvokeFunction"
  function_name = var.lambda_function_arn
  principal     = "s3.amazonaws.com"
  source_arn    = var.s3_bucket_arn
}
