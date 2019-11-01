terraform {
  required_version = ">= 0.12.0"
}

resource "aws_iam_user_policy_attachment" "test-attach" {
    policy_arn = var.policy_arn
    user       = var.user
}
