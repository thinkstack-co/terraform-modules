resource "aws_s3_bucket" "s3_bucket" {
    acl             = "${var.acl}"
    bucket_prefix   = "${var.bucket_prefix}"
    policy          = "${var.policy}"
    region          = "${var.region}"

    versioning {
        enabled     = "${var.versioning}"
        mfa_delete  = "${var.mfa_delete}"
    }

    lifecycle {
        prevent_destroy = true
    }

    tags {
        terraform    = "yes"
    }
}
