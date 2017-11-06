resource "aws_cloudtrail" "cloudtrail" {
    name                            =   "${var.cloudtrail_name}"
    s3_bucket_name                  =   "${aws_s3_bucket.cloudtrail_s3_bucket.id}"
    s3_key_prefix                   =   "${var.cloudtrail_s3_key_prefix}"
    include_global_service_events   =   "${var.cloudtrail_global_service_events}"
    is_multi_region_trail           =   "${var.cloudtrail_multi_region}"
    kms_key_id                      =   "${var.cloudtrail_kms_key}"
    enable_log_file_validation      =   "${var.cloudtrail_log_file_validation}"
}

resource "aws_s3_bucket" "cloudtrail_s3_bucket" {
    bucket_prefix   = "${var.s3_bucket_prefix}"
    region          = "${var.s3_bucket_region}"
    acl             = "${var.s3_bucket_acl}"

    versioning {
        enabled     = "${var.s3_versioning}"
        mfa_delete  = "${var.s3_mfa_delete}"
    }

    lifecycle {
        prevent_destroy = true
    }

    tags {
        terraform    = "true"
    }
}

resource "aws_s3_bucket_policy" "cloudtrail_bucket_policy" {
    bucket  = "${aws_s3_bucket.cloudtrail_s3_bucket.id}"
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
