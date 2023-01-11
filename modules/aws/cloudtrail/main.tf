terraform {
  required_version = ">= 1.0.0"
}

###########################
# KMS Encryption Key
###########################

resource "aws_kms_key" "cloudtrail_key" {
  count                    = (var.enable_siem_cloudtrail_logs == true ? 1 : 0)
  customer_master_key_spec = var.cloudtrail_key_customer_master_key_spec
  description              = var.cloudtrail_key_description
  deletion_window_in_days  = var.cloudtrail_key_deletion_window_in_days
  enable_key_rotation      = var.cloudtrail_key_enable_key_rotation
  key_usage                = var.cloudtrail_key_usage
  is_enabled               = var.cloudtrail_key_is_enabled
  tags                     = var.tags
  policy                   = jsonencode({
    "Version" = "2012-10-17",
    "Id" = "Key policy created by CloudTrail",
    "Statement" = [
        {
            "Sid" = "Enable IAM User Permissions",
            "Effect" = "Allow",
            "Principal" = {
                "AWS" = [
                    "arn:aws:iam::${data.aws_caller_identity.current.account_id}:root"
                ]
            },
            "Action" = "kms:*",
            "Resource" = "*"
        },
        {
            "Sid" = "Allow CloudTrail to encrypt logs",
            "Effect" = "Allow",
            "Principal" = {
                "Service" = "cloudtrail.amazonaws.com"
            },
            "Action" = "kms:GenerateDataKey*",
            "Resource" = "arn:aws:kms:${data.aws_region.current.name}:${data.aws_caller_identity.current.account_id}:key/*",
            "Condition" = {
                "StringLike" = {
                    "kms:EncryptionContext:aws:cloudtrail:arn": "arn:aws:cloudtrail:*:${data.aws_caller_identity.current.account_id}:trail/*"
                }
            }
        },
        {
            "Sid" = "Allow CloudTrail to describe key",
            "Effect" = "Allow",
            "Principal" = {
                "Service": "cloudtrail.amazonaws.com"
            },
            "Action" = "kms:DescribeKey",
            "Resource" = "arn:aws:kms:${data.aws_region.current.name}:${data.aws_caller_identity.current.account_id}:key/*"
        },
        {
            "Sid" = "Allow principals in the account to decrypt log files",
            "Effect" = "Allow",
            "Principal" = {
                "AWS": "*"
            },
            "Action" = [
                "kms:Decrypt",
                "kms:ReEncryptFrom"
            ],
            "Resource" = "arn:aws:kms:${data.aws_region.current.name}:${data.aws_caller_identity.current.account_id}:key/*",
            "Condition" = {
                "StringEquals" = {
                    "kms:CallerAccount": "${data.aws_caller_identity.current.account_id}"
                },
                "StringLike" = {
                    "kms:EncryptionContext:aws:cloudtrail:arn": "arn:aws:cloudtrail:*:${data.aws_caller_identity.current.account_id}:trail/*"
                }
            }
        },
        {
            "Sid" = "Allow alias creation during setup",
            "Effect" = "Allow",
            "Principal" = {
                "AWS": "*"
            },
            "Action" = "kms:CreateAlias",
            "Resource" = "*",
            "Condition" = {
                "StringEquals" = {
                    "kms:CallerAccount": "${data.aws_caller_identity.current.account_id}",
                    "kms:ViaService": "ec2.${data.aws_region.current.name}.amazonaws.com"
                }
            }
        },
        {
            "Sid" = "Enable cross account log decryption",
            "Effect" = "Allow",
            "Principal" = {
                "AWS": "*"
            },
            "Action" = [
                "kms:Decrypt",
                "kms:ReEncryptFrom"
            ],
            "Resource" = "arn:aws:kms:${data.aws_region.current.name}:${data.aws_caller_identity.current.account_id}:key/*",
            "Condition" = {
                "StringEquals" = {
                    "kms:CallerAccount": "${data.aws_caller_identity.current.account_id}"
                },
                "StringLike" = {
                    "kms:EncryptionContext:aws:cloudtrail:arn": "arn:aws:cloudtrail:*:${data.aws_caller_identity.current.account_id}:trail/*"
                }
            }
        }
    ]
  })
}

resource "aws_kms_alias" "cloudtrail_alias" {
  count         = (var.enable_siem_cloudtrail_logs == true ? 1 : 0)
  name_prefix   = var.cloudtrail_key_name_prefix
  target_key_id = aws_kms_key.cloudtrail_key[0].key_id
}

resource "aws_cloudtrail" "cloudtrail" {
  enable_log_file_validation    = var.enable_log_file_validation
  include_global_service_events = var.include_global_service_events
  is_multi_region_trail         = var.is_multi_region_trail
  kms_key_id                    = aws_kms_key.cloudtrail_key[0].arn
  name                          = var.name
  s3_bucket_name                = aws_s3_bucket.cloudtrail_s3_bucket.id
  s3_key_prefix                 = var.s3_key_prefix
}

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
      kms_master_key_id = var.kms_master_key_id
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
