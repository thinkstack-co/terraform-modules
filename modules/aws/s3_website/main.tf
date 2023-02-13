terraform {
  required_version = ">= 0.12.0"
}

resource "aws_s3_bucket" "this" {
  bucket_prefix = var.bucket_prefix
  policy        = var.policy
  tags          = var.tags

}

resource "aws_s3_bucket_website_configuration" "this" {
  bucket = aws_s3_bucket.this.bucket

  index_document {
    suffix = var.index_document
  }

  error_document {
    key = var.error_document
  }
}
