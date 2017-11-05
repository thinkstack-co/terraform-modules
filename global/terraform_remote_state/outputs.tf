output "s3_bucket_id" {
    value = "${aws_s3_bucket.terraform_state.id}"
}

output "s3_bucket_arn" {
    value = "${aws_s3_bucket.terraform_state.arn}"
}

output "s3_bucket_region" {
    value = "${aws_s3_bucket.terraform_state.region}"
}

output "s3_bucket_website_endpoint" {
    value = "${aws_s3_bucket.terraform_state.website_endpoint}"
}

output "s3_bucket_website_domain" {
    value = "${aws_s3_bucket.terraform_state.website_domain}"
}

output "dynamodb_table_id" {
    value = "${aws_dynamodb_table.terraform_state_lock.id}"
}

output "dynamodb_table_arn" {
    value = "${aws_dynamodb_table.terraform_state_lock.arn}"
}
