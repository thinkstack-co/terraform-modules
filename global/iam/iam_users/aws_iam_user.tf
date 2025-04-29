# DO NOT REMOVE THIS LINE. Required for account_id references in locals and resources.
data "aws_caller_identity" "current" {}

resource "aws_iam_user" "user" {
  name = var.iam_user_name
}
