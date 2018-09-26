output "arn" {
  value = "${aws_iam_role.this.arn}"
}

output "name" {
  value = "${aws_iam_role.this.name}"
}

output "unique_id" {
  value = "${aws_iam_role.this.unique_id}"
}
