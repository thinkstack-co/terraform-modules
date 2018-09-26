resource "aws_iam_policy" "this" {
    description = "${var.description}"
    name        = "${var.name}"
    path        = "${var.path}"
    policy      = "${var.policy}"
}
