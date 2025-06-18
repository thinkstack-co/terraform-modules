data "aws_caller_identity" "current" {}

resource "aws_iam_user" "user" {
  name = var.iam_user_name
}
