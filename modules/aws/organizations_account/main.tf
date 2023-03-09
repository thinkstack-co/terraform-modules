terraform {
  required_version = ">= 1.0.0"
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = ">= 4.0.0"
    }
  }
}

############################################################
# AWS Organization Account
############################################################

resource "aws_organizations_account" "account" {
  name                       = var.name
  email                      = var.email
  iam_user_access_to_billing = var.iam_user_access_to_billing
  parent_id                  = var.parent_id
  role_name                  = var.role_name
  close_on_deletion          = var.close_on_deletion
  tags                       = var.tags

  lifecycle {
    ignore_changes = [role_name]
  }
}
