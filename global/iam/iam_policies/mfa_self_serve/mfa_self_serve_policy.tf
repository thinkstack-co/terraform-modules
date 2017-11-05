resource "aws_iam_policy" "mfa_self_serve" {
  name        = "${var.mfa_self_serve_name}"
  description = "Allows users to manage their own MFA settings"
  policy      = "${file("${path.module}/mfa_self_serve_policy.json")}"
}
