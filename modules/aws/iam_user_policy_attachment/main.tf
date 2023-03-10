terraform {
  required_version = ">= 1.0.0"
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = ">= 4.0.0"
    }
  }
}

resource "aws_iam_user_policy_attachment" "test-attach" {
  policy_arn = var.policy_arn
  user       = var.user
}
