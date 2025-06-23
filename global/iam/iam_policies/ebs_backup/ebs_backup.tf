data "aws_caller_identity" "current" {}

resource "aws_iam_policy" "policy" {
  name        = var.policy_name
  description = var.policy_description
  policy      = var.policy
}
