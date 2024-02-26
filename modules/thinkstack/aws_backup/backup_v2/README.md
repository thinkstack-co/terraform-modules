<!-- BEGIN_TF_DOCS -->
## Requirements

| Name | Version |
|------|---------|
| <a name="requirement_terraform"></a> [terraform](#requirement\_terraform) | >= 1.0.0 |
| <a name="requirement_aws"></a> [aws](#requirement\_aws) | >= 4.0.0 |

## Providers

| Name | Version |
|------|---------|
| <a name="provider_aws"></a> [aws](#provider\_aws) | >= 4.0.0 |
| <a name="provider_aws.aws_prod_region"></a> [aws.aws\_prod\_region](#provider\_aws.aws\_prod\_region) | >= 4.0.0 |

## Modules

No modules.

## Resources

| Name | Type |
|------|------|
| [aws_backup_plan.this](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/backup_plan) | resource |
| [aws_backup_selection.this](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/backup_selection) | resource |
| [aws_backup_vault.this](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/backup_vault) | resource |
| [aws_backup_vault_lock_configuration.this](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/backup_vault_lock_configuration) | resource |
| [aws_iam_role.backup_role](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/iam_role) | resource |
| [aws_iam_role_policy_attachment.backup_role_policy](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/iam_role_policy_attachment) | resource |
| [aws_kms_alias.alias](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/kms_alias) | resource |
| [aws_kms_key.key](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/kms_key) | resource |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_backup_plan_name"></a> [backup\_plan\_name](#input\_backup\_plan\_name) | The name of the backup plan | `string` | n/a | yes |
| <a name="input_backup_region"></a> [backup\_region](#input\_backup\_region) | Backup Region | `string` | n/a | yes |
| <a name="input_backup_rule_name"></a> [backup\_rule\_name](#input\_backup\_rule\_name) | The name of the backup rule | `string` | n/a | yes |
| <a name="input_backup_vault_name"></a> [backup\_vault\_name](#input\_backup\_vault\_name) | The name of the backup vault | `string` | `"Default"` | no |
| <a name="input_cold_storage_after_days"></a> [cold\_storage\_after\_days](#input\_cold\_storage\_after\_days) | The number of days after creation when a recovery point is moved to cold storage. | `number` | n/a | yes |
| <a name="input_delete_after_days"></a> [delete\_after\_days](#input\_delete\_after\_days) | The number of days after creation when a recovery point is deleted. | `number` | n/a | yes |
| <a name="input_instance_ids"></a> [instance\_ids](#input\_instance\_ids) | List of EC2 instance IDs to backup | `list(string)` | n/a | yes |
| <a name="input_key_bypass_policy_lockout_safety_check"></a> [key\_bypass\_policy\_lockout\_safety\_check](#input\_key\_bypass\_policy\_lockout\_safety\_check) | (Optional) Specifies whether to disable the policy lockout check performed when creating or updating the key's policy. Setting this value to true increases the risk that the CMK becomes unmanageable. For more information, refer to the scenario in the Default Key Policy section in the AWS Key Management Service Developer Guide. Defaults to false. | `bool` | `false` | no |
| <a name="input_key_customer_master_key_spec"></a> [key\_customer\_master\_key\_spec](#input\_key\_customer\_master\_key\_spec) | (Optional) Specifies whether the key contains a symmetric key or an asymmetric key pair and the encryption algorithms or signing algorithms that the key supports. Valid values: SYMMETRIC\_DEFAULT, RSA\_2048, RSA\_3072, RSA\_4096, ECC\_NIST\_P256, ECC\_NIST\_P384, ECC\_NIST\_P521, or ECC\_SECG\_P256K1. Defaults to SYMMETRIC\_DEFAULT. For help with choosing a key spec, see the AWS KMS Developer Guide. | `string` | `"SYMMETRIC_DEFAULT"` | no |
| <a name="input_key_deletion_window_in_days"></a> [key\_deletion\_window\_in\_days](#input\_key\_deletion\_window\_in\_days) | (Optional) Duration in days after which the key is deleted after destruction of the resource, must be between 7 and 30 days. Defaults to 30 days. | `number` | `30` | no |
| <a name="input_key_description"></a> [key\_description](#input\_key\_description) | (Optional) The description of the key as viewed in AWS console. | `string` | `"AWS backups kms key used to encrypt backups"` | no |
| <a name="input_key_enable_key_rotation"></a> [key\_enable\_key\_rotation](#input\_key\_enable\_key\_rotation) | (Optional) Specifies whether key rotation is enabled. Defaults to false. | `bool` | `true` | no |
| <a name="input_key_is_enabled"></a> [key\_is\_enabled](#input\_key\_is\_enabled) | (Optional) Specifies whether the key is enabled. Defaults to true. | `string` | `true` | no |
| <a name="input_key_name"></a> [key\_name](#input\_key\_name) | (Optional) The display name of the alias. The name must start with the word 'alias' followed by a forward slash | `string` | `"alias/aws_backup_key"` | no |
| <a name="input_key_policy"></a> [key\_policy](#input\_key\_policy) | (Optional) A valid policy JSON document. Although this is a key policy, not an IAM policy, an aws\_iam\_policy\_document, in the form that designates a principal, can be used. For more information about building policy documents with Terraform, see the AWS IAM Policy Document Guide. | `string` | `null` | no |
| <a name="input_key_usage"></a> [key\_usage](#input\_key\_usage) | (Optional) Specifies the intended use of the key. Defaults to ENCRYPT\_DECRYPT, and only symmetric encryption and decryption are supported. | `string` | `"ENCRYPT_DECRYPT"` | no |
| <a name="input_schedule"></a> [schedule](#input\_schedule) | A CRON expression specifying when to initiate backups | `string` | n/a | yes |
| <a name="input_tags"></a> [tags](#input\_tags) | A map of tags to assign to the backup plan | `map(string)` | `{}` | no |

## Outputs

| Name | Description |
|------|-------------|
| <a name="output_backup_plan_id"></a> [backup\_plan\_id](#output\_backup\_plan\_id) | The ID of the backup plan |
| <a name="output_backup_role_arn"></a> [backup\_role\_arn](#output\_backup\_role\_arn) | The ARN of the IAM role used for backup |
| <a name="output_backup_role_name"></a> [backup\_role\_name](#output\_backup\_role\_name) | The name of the IAM role used for AWS Backup |
| <a name="output_backup_vault_id"></a> [backup\_vault\_id](#output\_backup\_vault\_id) | The ID of the backup vault |
<!-- END_TF_DOCS -->