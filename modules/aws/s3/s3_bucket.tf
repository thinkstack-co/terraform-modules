resource "aws_s3_bucket" "s3_bucket" {
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
        terraform    = "yes"
    }
}
