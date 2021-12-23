terraform {
  required_version = ">= 0.12.0"
}

resource "aws_iam_role_policy_attachment" "this" {
  policy_arn = var.policy_arn
  role       = var.role
}
