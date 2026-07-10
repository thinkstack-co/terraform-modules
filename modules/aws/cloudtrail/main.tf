terraform {
  required_version = ">= 1.0.0"
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = ">= 4.0.0, < 7.0.0"
    }
  }
}

###########################
# Data Sources
###########################
data "aws_caller_identity" "current" {}
data "aws_region" "current" {}

###########################
# KMS Encryption Key
###########################

resource "aws_kms_key" "cloudtrail" {
  customer_master_key_spec = var.key_customer_master_key_spec
  description              = var.key_description
  deletion_window_in_days  = var.key_deletion_window_in_days
  enable_key_rotation      = var.key_enable_key_rotation
  key_usage                = var.key_usage
  is_enabled               = var.key_is_enabled
  tags                     = var.tags
  policy = jsonencode({
    "Version" = "2012-10-17",
    "Statement" = concat([
      {
        "Sid"    = "Enable IAM User Permissions",
        "Effect" = "Allow",
        "Principal" = {
          "AWS" = "arn:aws:iam::${data.aws_caller_identity.current.account_id}:root"
        },
        "Action"   = "kms:*",
        "Resource" = "*"
      },
      {
        "Sid"    = "Allow CloudTrail to encrypt logs",
        "Effect" = "Allow",
        "Principal" = {
          "Service" = "cloudtrail.amazonaws.com"
        },
        "Action" = [
          "kms:Encrypt*",
          "kms:Decrypt*",
          "kms:ReEncrypt*",
          "kms:GenerateDataKey*",
          "kms:Describe*"
        ],
        "Resource" = "*",
        "Condition" = {
          "StringLike" = {
            "kms:EncryptionContext:aws:cloudtrail:arn" : [
              "arn:aws:cloudtrail:*:${data.aws_caller_identity.current.account_id}:trail/*"
            ]
          },
          "StringEquals" = {
            "aws:SourceArn" = "arn:aws:cloudtrail:${data.aws_region.current.region}:${data.aws_caller_identity.current.account_id}:trail/${var.name}"
          }
        }
      }
      ], var.enable_cloudwatch_logs ? [
      {
        "Sid"    = "Allow CloudWatch Logs to encrypt logs",
        "Effect" = "Allow",
        "Principal" = {
          "Service" = "logs.${data.aws_region.current.region}.amazonaws.com"
        },
        "Action" = [
          "kms:Encrypt*",
          "kms:Decrypt*",
          "kms:ReEncrypt*",
          "kms:GenerateDataKey*",
          "kms:Describe*"
        ],
        "Resource" = "*",
        "Condition" = {
          "ArnEquals" = {
            "kms:EncryptionContext:aws:logs:arn" : "arn:aws:logs:${data.aws_region.current.region}:${data.aws_caller_identity.current.account_id}:log-group:*"
          }
        }
      }
    ] : [])
  })
}

resource "aws_kms_alias" "cloudtrail" {
  name_prefix   = var.key_name_prefix
  target_key_id = aws_kms_key.cloudtrail.key_id
}

###########################
# CloudWatch Log Group
###########################

# Purpose:       Log group CloudTrail streams events into for near-real-time
#                metric filters / alarms (the S3 trail is the archive). Gated by
#                var.enable_cloudwatch_logs.
# Referenced by: aws_iam_policy.cloudtrail, aws_cloudtrail.cloudtrail
# References:    aws_kms_key.cloudtrail
resource "aws_cloudwatch_log_group" "cloudtrail" {
  count             = var.enable_cloudwatch_logs ? 1 : 0
  kms_key_id        = aws_kms_key.cloudtrail.arn
  name_prefix       = var.cloudwatch_name_prefix
  retention_in_days = var.cloudwatch_retention_in_days
  tags              = var.tags
}

############################
# IAM Policy
############################
# Purpose:       Grants the CloudTrail role permission to write to the log group.
# Referenced by: aws_iam_role_policy_attachment.role_attach
# References:    aws_cloudwatch_log_group.cloudtrail
resource "aws_iam_policy" "cloudtrail" {
  count       = var.enable_cloudwatch_logs ? 1 : 0
  description = var.iam_policy_description
  name_prefix = var.iam_policy_name_prefix
  path        = var.iam_policy_path
  tags        = var.tags
  #tfsec:ignore:aws-iam-no-policy-wildcards
  policy = jsonencode({
    Version = "2012-10-17",
    Statement = [{
      Sid    = "AllowCloudTrailToWriteLogs"
      Effect = "Allow",
      Action = [
        "logs:CreateLogStream",
        "logs:PutLogEvents",
        "logs:DescribeLogGroups",
        "logs:DescribeLogStreams"
      ],
      Resource = [
        "${aws_cloudwatch_log_group.cloudtrail[0].arn}",
        "${aws_cloudwatch_log_group.cloudtrail[0].arn}:log-stream:*"
      ]
    }]
  })
}

###########################
# IAM Role
###########################

