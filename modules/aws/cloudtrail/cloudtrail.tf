resource "aws_cloudtrail" "cloudtrail" {
    enable_log_file_validation      =   "${var.enable_log_file_validation}"
    include_global_service_events   =   "${var.include_global_service_events}"
    is_multi_region_trail           =   "${var.is_multi_region_trail}"
    kms_key_id                      =   "${var.kms_key_id}"
    name                            =   "${var.name}"
    s3_bucket_name                  =   "${aws_s3_bucket.cloudtrail_s3_bucket.id}"
    s3_key_prefix                   =   "${var.s3_key_prefix}"
}

resource "aws_s3_bucket" "cloudtrail_s3_bucket" {
    acl             = "${var.s3_bucket_acl}"
    bucket_prefix   = "${var.s3_bucket_prefix}"
    region          = "${var.s3_bucket_region}"

    versioning {
        enabled     = "${var.s3_versioning}"
        mfa_delete  = "${var.s3_mfa_delete}"
    }

    tags {
        terraform    = "yes"
    }

    lifecycle {
        prevent_destroy = true
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
