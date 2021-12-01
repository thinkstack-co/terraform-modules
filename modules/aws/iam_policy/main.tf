terraform {
  required_version = ">= 0.12.0"
}

resource "aws_iam_policy" "this" {
  description = var.description
  name        = var.name
  path        = var.path
  policy      = var.policy
}
