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
| <a name="provider_aws.aws_dr_region"></a> [aws.aws\_dr\_region](#provider\_aws.aws\_dr\_region) | >= 4.0.0 |
| <a name="provider_aws.aws_prod_region"></a> [aws.aws\_prod\_region](#provider\_aws.aws\_prod\_region) | >= 4.0.0 |

## Modules

No modules.

## Resources

| Name | Type |
|------|------|
| [aws_backup_plan.dr_plan](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/backup_plan) | resource |
| [aws_backup_plan.prod_plan](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/backup_plan) | resource |
| [aws_backup_selection.dr_backup_selection](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/backup_selection) | resource |
| [aws_backup_selection.prod_backup_selection](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/backup_selection) | resource |
| [aws_backup_vault.dr_vault](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/backup_vault) | resource |
| [aws_backup_vault.prod_vault](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/backup_vault) | resource |
| [aws_iam_role.aws_backup_role](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/iam_role) | resource |
| [aws_iam_role_policy_attachment.backup](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/iam_role_policy_attachment) | resource |
| [aws_iam_role_policy_attachment.restores](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/iam_role_policy_attachment) | resource |
| [aws_kms_alias.dr_kms_alias](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/kms_alias) | resource |
| [aws_kms_alias.prod_kms_alias](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/kms_alias) | resource |
| [aws_kms_key.dr_key](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/kms_key) | resource |
| [aws_kms_key.prod_key](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/kms_key) | resource |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_backup_jobs"></a> [backup\_jobs](#input\_backup\_jobs) | List of backup jobs with associated vault details. | <pre>list(object({<br>    vault_name     = string<br>    vault_tags     = map(string)<br>    rule_name      = string<br>    schedule       = string<br>    dr_region      = bool<br>    prod_region    = bool<br>    retention_days = number<br>    selection_tag  = string<br>  }))</pre> | `[]` | no |
| <a name="input_dr_region_key"></a> [dr\_region\_key](#input\_dr\_region\_key) | Flag to indicate if the DR region should be used | `bool` | `false` | no |
| <a name="input_key_bypass_policy_lockout_safety_check"></a> [key\_bypass\_policy\_lockout\_safety\_check](#input\_key\_bypass\_policy\_lockout\_safety\_check) | (Optional) Specifies whether to disable the policy lockout check performed when creating or updating the key's policy. Setting this value to true increases the risk that the CMK becomes unmanageable. For more information, refer to the scenario in the Default Key Policy section in the AWS Key Management Service Developer Guide. Defaults to false. | `bool` | `false` | no |
| <a name="input_key_customer_master_key_spec"></a> [key\_customer\_master\_key\_spec](#input\_key\_customer\_master\_key\_spec) | (Optional) Specifies whether the key contains a symmetric key or an asymmetric key pair and the encryption algorithms or signing algorithms that the key supports. Valid values: SYMMETRIC\_DEFAULT, RSA\_2048, RSA\_3072, RSA\_4096, ECC\_NIST\_P256, ECC\_NIST\_P384, ECC\_NIST\_P521, or ECC\_SECG\_P256K1. Defaults to SYMMETRIC\_DEFAULT. For help with choosing a key spec, see the AWS KMS Developer Guide. | `string` | `"SYMMETRIC_DEFAULT"` | no |
| <a name="input_key_deletion_window_in_days"></a> [key\_deletion\_window\_in\_days](#input\_key\_deletion\_window\_in\_days) | (Optional) Duration in days after which the key is deleted after destruction of the resource, must be between 7 and 30 days. Defaults to 30 days. | `number` | `30` | no |
| <a name="input_key_description"></a> [key\_description](#input\_key\_description) | (Optional) The description of the key as viewed in AWS console. | `string` | `"AWS backups kms key used to encrypt backups"` | no |
| <a name="input_key_enable_key_rotation"></a> [key\_enable\_key\_rotation](#input\_key\_enable\_key\_rotation) | (Optional) Specifies whether key rotation is enabled. Defaults to false. | `bool` | `true` | no |
| <a name="input_key_is_enabled"></a> [key\_is\_enabled](#input\_key\_is\_enabled) | (Optional) Specifies whether the key is enabled. Defaults to true. | `string` | `true` | no |
| <a name="input_key_name"></a> [key\_name](#input\_key\_name) | (Optional) The display name of the alias. The name must start with the word 'alias' followed by a forward slash | `string` | `"alias/aws_backup_key"` | no |
| <a name="input_key_policy"></a> [key\_policy](#input\_key\_policy) | (Optional) A valid policy JSON document. Although this is a key policy, not an IAM policy, an aws\_iam\_policy\_document, in the form that designates a principal, can be used. For more information about building policy documents with Terraform, see the AWS IAM Policy Document Guide. | `string` | `null` | no |
| <a name="input_key_tags"></a> [key\_tags](#input\_key\_tags) | A mapping of tags to assign to the resource | `map(string)` | `{}` | no |
| <a name="input_key_usage"></a> [key\_usage](#input\_key\_usage) | (Optional) Specifies the intended use of the key. Defaults to ENCRYPT\_DECRYPT, and only symmetric encryption and decryption are supported. | `string` | `"ENCRYPT_DECRYPT"` | no |
| <a name="input_plan_tags"></a> [plan\_tags](#input\_plan\_tags) | A mapping of tags to assign to the resource | `map(string)` | `{}` | no |
| <a name="input_vault_tags"></a> [vault\_tags](#input\_vault\_tags) | A mapping of tags to assign to the resource | `map(string)` | `{}` | no |

## Outputs

No outputs.
<!-- END_TF_DOCS -->