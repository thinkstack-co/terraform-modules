# AWS Backup IAM Role Module

This module creates an IAM role for AWS Backup service with necessary permissions.

## Usage

```hcl
module "backup_iam_role" {
  source = "github.com/thinkstack-co/terraform-modules//modules/thinkstack/aws_backup_custom/modules/aws_backup_iam_role?ref=v2.6.6"

  role_name                  = "my-backup-service-role"
  enable_tag_based_selection = true
  
  additional_policy_arns = [
    "arn:aws:iam::123456789012:policy/CustomBackupPolicy"
  ]
  
  tags = {
    Environment = "production"
  }
}
```

## Requirements

| Name | Version |
|------|---------|
| terraform | >= 1.0.0 |
| aws | >= 4.0.0 |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| role_name | The name of the IAM role that AWS Backup uses to authenticate when backing up the target resource | `string` | `"aws-backup-service-role"` | no |
| enable_tag_based_selection | Whether to create and attach a policy that allows AWS Backup to select resources based on tags | `bool` | `true` | no |
| additional_policy_arns | List of additional policy ARNs to attach to the backup role | `list(string)` | `[]` | no |
| tags | A mapping of tags to assign to the IAM role | `map(string)` | `{}` | no |

## Outputs

| Name | Description |
|------|-------------|
| role_arn | The Amazon Resource Name (ARN) of the IAM role used for AWS Backup |
| role_name | The name of the IAM role used for AWS Backup |
| role_id | The unique ID of the IAM role |
| tag_policy_arn | The ARN of the tag-based backup policy (if enabled) |