rule "terraform_unused_declarations" {
  enabled = true
  ignore_paths = [
    "global/iam/iam_groups/iam_groups.tf",
    "global/iam/iam_policies/ebs_backup/ebs_backup.tf",
    "global/iam/iam_policies/mfa_self_serv/mfa_enforcement_policy.tf",
    "global/iam/iam_policies/s3_put_object/s3_put_object.tf",
    "global/iam/iam_roles/iam_role.tf",
    "global/iam/iam_users/aws_iam_user.tf",
    "modules/aws/config/main.tf",
    "modules/aws/ec2_instance/main.tf",
    "modules/aws/ec2_instance",
    "modules/aws/vendor/cato_sdwan/main.tf",
    "modules/aws/vendor/cato_sdwan",
    "modules/thinkstack/aws_backup_custom/main.tf",
    "modules/thinkstack/aws_backup_custom"
  ]
}
