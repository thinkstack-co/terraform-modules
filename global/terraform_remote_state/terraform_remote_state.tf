resource "aws_s3_bucket" "terraform_state" {
    bucket    = "${var.s3_bucket_name}"
    region    = "${var.s3_bucket_region}"
    versioning {
        enabled = true
    }

    lifecycle {
        prevent_destroy = true
    }

    tags {
        terraform    = "yes"
    }
}

resource "aws_dynamodb_table" "terraform_state_lock" {
    name    = "${var.dynamodb_table_name}"
    read_capacity   = 20
    write_capacity  = 20
    hash_key        = "LockID"

    attribute {
        name    = "LockID"
        type    = "S"
    }

    tags {
        terraform   = "yes"
    }
}
