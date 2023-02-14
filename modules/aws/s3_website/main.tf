terraform {
  required_version = ">= 0.12.0"
}

resource "aws_s3_bucket" "this" {
  bucket        = var.bucket
  tags          = var.tags

}

resource "aws_s3_bucket_policy" "public_website_access" {
  bucket = aws_s3_bucket.this.id
  policy = var.policy
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
