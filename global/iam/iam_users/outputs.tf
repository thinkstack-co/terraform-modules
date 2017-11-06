output "arn" {
    value = "${aws_iam_user.user.arn}"
}

output "name" {
    value = "${aws_iam_user.user.name}"
}

output "unique_id" {
    value = "${aws_iam_user.user.unique_id}"
}
