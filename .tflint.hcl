# TFLint configuration for terraform-modules

# Plugin for AWS-specific rules
plugin "aws" {
  enabled = true
}

# Rule configuration
rule "terraform_unused_declarations" {
  enabled = true
  # Ignore paths where unused declarations are acceptable
  ignore_paths = [
    "global/iam/iam_groups/iam_groups.tf",
    "global/iam/iam_policies/ebs_backup/ebs_backup.tf",
    "global/iam/iam_policies/mfa_self_serv/mfa_enforcement_policy.tf",
    "global/iam/iam_policies/s3_put_object/s3_put_object.tf",
    "global/iam/iam_roles/iam_role.tf",
    "global/iam/iam_users/aws_iam_user.tf",
    "modules/aws/config/*",
    "modules/aws/ec2_instance/*",
    "modules/aws/vendor/cato_sdwan/*",
    "modules/thinkstack/aws_backup_custom/*",
    "modules/aws/alb/alb_listener_rule/*",
    "modules/aws/s3/notification/*",
    "modules/aws/vendor/silverpeak/*",
    "modules/module_template/*",
    "modules/terraform/oauth_client/*",
    "modules/terraform/team/*",
    "modules/terraform/team_access/*"
  ]
  # Ignore specific data sources that are commonly used for account context
  ignore = ["data.aws_caller_identity.current"]
}

# Disable specific checks for module development patterns
rule "terraform_module_version" {
  enabled = false
}

rule "terraform_required_providers" {
  enabled = true
}

rule "terraform_required_version" {
  enabled = true
}

# Ignore unused aws_caller_identity data sources
rule "terraform_unused_required_providers" {
  enabled = true
}

# AWS Provider specific rules
rule "aws_iam_role_missing_current_account_caller_identity" {
  enabled = false
}