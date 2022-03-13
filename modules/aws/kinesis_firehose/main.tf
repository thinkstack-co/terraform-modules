terraform {
  required_version = ">= 0.15.0"
}

#################################
# Kinesis Firehose
#################################

resource "aws_kinesis_firehose_delivery_stream" "extended_s3_stream" {
  name        = var.firehose_name
  destination = var.firehose_destination
  tags        = var.tags

  server_side_encryption {
      enabled  = var.firehose_server_side_encryption_enabled
      key_type = var.firehose_key_type
      key_arn  = var.firehose_key_arn
  }

  extended_s3_configuration {
    role_arn            = aws_iam_role.firehose_role.arn
    bucket_arn          = aws_s3_bucket.firehose_bucket.arn
    prefix              = var.firehose_prefix
    buffer_size         = var.firehose_buffer_size
    buffer_interval     = var.firehose_buffer_interval
    compression_format  = var.firehose_compression_format
    error_output_prefix = var.firehose_error_output_prefix
    kms_key_arn         = var.firehose_kms_key_arn
  }
}

#################################
# S3
#################################

resource "aws_s3_bucket" "firehose_bucket" {
  acl           = var.s3_acl
  bucket_prefix = var.s3_bucket_prefix
  policy        = var.s3_policy
  tags          = var.tags

  lifecycle_rule {
      id      = var.s3_lifecycle_id
      prefix  = var.s3_lifecycle_prefix
      enabled = var.s3_lifecycle_enabled
    
    expiration {
      days = var.s3_lifecycle_expiration_days
    }
  }
}

###########################
# IAM Policy
###########################
resource "aws_iam_policy" "firehose_policy" {
  description = var.iam_policy_description
  name_prefix = var.iam_policy_name_prefix
  path        = var.iam_policy_path
  tags        = var.tags
  policy      = jsonencode({
    Version = "2012-10-17",
    Statement = [{
        Effect = "Allow",
        Action = [
            "s3:AbortMultipartUpload",
            "s3:GetBucketLocation",
            "s3:GetObject",
            "s3:ListBucket",
            "s3:ListBucketMultipartUploads",
            "s3:PutObject"
        ],
        Resource = [
            "${aws_s3_bucket.firehose_bucket.arn}",
            "${aws_s3_bucket.firehose_bucket.arn}/*"
        ]
        }]
    })
}

###########################
# IAM Role
###########################

resource "aws_iam_role" "firehose_role" {
  assume_role_policy    = var.iam_role_assume_role_policy
  description           = var.iam_role_description
  force_detach_policies = var.iam_role_force_detach_policies
  max_session_duration  = var.iam_role_max_session_duration
  name_prefix           = var.iam_role_name_prefix
  permissions_boundary  = var.iam_role_permissions_boundary
}

resource "aws_iam_role_policy_attachment" "role_attach" {
  role       = aws_iam_role.firehose_role.name
  policy_arn = aws_iam_policy.firehose_policy.arn
}