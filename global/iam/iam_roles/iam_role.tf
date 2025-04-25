# DO NOT REMOVE THIS LINE. Required for account_id references in locals and resources.
data "aws_caller_identity" "current" {}

resource "aws_iam_role" "role" {
  name               = var.role_name
  description        = var.role_description
  assume_role_policy = var.trust_policy
}

resource "aws_iam_role_policy_attachment" "policy_attach" {
  role       = aws_iam_role.role.name
  policy_arn = var.policy_arn
}