# Purpose:       Role CloudTrail assumes to write to the CloudWatch log group.
# Referenced by: aws_iam_role_policy_attachment.role_attach, aws_cloudtrail.cloudtrail
resource "aws_iam_role" "cloudtrail" {
  count                 = var.enable_cloudwatch_logs ? 1 : 0
  assume_role_policy    = var.iam_role_assume_role_policy
  description           = var.iam_role_description
  force_detach_policies = var.iam_role_force_detach_policies
  max_session_duration  = var.iam_role_max_session_duration
  name_prefix           = var.iam_role_name_prefix
  permissions_boundary  = var.iam_role_permissions_boundary
}

# Purpose:       Binds the write policy to the CloudTrail role.
# References:    aws_iam_role.cloudtrail, aws_iam_policy.cloudtrail
resource "aws_iam_role_policy_attachment" "role_attach" {
  count      = var.enable_cloudwatch_logs ? 1 : 0
  role       = aws_iam_role.cloudtrail[0].name
  policy_arn = aws_iam_policy.cloudtrail[0].arn
}

###########################
# CloudTrail
###########################

resource "aws_cloudtrail" "cloudtrail" {
  enable_log_file_validation    = var.enable_log_file_validation
  include_global_service_events = var.include_global_service_events
  is_multi_region_trail         = var.is_multi_region_trail
  kms_key_id                    = aws_kms_key.cloudtrail.arn
  name                          = var.name
  s3_bucket_name                = aws_s3_bucket.cloudtrail_s3_bucket.id
  s3_key_prefix                 = var.s3_key_prefix
  # Log Stream wildcard (:*) is required by CloudTrail. Both null when disabled.
  cloud_watch_logs_group_arn = var.enable_cloudwatch_logs ? "${aws_cloudwatch_log_group.cloudtrail[0].arn}:*" : null
  cloud_watch_logs_role_arn  = var.enable_cloudwatch_logs ? aws_iam_role.cloudtrail[0].arn : null
}

###########################
# S3 Bucket
###########################

resource "aws_s3_bucket" "cloudtrail_s3_bucket" {
  bucket_prefix = var.bucket_prefix
  tags          = var.tags
}

resource "aws_s3_bucket_acl" "cloudtrail_bucket_acl" {
  bucket = aws_s3_bucket.cloudtrail_s3_bucket.id
  acl    = var.acl
}

resource "aws_s3_bucket_public_access_block" "cloudtrail_bucket_public_access_block" {
  bucket                  = aws_s3_bucket.cloudtrail_s3_bucket.id
  block_public_acls       = true
  block_public_policy     = true
  ignore_public_acls      = true
  restrict_public_buckets = true
}

resource "aws_s3_bucket_lifecycle_configuration" "cloudtrail_bucket_lifecycle" {
  bucket = aws_s3_bucket.cloudtrail_s3_bucket.id

  rule {
    id     = var.bucket_lifecycle_rule_id
    status = "Enabled"

    filter {}
    expiration {
      days = var.bucket_lifecycle_expiration_days
    }
  }
}

resource "aws_s3_bucket_versioning" "cloudtrail_bucket_versioning" {
  bucket = aws_s3_bucket.cloudtrail_s3_bucket.id
  versioning_configuration {
    status     = var.versioning_status
    mfa_delete = var.mfa_delete
  }
}

resource "aws_s3_bucket_server_side_encryption_configuration" "cloudtrail_bucket_encryption" {
  bucket = aws_s3_bucket.cloudtrail_s3_bucket.bucket

  rule {
    bucket_key_enabled = var.bucket_key_enabled
    apply_server_side_encryption_by_default {
      kms_master_key_id = aws_kms_key.cloudtrail.arn
      sse_algorithm     = var.sse_algorithm
    }
  }
}

resource "aws_s3_bucket_policy" "cloudtrail_bucket_policy" {
  bucket = aws_s3_bucket.cloudtrail_s3_bucket.id
  policy = <<POLICY
{
    "Version": "2012-10-17",
    "Statement": [
        {
            "Sid": "AWSCloudTrailAclCheck",
            "Effect": "Allow",
            "Principal": {
              "Service": "cloudtrail.amazonaws.com"
            },
            "Action": "s3:GetBucketAcl",
            "Resource": "${aws_s3_bucket.cloudtrail_s3_bucket.arn}"
        },
        {
            "Sid": "AWSCloudTrailWrite",
            "Effect": "Allow",
            "Principal": {
              "Service": "cloudtrail.amazonaws.com"
            },
            "Action": "s3:PutObject",
            "Resource": "${aws_s3_bucket.cloudtrail_s3_bucket.arn}/*",
            "Condition": {
                "StringEquals": {
                    "s3:x-amz-acl": "bucket-owner-full-control"
                }
            }
        }
    ]
}
POLICY
}

resource "aws_s3_bucket_logging" "cloudtrail_s3_bucket" {
  count                 = var.enable_s3_bucket_logging ? 1 : 0
  bucket                = aws_s3_bucket.cloudtrail_s3_bucket.id
  target_bucket         = var.target_bucket
  target_prefix         = var.target_prefix
  expected_bucket_owner = var.expected_bucket_owner != "" ? var.expected_bucket_owner : null
}
