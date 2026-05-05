<!-- Blank module readme template: Do a search and replace with your text editor for the following: `module_name`, `module_description` -->
<!-- Improved compatibility of back to top link: See: https://github.com/othneildrew/Best-README-Template/pull/73 -->

<a name="readme-top"></a>

<!-- PROJECT SHIELDS -->
<!--
*** I'm using markdown "reference style" links for readability.
*** Reference links are enclosed in brackets [ ] instead of parentheses ( ).
*** See the bottom of this document for the declaration of the reference variables
*** for contributors-url, forks-url, etc. This is an optional, concise syntax you may use.
*** https://www.markdownguide.org/basic-syntax/#reference-style-links
-->

[![Contributors][contributors-shield]][contributors-url]
[![Forks][forks-shield]][forks-url]
[![Stargazers][stars-shield]][stars-url]
[![Issues][issues-shield]][issues-url]
[![MIT License][license-shield]][license-url]
[![LinkedIn][linkedin-shield]][linkedin-url]

<!-- PROJECT LOGO -->
<br />
<div align="center">
  <a href="https://github.com/thinkstack-co/terraform-modules">
    <img src="/images/terraform_modules_logo.webp" alt="Logo" width="300" height="300">
  </a>

<h3 align="center">ThinkStack - AWS Backups Module</h3>
  <p align="center">
    This module sets AWS backup jobs and associated services.
    <br />
    <a href="https://github.com/thinkstack-co/terraform-modules"><strong>Explore the docs »</strong></a>
    <br />
    <br />
    <a href="https://www.thinkstack.co/">Think|Stack</a>
    ·
    <a href="https://github.com/thinkstack-co/terraform-modules/issues">Report Bug</a>
    ·
    <a href="https://github.com/thinkstack-co/terraform-modules/issues">Request Feature</a>
  </p>
</div>

<!-- TABLE OF CONTENTS -->
<details>
  <summary>Table of Contents</summary>
  <ol>
    <li><a href="#usage">Usage</a></li>
    <li><a href="#requirements">Requirements</a></li>
    <li><a href="#providers">Providers</a></li>
    <li><a href="#modules">Modules</a></li>
    <li><a href="#Resources">Resources</a></li>
    <li><a href="#inputs">Inputs</a></li>
    <li><a href="#outputs">Outputs</a></li>
    <li><a href="#license">License</a></li>
    <li><a href="#contact">Contact</a></li>
    <li><a href="#acknowledgments">Acknowledgments</a></li>
  </ol>
</details>

<!-- USAGE EXAMPLES -->

## Usage

### Simple Example

```
module "aws_prod_backups" {
    source           = "github.com/thinkstack-co/terraform-modules//modules/thinkstack/aws_backup"
    providers        = {
        aws.aws_prod_region = aws.aws_prod_region
        aws.aws_dr_region   = aws.aws_dr_region
    }
}
```

