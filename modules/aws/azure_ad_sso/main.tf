terraform {
  required_version = ">= 0.12.0"
}

##################################
# AWS iam policy - role reading policy
##################################

resource "aws_iam_policy" "role_reading_policy" {
  name        = var.policy_name
  description = var.policy_description
  policy      = file("${path.module}/azure-ad-sso-policy.json")
}

##################################
# AWS iam user - role reading user
##################################

resource "aws_iam_user" "role_reading_user" {
  force_destroy        = var.user_force_destroy
  name                 = var.user_name
  path                 = var.user_path
  permissions_boundary = var.user_permissions_boundary
}

resource "aws_iam_user_policy_attachment" "reading_user_attach" {
  user       = aws_iam_user.role_reading_user.name
  policy_arn = aws_iam_policy.role_reading_policy.arn
}

resource "aws_iam_access_key" "read_user_key" {
  user    = aws_iam_user.role_reading_user.name
  pgp_key = var.pgp_key
}

##################################
# AWS iam saml provider - saml identify provider
##################################

resource "aws_iam_saml_provider" "this" {
  name                   = var.saml_name
  saml_metadata_document = var.saml_metadata_document
}

##################################
# AWS assume policy document
##################################

data "aws_iam_policy_document" "thinkstack_azure_ad_assume_policy" {
  statement {
    sid     = "ThinkStackAzureAD"
    actions = ["sts:AssumeRoleWithSAML"]

    principals {
      type        = "Federated"
      identifiers = [aws_iam_saml_provider.this.arn]
    }

    condition {
      test     = "StringEquals"
      variable = "SAML:aud"
      values   = ["https://signin.aws.amazon.com/saml"]
    }
  }
}

##################################
# AWS iam role - admins role
##################################

resource "aws_iam_role" "role_admins" {
  assume_role_policy    = data.aws_iam_policy_document.thinkstack_azure_ad_assume_policy.json
  description           = var.role_admins_description
  force_detach_policies = var.role_admins_force_detach_policies
  max_session_duration  = var.role_admins_max_session_duration
  name                  = var.role_admins_name
  permissions_boundary  = var.role_admins_permissions_boundary
}

resource "aws_iam_role_policy_attachment" "admin_policy_attach" {
  role       = aws_iam_role.role_admins.name
  policy_arn = var.admin_policy_arn
}

##################################
# AWS iam role - sysadmins role
##################################

resource "aws_iam_role" "role_sysadmins" {
  assume_role_policy    = data.aws_iam_policy_document.thinkstack_azure_ad_assume_policy.json
  description           = var.role_sysadmins_description
  force_detach_policies = var.role_sysadmins_force_detach_policies
  max_session_duration  = var.role_sysadmins_max_session_duration
  name                  = var.role_sysadmins_name
  permissions_boundary  = var.role_sysadmins_permissions_boundary
}

resource "aws_iam_role_policy_attachment" "sysadmins_policy_attach" {
  role       = aws_iam_role.role_sysadmins.name
  policy_arn = var.sysadmins_policy_arn
}

##################################
# AWS iam role - read only role
##################################

resource "aws_iam_role" "role_read_only" {
  assume_role_policy    = data.aws_iam_policy_document.thinkstack_azure_ad_assume_policy.json
  description           = var.role_read_only_description
  force_detach_policies = var.role_read_only_force_detach_policies
  max_session_duration  = var.role_read_only_max_session_duration
  name                  = var.role_read_only_name
  permissions_boundary  = var.role_read_only_permissions_boundary
}

resource "aws_iam_role_policy_attachment" "read_only_policy_attach" {
  role       = aws_iam_role.role_read_only.name
  policy_arn = var.read_only_policy_arn
}
