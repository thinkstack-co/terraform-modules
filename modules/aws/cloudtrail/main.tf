terraform {
  required_version = ">= 0.13.0"
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
  policy                   = jsonencode({
    "Version" = "2012-10-17",
    "Id" = "Key policy created by CloudTrail",
    "Statement" = [
        {
            "Sid" = "Enable IAM User Permissions",
            "Effect" = "Allow",
            "Principal" = {"AWS": [
                "arn:aws:iam::${data.aws_caller_identity.current.account_id}:root"
            ]},
            "Action": "kms:*",
            "Resource": "*"
        },
        {
            "Sid": "Allow CloudTrail to encrypt logs",
            "Effect": "Allow",
            "Principal": {"Service": ["cloudtrail.amazonaws.com"]},
            "Action": "kms:GenerateDataKey*",
            "Resource": "arn:aws:kms:${data.aws_region.current.name}:${data.aws_caller_identity.current.account_id}:key/${aws_kms_key.cloudtrail.key_id}",
            "Condition": {"StringLike": {"kms:EncryptionContext:aws:cloudtrail:arn": "arn:aws:cloudtrail:*:${data.aws_caller_identity.current.account_id}:trail/*"}}
        },
        {
            "Sid": "Allow CloudTrail to describe key",
            "Effect": "Allow",
            "Principal": {"Service": ["cloudtrail.amazonaws.com"]},
            "Action": "kms:DescribeKey",
            "Resource": "arn:aws:kms:${data.aws_region.current.name}:${data.aws_caller_identity.current.account_id}:key/${aws_kms_key.cloudtrail.key_id}"
        },
        {
            "Sid": "Allow principals in the account to decrypt log files",
            "Effect": "Allow",
            "Principal": {"AWS": "*"},
            "Action": [
                "kms:Decrypt",
                "kms:ReEncryptFrom"
            ],
            "Resource": "arn:aws:kms:${data.aws_region.current.name}:${data.aws_caller_identity.current.account_id}:key/${aws_kms_key.cloudtrail.key_id}",
            "Condition": {
                "StringEquals": {"kms:CallerAccount": "${data.aws_caller_identity.current.account_id}"},
                "StringLike": {"kms:EncryptionContext:aws:cloudtrail:arn": "arn:aws:cloudtrail:*:${data.aws_caller_identity.current.account_id}:trail/*"}
            }
        },
        {
            "Sid": "Allow alias creation during setup",
            "Effect": "Allow",
            "Principal": {"AWS": "*"},
            "Action": "kms:CreateAlias",
            "Resource": "arn:aws:kms:${data.aws_region.current.name}:${data.aws_caller_identity.current.account_id}:key/${aws_kms_key.cloudtrail.key_id}",
            "Condition": {"StringEquals": {
                "kms:ViaService": "ec2.${data.aws_region.current.name}.amazonaws.com",
                "kms:CallerAccount": "${data.aws_caller_identity.current.account_id}"
            }}
        },
        {
            "Sid": "Enable cross account log decryption",
            "Effect": "Allow",
            "Principal": {"AWS": "*"},
            "Action": [
                "kms:Decrypt",
                "kms:ReEncryptFrom"
            ],
            "Resource": "arn:aws:kms:${data.aws_region.current.name}:${data.aws_caller_identity.current.account_id}:key/${aws_kms_key.cloudtrail.key_id}",
            "Condition": {
                "StringEquals": {"kms:CallerAccount": "${data.aws_caller_identity.current.account_id}"},
                "StringLike": {"kms:EncryptionContext:aws:cloudtrail:arn": "arn:aws:cloudtrail:*:${data.aws_caller_identity.current.account_id}:trail/*"}
            }
        }
    ]
  })
}

###########################
# S3 Bucket
###########################
resource "aws_s3_bucket" "cloudtrail_s3_bucket" {
  acl           = "private"
  bucket_prefix = var.s3_bucket_prefix
  tags          = var.tags

  versioning {
    enabled    = var.s3_versioning_enabled
    mfa_delete = var.s3_mfa_delete
  }
}

resource "aws_s3_bucket_policy" "cloudtrail_bucket_policy" {
  bucket = aws_s3_bucket.cloudtrail_s3_bucket.id
  policy = jsonencode({
    "Version" = "2012-10-17",
    "Statement" = [
        {
            "Sid" = "AWSCloudTrailAclCheck",
            "Effect" = "Allow",
            "Principal" = {
                "Service" = "cloudtrail.amazonaws.com"
            },
            "Action" = "s3:GetBucketAcl",
            "Resource" = "${aws_s3_bucket.cloudtrail_s3_bucket.arn}"
        },
        {
            "Sid" = "AWSCloudTrailWrite",
            "Effect" = "Allow",
            "Principal" = {
                "Service" = "cloudtrail.amazonaws.com"
            },
            "Action" = "s3:PutObject",
            "Resource" = "${aws_s3_bucket.cloudtrail_s3_bucket.arn}/*",
            "Condition" = {
                "StringEquals" = {
                    "AWS:SourceArn" = "${aws_cloudtrail.cloudtrail.arn}",
                    "s3:x-amz-acl" = "bucket-owner-full-control"
                }
            }
        }
    ]
  })
}

###########################
# Cloudtrail
###########################

resource "aws_cloudtrail" "cloudtrail" {
    enable_log_file_validation      =   var.cloudtrail_enable_log_file_validation
    include_global_service_events   =   var.cloudtrail_include_global_service_events
    is_multi_region_trail           =   var.cloudtrail_is_multi_region_trail
    kms_key_id                      =   aws_kms_key.cloudtrail.arn
    name                            =   var.cloudtrail_name
    s3_bucket_name                  =   aws_s3_bucket.cloudtrail_s3_bucket.id
    s3_key_prefix                   =   var.cloudtrail_s3_key_prefix
    insight_selector {
      insight_type = var.cloudtrail_insight_type
    }
}