_For more examples, please refer to the [Documentation](https://github.com/thinkstack-co/terraform-modules)_

<p align="right">(<a href="#readme-top">back to top</a>)</p>

<!-- terraform-docs output will be input automatically below-->
<!-- terraform-docs markdown table --output-file README.md --output-mode inject .-->
<!-- BEGIN_TF_DOCS -->

## Requirements

| Name                                                                     | Version  |
| ------------------------------------------------------------------------ | -------- |
| <a name="requirement_terraform"></a> [terraform](#requirement_terraform) | >= 1.0.0 |
| <a name="requirement_aws"></a> [aws](#requirement_aws)                   | >= 4.0.0 |

## Providers

| Name                                                                                             | Version  |
| ------------------------------------------------------------------------------------------------ | -------- |
| <a name="provider_aws.aws_dr_region"></a> [aws.aws_dr_region](#provider_aws.aws_dr_region)       | >= 4.0.0 |
| <a name="provider_aws.aws_prod_region"></a> [aws.aws_prod_region](#provider_aws.aws_prod_region) | >= 4.0.0 |

## Modules

No modules.

## Resources

| Name                                                                                                                                                                       | Type     |
| -------------------------------------------------------------------------------------------------------------------------------------------------------------------------- | -------- |
| [aws_backup_plan.ec2_plan](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/backup_plan)                                                        | resource |
| [aws_backup_plan.plan](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/backup_plan)                                                            | resource |
| [aws_backup_selection.all_ec2](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/backup_selection)                                               | resource |
| [aws_backup_selection.all_resources](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/backup_selection)                                         | resource |
| [aws_backup_vault.vault_disaster_recovery](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/backup_vault)                                       | resource |
| [aws_backup_vault.vault_prod_daily](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/backup_vault)                                              | resource |
| [aws_backup_vault.vault_prod_hourly](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/backup_vault)                                             | resource |
| [aws_backup_vault.vault_prod_monthly](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/backup_vault)                                            | resource |
| [aws_backup_vault_lock_configuration.vault_disaster_recovery](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/backup_vault_lock_configuration) | resource |
| [aws_backup_vault_lock_configuration.vault_prod_daily](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/backup_vault_lock_configuration)        | resource |
| [aws_backup_vault_lock_configuration.vault_prod_hourly](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/backup_vault_lock_configuration)       | resource |
| [aws_backup_vault_lock_configuration.vault_prod_monthly](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/backup_vault_lock_configuration)      | resource |
| [aws_backup_vault_policy.vault_disaster_recovery](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/backup_vault_policy)                         | resource |
| [aws_backup_vault_policy.vault_prod_daily](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/backup_vault_policy)                                | resource |
| [aws_backup_vault_policy.vault_prod_hourly](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/backup_vault_policy)                               | resource |
| [aws_backup_vault_policy.vault_prod_monthly](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/backup_vault_policy)                              | resource |
| [aws_iam_role.backup](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/iam_role)                                                                | resource |
| [aws_iam_role_policy_attachment.backup](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/iam_role_policy_attachment)                            | resource |
| [aws_iam_role_policy_attachment.restores](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/iam_role_policy_attachment)                          | resource |
| [aws_kms_alias.alias](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/kms_alias)                                                               | resource |
| [aws_kms_alias.dr_alias](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/kms_alias)                                                            | resource |
| [aws_kms_key.dr_key](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/kms_key)                                                                  | resource |
| [aws_kms_key.key](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/kms_key)                                                                     | resource |

## Inputs

| Name                                                                                                                                                | Description                                                                                                                                                                                                                                                                                                                                                                                           | Type       | Default                                                                                                                                                    | Required |
| --------------------------------------------------------------------------------------------------------------------------------------------------- | ----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------- | ---------- | ---------------------------------------------------------------------------------------------------------------------------------------------------------- | :------: |
| <a name="input_backup_plan_completion_window"></a> [backup_plan_completion_window](#input_backup_plan_completion_window)                            | (Optional) The amount of time in minutes AWS Backup attempts a backup before canceling the job and returning an error. Default is set to 24 hours.                                                                                                                                                                                                                                                    | `number`   | `1440`                                                                                                                                                     |    no    |
| <a name="input_backup_plan_name"></a> [backup_plan_name](#input_backup_plan_name)                                                                   | (Required) The display name of a backup plan.                                                                                                                                                                                                                                                                                                                                                         | `string`   | `"prod_backups"`                                                                                                                                           |    no    |
| <a name="input_backup_plan_start_window"></a> [backup_plan_start_window](#input_backup_plan_start_window)                                           | (Optional) The amount of time in minutes before beginning a backup.                                                                                                                                                                                                                                                                                                                                   | `number`   | `60`                                                                                                                                                       |    no    |
| <a name="input_daily_backup_retention"></a> [daily_backup_retention](#input_daily_backup_retention)                                                 | (Required) The daily backup plan retention in days. By default this is 30 days                                                                                                                                                                                                                                                                                                                        | `number`   | `30`                                                                                                                                                       |    no    |
| <a name="input_dr_backup_retention"></a> [dr_backup_retention](#input_dr_backup_retention)                                                          | (Required) The dr backup plan retention in days. By default this is 7 days.                                                                                                                                                                                                                                                                                                                           | `number`   | `7`                                                                                                                                                        |    no    |
| <a name="input_ec2_backup_plan_name"></a> [ec2_backup_plan_name](#input_ec2_backup_plan_name)                                                       | (Required) The display name of a backup plan.                                                                                                                                                                                                                                                                                                                                                         | `string`   | `"ec2_prod_backups"`                                                                                                                                       |    no    |
| <a name="input_hourly_backup_retention"></a> [hourly_backup_retention](#input_hourly_backup_retention)                                              | (Required) The hourly backup plan retention in days. By default this is 3 days.                                                                                                                                                                                                                                                                                                                       | `number`   | `3`                                                                                                                                                        |    no    |
| <a name="input_key_bypass_policy_lockout_safety_check"></a> [key_bypass_policy_lockout_safety_check](#input_key_bypass_policy_lockout_safety_check) | (Optional) Specifies whether to disable the policy lockout check performed when creating or updating the key's policy. Setting this value to true increases the risk that the CMK becomes unmanageable. For more information, refer to the scenario in the Default Key Policy section in the AWS Key Management Service Developer Guide. Defaults to false.                                           | `bool`     | `false`                                                                                                                                                    |    no    |
| <a name="input_key_customer_master_key_spec"></a> [key_customer_master_key_spec](#input_key_customer_master_key_spec)                               | (Optional) Specifies whether the key contains a symmetric key or an asymmetric key pair and the encryption algorithms or signing algorithms that the key supports. Valid values: SYMMETRIC_DEFAULT, RSA_2048, RSA_3072, RSA_4096, ECC_NIST_P256, ECC_NIST_P384, ECC_NIST_P521, or ECC_SECG_P256K1. Defaults to SYMMETRIC_DEFAULT. For help with choosing a key spec, see the AWS KMS Developer Guide. | `string`   | `"SYMMETRIC_DEFAULT"`                                                                                                                                      |    no    |
| <a name="input_key_deletion_window_in_days"></a> [key_deletion_window_in_days](#input_key_deletion_window_in_days)                                  | (Optional) Duration in days after which the key is deleted after destruction of the resource, must be between 7 and 30 days. Defaults to 30 days.                                                                                                                                                                                                                                                     | `number`   | `30`                                                                                                                                                       |    no    |
| <a name="input_key_description"></a> [key_description](#input_key_description)                                                                      | (Optional) The description of the key as viewed in AWS console.                                                                                                                                                                                                                                                                                                                                       | `string`   | `"AWS backups kms key used to encrypt backups"`                                                                                                            |    no    |
| <a name="input_key_enable_key_rotation"></a> [key_enable_key_rotation](#input_key_enable_key_rotation)                                              | (Optional) Specifies whether key rotation is enabled. Defaults to false.                                                                                                                                                                                                                                                                                                                              | `bool`     | `true`                                                                                                                                                     |    no    |
| <a name="input_key_is_enabled"></a> [key_is_enabled](#input_key_is_enabled)                                                                         | (Optional) Specifies whether the key is enabled. Defaults to true.                                                                                                                                                                                                                                                                                                                                    | `string`   | `true`                                                                                                                                                     |    no    |
| <a name="input_key_name"></a> [key_name](#input_key_name)                                                                                           | (Optional) The display name of the alias. The name must start with the word 'alias' followed by a forward slash                                                                                                                                                                                                                                                                                       | `string`   | `"alias/aws_backup_key"`                                                                                                                                   |    no    |
| <a name="input_key_policy"></a> [key_policy](#input_key_policy)                                                                                     | (Optional) A valid policy JSON document. Although this is a key policy, not an IAM policy, an aws_iam_policy_document, in the form that designates a principal, can be used. For more information about building policy documents with Terraform, see the AWS IAM Policy Document Guide.                                                                                                              | `string`   | `null`                                                                                                                                                     |    no    |
| <a name="input_key_usage"></a> [key_usage](#input_key_usage)                                                                                        | (Optional) Specifies the intended use of the key. Defaults to ENCRYPT_DECRYPT, and only symmetric encryption and decryption are supported.                                                                                                                                                                                                                                                            | `string`   | `"ENCRYPT_DECRYPT"`                                                                                                                                        |    no    |
| <a name="input_monthly_backup_retention"></a> [monthly_backup_retention](#input_monthly_backup_retention)                                           | (Required) The daily backup plan retention in days. By default this is 365 days.                                                                                                                                                                                                                                                                                                                      | `number`   | `365`                                                                                                                                                      |    no    |
| <a name="input_tags"></a> [tags](#input_tags)                                                                                                       | (Optional) A mapping of tags to assign to the object.                                                                                                                                                                                                                                                                                                                                                 | `map(any)` | <pre>{<br> "aws_backup": "true",<br> "created_by": "ThinkStack",<br> "environment": "prod",<br> "priority": "critical",<br> "terraform": "true"<br>}</pre> |    no    |
| <a name="input_vault_disaster_recovery_name"></a> [vault_disaster_recovery_name](#input_vault_disaster_recovery_name)                               | value                                                                                                                                                                                                                                                                                                                                                                                                 | `string`   | `"vault_disaster_recovery"`                                                                                                                                |    no    |
| <a name="input_vault_prod_daily_name"></a> [vault_prod_daily_name](#input_vault_prod_daily_name)                                                    | value                                                                                                                                                                                                                                                                                                                                                                                                 | `string`   | `"vault_prod_daily"`                                                                                                                                       |    no    |
| <a name="input_vault_prod_hourly_name"></a> [vault_prod_hourly_name](#input_vault_prod_hourly_name)                                                 | value                                                                                                                                                                                                                                                                                                                                                                                                 | `string`   | `"vault_prod_hourly"`                                                                                                                                      |    no    |
| <a name="input_vault_prod_monthly_name"></a> [vault_prod_monthly_name](#input_vault_prod_monthly_name)                                              | value                                                                                                                                                                                                                                                                                                                                                                                                 | `string`   | `"vault_prod_monthly"`                                                                                                                                     |    no    |

## Outputs

| Name                                                                                                                 | Description |
| -------------------------------------------------------------------------------------------------------------------- | ----------- |
| <a name="output_vault_daily_arn"></a> [vault_daily_arn](#output_vault_daily_arn)                                     | n/a         |
| <a name="output_vault_disaster_recovery_arn"></a> [vault_disaster_recovery_arn](#output_vault_disaster_recovery_arn) | n/a         |
| <a name="output_vault_hourly_arn"></a> [vault_hourly_arn](#output_vault_hourly_arn)                                  | n/a         |
| <a name="output_vault_monthly_arn"></a> [vault_monthly_arn](#output_vault_monthly_arn)                               | n/a         |

<!-- END_TF_DOCS -->

<!-- LICENSE -->

## License

Distributed under the MIT License. See `LICENSE.txt` for more information.

<p align="right">(<a href="#readme-top">back to top</a>)</p>

<!-- CONTACT -->

## Contact

Think|Stack - [![LinkedIn][linkedin-shield]][linkedin-url] - info@thinkstack.co

Project Link: [https://github.com/thinkstack-co/terraform-modules](https://github.com/thinkstack-co/terraform-modules)

<p align="right">(<a href="#readme-top">back to top</a>)</p>

<!-- ACKNOWLEDGMENTS -->

## Acknowledgments

- [Zachary Hill](https://zacharyhill.co)
- [Jake Jones](https://github.com/jakeasarus)

<p align="right">(<a href="#readme-top">back to top</a>)</p>

<!-- MARKDOWN LINKS & IMAGES -->
<!-- https://www.markdownguide.org/basic-syntax/#reference-style-links -->

[contributors-shield]: https://img.shields.io/github/contributors/thinkstack-co/terraform-modules.svg?style=for-the-badge
[contributors-url]: https://github.com/thinkstack-co/terraform-modules/graphs/contributors
[forks-shield]: https://img.shields.io/github/forks/thinkstack-co/terraform-modules.svg?style=for-the-badge
[forks-url]: https://github.com/thinkstack-co/terraform-modules/network/members
[stars-shield]: https://img.shields.io/github/stars/thinkstack-co/terraform-modules.svg?style=for-the-badge
[stars-url]: https://github.com/thinkstack-co/terraform-modules/stargazers
[issues-shield]: https://img.shields.io/github/issues/thinkstack-co/terraform-modules.svg?style=for-the-badge
[issues-url]: https://github.com/thinkstack-co/terraform-modules/issues
[license-shield]: https://img.shields.io/github/license/thinkstack-co/terraform-modules.svg?style=for-the-badge
[license-url]: https://github.com/thinkstack-co/terraform-modules/blob/master/LICENSE.txt
[linkedin-shield]: https://img.shields.io/badge/-LinkedIn-black.svg?style=for-the-badge&logo=linkedin&colorB=555
[linkedin-url]: https://www.linkedin.com/company/thinkstack/
[product-screenshot]: /images/screenshot.webp
[Terraform.io]: https://img.shields.io/badge/Terraform-7B42BC?style=for-the-badge&logo=terraform
[Terraform-url]: https://terraform.io
