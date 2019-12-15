terraform {
  required_version = ">= 0.12.0"
}

data "aws_iam_role" "this" {
  assume_role_policy    = var.assume_role_policy
  description           = var.description
  force_detach_policies = var.force_detach_policies
  max_session_duration  = var.max_session_duration
  name                  = var.name
  permissions_boundary  = var.permissions_boundary
}
