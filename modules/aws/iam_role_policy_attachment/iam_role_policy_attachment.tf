resource "aws_iam_role_policy_attachment" "test-attach" {
    policy_arn = "${var.policy_arn}"
    role       = "${var.role}"
}
