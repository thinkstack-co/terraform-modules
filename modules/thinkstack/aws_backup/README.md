# AWS Backups Module

This module sets AWS backup jobs and associated services. 

# Usage

    module "aws_prod_backups" {
        source           = "github.com/thinkstack-co/terraform-modules//modules/thinkstack/aws_backup"
        providers        = {
            aws.aws_prod_region = aws.aws_prod_region
            aws.aws_dr_region   = aws.aws_dr_region
        }
    }

## Requirements

| Name | Version |
|------|---------|
| <a name="requirement_terraform"></a> [terraform](#requirement\_terraform) | >= 0.15.0 |
| <a name="requirement_aws"></a> [aws](#requirement\_aws) | >= 3.0.0 |

## Providers

| Name | Version |
|------|---------|
| <a name="provider_aws.aws_dr_region"></a> [aws.aws\_dr\_region](#provider\_aws.aws\_dr\_region) | >= 3.0.0 |
| <a name="provider_aws.aws_prod_region"></a> [aws.aws\_prod\_region](#provider\_aws.aws\_prod\_region) | >= 3.0.0 |

## Modules

No modules.

## Resources

| Name | Type |
|------|------|
| [aws_backup_plan.ec2_plan](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/backup_plan) | resource |
| [aws_backup_plan.plan](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/backup_plan) | resource |
| [aws_backup_selection.all_ec2](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/backup_selection) | resource |
| [aws_backup_selection.all_resources](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/backup_selection) | resource |
| [aws_backup_vault.vault_disaster_recovery](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/backup_vault) | resource |
| [aws_backup_vault.vault_prod_daily](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/backup_vault) | resource |
| [aws_backup_vault.vault_prod_hourly](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/backup_vault) | resource |
| [aws_backup_vault.vault_prod_monthly](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/backup_vault) | resource |
| [aws_backup_vault_lock_configuration.vault_disaster_recovery](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/backup_vault_lock_configuration) | resource |
| [aws_backup_vault_lock_configuration.vault_prod_daily](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/backup_vault_lock_configuration) | resource |
| [aws_backup_vault_lock_configuration.vault_prod_hourly](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/backup_vault_lock_configuration) | resource |
| [aws_backup_vault_lock_configuration.vault_prod_monthly](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/backup_vault_lock_configuration) | resource |
| [aws_backup_vault_policy.vault_disaster_recovery](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/backup_vault_policy) | resource |
| [aws_backup_vault_policy.vault_prod_daily](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/backup_vault_policy) | resource |
| [aws_backup_vault_policy.vault_prod_hourly](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/backup_vault_policy) | resource |
| [aws_backup_vault_policy.vault_prod_monthly](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/backup_vault_policy) | resource |
| [aws_iam_role.backup](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/iam_role) | resource |
| [aws_iam_role_policy_attachment.backup](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/iam_role_policy_attachment) | resource |
| [aws_iam_role_policy_attachment.restores](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/iam_role_policy_attachment) | resource |
| [aws_kms_alias.alias](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/kms_alias) | resource |
| [aws_kms_alias.dr_alias](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/kms_alias) | resource |
| [aws_kms_key.dr_key](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/kms_key) | resource |
| [aws_kms_key.key](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/kms_key) | resource |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_backup_plan_completion_window"></a> [backup\_plan\_completion\_window](#input\_backup\_plan\_completion\_window) | (Optional) The amount of time in minutes AWS Backup attempts a backup before canceling the job and returning an error. Default is set to 24 hours. | `number` | `1440` | no |
| <a name="input_backup_plan_name"></a> [backup\_plan\_name](#input\_backup\_plan\_name) | (Required) The display name of a backup plan. | `string` | `"prod_backups"` | no |
| <a name="input_backup_plan_start_window"></a> [backup\_plan\_start\_window](#input\_backup\_plan\_start\_window) | (Optional) The amount of time in minutes before beginning a backup. | `number` | `60` | no |
| <a name="input_daily_backup_retention"></a> [daily\_backup\_retention](#input\_daily\_backup\_retention) | (Required) The daily backup plan retention in days. By default this is 30 days | `number` | `30` | no |
| <a name="input_dr_backup_retention"></a> [dr\_backup\_retention](#input\_dr\_backup\_retention) | (Required) The dr backup plan retention in days. By default this is 7 days. | `number` | `7` | no |
| <a name="input_ec2_backup_plan_name"></a> [ec2\_backup\_plan\_name](#input\_ec2\_backup\_plan\_name) | (Required) The display name of a backup plan. | `string` | `"ec2_prod_backups"` | no |
| <a name="input_hourly_backup_retention"></a> [hourly\_backup\_retention](#input\_hourly\_backup\_retention) | (Required) The hourly backup plan retention in days. By default this is 3 days. | `number` | `3` | no |
| <a name="input_key_bypass_policy_lockout_safety_check"></a> [key\_bypass\_policy\_lockout\_safety\_check](#input\_key\_bypass\_policy\_lockout\_safety\_check) | (Optional) Specifies whether to disable the policy lockout check performed when creating or updating the key's policy. Setting this value to true increases the risk that the CMK becomes unmanageable. For more information, refer to the scenario in the Default Key Policy section in the AWS Key Management Service Developer Guide. Defaults to false. | `bool` | `false` | no |
| <a name="input_key_customer_master_key_spec"></a> [key\_customer\_master\_key\_spec](#input\_key\_customer\_master\_key\_spec) | (Optional) Specifies whether the key contains a symmetric key or an asymmetric key pair and the encryption algorithms or signing algorithms that the key supports. Valid values: SYMMETRIC\_DEFAULT, RSA\_2048, RSA\_3072, RSA\_4096, ECC\_NIST\_P256, ECC\_NIST\_P384, ECC\_NIST\_P521, or ECC\_SECG\_P256K1. Defaults to SYMMETRIC\_DEFAULT. For help with choosing a key spec, see the AWS KMS Developer Guide. | `string` | `"SYMMETRIC_DEFAULT"` | no |
| <a name="input_key_deletion_window_in_days"></a> [key\_deletion\_window\_in\_days](#input\_key\_deletion\_window\_in\_days) | (Optional) Duration in days after which the key is deleted after destruction of the resource, must be between 7 and 30 days. Defaults to 30 days. | `number` | `30` | no |
| <a name="input_key_description"></a> [key\_description](#input\_key\_description) | (Optional) The description of the key as viewed in AWS console. | `string` | `"AWS backups kms key used to encrypt backups"` | no |
| <a name="input_key_enable_key_rotation"></a> [key\_enable\_key\_rotation](#input\_key\_enable\_key\_rotation) | (Optional) Specifies whether key rotation is enabled. Defaults to false. | `bool` | `true` | no |
| <a name="input_key_is_enabled"></a> [key\_is\_enabled](#input\_key\_is\_enabled) | (Optional) Specifies whether the key is enabled. Defaults to true. | `string` | `true` | no |
| <a name="input_key_name"></a> [key\_name](#input\_key\_name) | (Optional) The display name of the alias. The name must start with the word 'alias' followed by a forward slash | `string` | `"alias/aws_backup_key"` | no |
| <a name="input_key_policy"></a> [key\_policy](#input\_key\_policy) | (Optional) A valid policy JSON document. Although this is a key policy, not an IAM policy, an aws\_iam\_policy\_document, in the form that designates a principal, can be used. For more information about building policy documents with Terraform, see the AWS IAM Policy Document Guide. | `string` | `null` | no |
| <a name="input_key_usage"></a> [key\_usage](#input\_key\_usage) | (Optional) Specifies the intended use of the key. Defaults to ENCRYPT\_DECRYPT, and only symmetric encryption and decryption are supported. | `string` | `"ENCRYPT_DECRYPT"` | no |
| <a name="input_monthly_backup_retention"></a> [monthly\_backup\_retention](#input\_monthly\_backup\_retention) | (Required) The daily backup plan retention in days. By default this is 365 days. | `number` | `365` | no |
| <a name="input_tags"></a> [tags](#input\_tags) | (Optional) A mapping of tags to assign to the object. | `map` | <pre>{<br>  "aws_backup": "true",<br>  "created_by": "ThinkStack",<br>  "environment": "prod",<br>  "priority": "critical",<br>  "terraform": "true"<br>}</pre> | no |
| <a name="input_vault_disaster_recovery_name"></a> [vault\_disaster\_recovery\_name](#input\_vault\_disaster\_recovery\_name) | value | `string` | `"vault_disaster_recovery"` | no |
| <a name="input_vault_dr_hourly_name"></a> [vault\_dr\_hourly\_name](#input\_vault\_dr\_hourly\_name) | value | `string` | `"vault_dr_hourly"` | no |
| <a name="input_vault_prod_daily_name"></a> [vault\_prod\_daily\_name](#input\_vault\_prod\_daily\_name) | value | `string` | `"vault_prod_daily"` | no |
| <a name="input_vault_prod_hourly_name"></a> [vault\_prod\_hourly\_name](#input\_vault\_prod\_hourly\_name) | value | `string` | `"vault_prod_hourly"` | no |
| <a name="input_vault_prod_monthly_name"></a> [vault\_prod\_monthly\_name](#input\_vault\_prod\_monthly\_name) | value | `string` | `"vault_prod_monthly"` | no |

## Outputs

| Name | Description |
|------|-------------|
| <a name="output_vault_daily_arn"></a> [vault\_daily\_arn](#output\_vault\_daily\_arn) | n/a |
| <a name="output_vault_disaster_recovery_arn"></a> [vault\_disaster\_recovery\_arn](#output\_vault\_disaster\_recovery\_arn) | n/a |
| <a name="output_vault_hourly_arn"></a> [vault\_hourly\_arn](#output\_vault\_hourly\_arn) | n/a |
| <a name="output_vault_monthly_arn"></a> [vault\_monthly\_arn](#output\_vault\_monthly\_arn) | n/a |