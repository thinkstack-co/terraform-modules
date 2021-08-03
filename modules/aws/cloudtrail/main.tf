terraform {
  required_version = ">= 0.12.0"
}

resource "aws_kms_key" "cloudtrail" {
  description             = "KMS key for cloudtrail logs"
  deletion_window_in_days = 30
  enable_key_rotation = true
  policy  = <<POLICY
{
    "Version": "2012-10-17",
    "Statement": [

        {
            "Sid": "Enable IAM User Permissions",
            "Effect": "Allow",
            "Principal": {
                "AWS": "arn:aws:iam::369844436288:root"
            },
            "Action": "kms:*",
            "Resource": "*"
        },

        {
            "Sid": "Enable CloudTrail Encrypt Permissions",
            "Effect": "Allow",
            "Principal": {
              "Service": "cloudtrail.amazonaws.com"
            },
            "Action": "kms:GenerateDataKey*",
            "Resource": "${aws_s3_bucket.cloudtrail_s3_bucket.arn}"
            
          },

          {
            "Sid": "Enable CloudTrail Encrypt Permissions",
            "Effect": "Allow",
            "Principal": {
              "Service": "cloudtrail.amazonaws.com"
            },
            "Action": "kms:Decrypt",
            "Resource": "${aws_s3_bucket.cloudtrail_s3_bucket.arn}"
          }
          
          ]
        }
        
          
POLICY
}

resource "aws_cloudtrail" "cloudtrail" {
    enable_log_file_validation      =   var.enable_log_file_validation
    include_global_service_events   =   var.include_global_service_events
    is_multi_region_trail           =   var.is_multi_region_trail
    kms_key_id                      =   aws_kms_key.cloudtrail.arn
    name                            =   var.name
    s3_bucket_name                  =   aws_s3_bucket.cloudtrail_s3_bucket.id
    s3_key_prefix                   =   var.s3_key_prefix
}

resource "aws_s3_bucket" "cloudtrail_s3_bucket" {
    acl             = var.acl
    bucket_prefix   = var.bucket_prefix

    versioning {
        enabled     = var.enabled
        mfa_delete  = var.mfa_delete
    }

    server_side_encryption_configuration {
        rule {
          apply_server_side_encryption_by_default {
            kms_master_key_id = var.kms_master_key_id
            sse_algorithm     = var.sse_algorithm
          }
        }
      }

    tags = {
        terraform    = "true"
    }
}

resource "aws_s3_bucket_policy" "cloudtrail_bucket_policy" {
    bucket  = aws_s3_bucket.cloudtrail_s3_bucket.id
    policy  = <<POLICY
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
