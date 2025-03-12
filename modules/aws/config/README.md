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

<h3 align="center">AWS Config Module</h3>
  <p align="center">
    Module for deploying AWS Config with configuration recorder, delivery channel, and config rules
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

```hcl
module "aws_config" {
    source = "github.com/thinkstack-co/terraform-modules//modules/aws/config"

    config_recorder_name         = "example-config-recorder"
    config_bucket_prefix         = "example-config-bucket-"
    include_global_resource_types = true
    enable_config_rules          = true
    recording_frequency          = "DAILY"
    snapshot_delivery_frequency  = "TwentyFour_Hours"
    s3_key_prefix                = "config"
    notification_email           = "support@thinkstack.co"
    create_monthly_compliance_report = true
    customer_name                = "Acme Corp"
    tags                         = {
        terraform   = "true"
        created_by  = "Terraform"
        environment = "prod"
        role        = "security"
    }
}
```

_For more examples, please refer to the [Documentation](https://github.com/thinkstack-co/terraform-modules)_

<p align="right">(<a href="#readme-top">back to top</a>)</p>

<!-- terraform-docs output will be input automatically below-->
<!-- terraform-docs markdown table --output-file README.md --output-mode inject .-->
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

## Modules

No modules.

## Resources

| Name | Type | AWS Documentation |
|------|------|------------------|
| [aws_config_configuration_recorder.config](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/config_configuration_recorder) | resource | [AWS Config Configuration Recorder](https://docs.aws.amazon.com/config/latest/developerguide/config-concepts.html#config-recorder) |
| [aws_config_configuration_recorder_status.config](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/config_configuration_recorder_status) | resource | [AWS Config Recorder Status](https://docs.aws.amazon.com/config/latest/developerguide/config-concepts.html#recorder-status) |
| [aws_config_delivery_channel.config](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/config_delivery_channel) | resource | [AWS Config Delivery Channel](https://docs.aws.amazon.com/config/latest/developerguide/config-concepts.html#delivery-channel) |
| [aws_config_config_rule.iam_password_policy](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/config_config_rule) | resource | [AWS Config Rules](https://docs.aws.amazon.com/config/latest/developerguide/evaluate-config.html) |
| [aws_config_config_rule.ebs_encrypted_volumes](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/config_config_rule) | resource | [AWS Config Rules](https://docs.aws.amazon.com/config/latest/developerguide/evaluate-config.html) |
| [aws_iam_role.config_role](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/iam_role) | resource | [IAM Roles](https://docs.aws.amazon.com/IAM/latest/UserGuide/id_roles.html) |
| [aws_iam_role_policy.config_policy](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/iam_role_policy) | resource | [IAM Policy Attachments](https://docs.aws.amazon.com/IAM/latest/UserGuide/access_policies_manage-attach-detach.html) |
| [aws_s3_bucket.config_bucket](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/s3_bucket) | resource | [S3 Buckets](https://docs.aws.amazon.com/AmazonS3/latest/userguide/UsingBucket.html) |
| [aws_s3_bucket_policy.config](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/s3_bucket_policy) | resource | [S3 Bucket Policies](https://docs.aws.amazon.com/AmazonS3/latest/userguide/bucket-policies.html) |
| [aws_sns_topic.config_notifications](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/sns_topic) | resource | [SNS Topics](https://docs.aws.amazon.com/sns/latest/dg/sns-create-topic.html) |
| [aws_sns_topic_policy.config_notifications](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/sns_topic_policy) | resource | [SNS Topic Policies](https://docs.aws.amazon.com/sns/latest/dg/sns-access-policy-language-api-permissions-reference.html) |
| [aws_sns_topic_subscription.config_email_subscription](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/sns_topic_subscription) | resource | [SNS Subscriptions](https://docs.aws.amazon.com/sns/latest/dg/sns-create-subscribe-endpoint-to-topic.html) |
| [aws_cloudwatch_event_rule.monthly_compliance_report](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/cloudwatch_event_rule) | resource | [CloudWatch Event Rules](https://docs.aws.amazon.com/eventbridge/latest/userguide/eb-create-rule.html) |
| [aws_cloudwatch_event_target.monthly_compliance_report](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/cloudwatch_event_target) | resource | [CloudWatch Event Targets](https://docs.aws.amazon.com/eventbridge/latest/userguide/eb-targets.html) |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_config_recorder_name"></a> [config\_recorder\_name](#input\_config\_recorder\_name) | Name of the AWS Config recorder | `string` | `"aws_config_recorder"` | no |
| <a name="input_config_bucket_prefix"></a> [config\_bucket\_prefix](#input\_config\_bucket\_prefix) | Name of the S3 bucket for AWS Config recordings | `string` | `"aws-config-recordings-"` | no |
| <a name="input_config_iam_role_name"></a> [config\_iam\_role\_name](#input\_config\_iam\_role\_name) | Name of the IAM role for AWS Config | `string` | `"aws-config-role"` | no |
| <a name="input_include_global_resource_types"></a> [include\_global\_resource\_types](#input\_include\_global\_resource\_types) | Specifies whether AWS Config includes all supported types of global resources with the resources that it records | `bool` | `true` | no |
| <a name="input_tags"></a> [tags](#input\_tags) | A map of tags to add to all resources | `map(string)` | `{}` | no |
| <a name="input_password_min_length"></a> [password\_min\_length](#input\_password\_min\_length) | Minimum length for IAM user passwords | `number` | `16` | no |
| <a name="input_password_reuse_prevention"></a> [password\_reuse\_prevention](#input\_password\_reuse\_prevention) | Number of previous passwords that users are prevented from reusing | `number` | `24` | no |
| <a name="input_password_max_age"></a> [password\_max\_age](#input\_password\_max\_age) | Maximum age in days before password must be changed | `number` | `45` | no |
| <a name="input_enable_config_rules"></a> [enable\_config\_rules](#input\_enable\_config\_rules) | Enable or disable AWS Config Rules | `bool` | `true` | no |
| <a name="input_recording_frequency"></a> [recording\_frequency](#input\_recording\_frequency) | The frequency with which AWS Config records information | `string` | `"DAILY"` | no |
| <a name="input_s3_key_prefix"></a> [s3\_key\_prefix](#input\_s3\_key\_prefix) | The prefix for the S3 bucket where AWS Config delivers configuration snapshots and history files | `string` | `"config"` | no |
| <a name="input_sns_topic_arn"></a> [sns\_topic\_arn](#input\_sns\_topic\_arn) | The ARN of the SNS topic that AWS Config delivers notifications to | `string` | `null` | no |
| <a name="input_snapshot_delivery_frequency"></a> [snapshot\_delivery\_frequency](#input\_snapshot\_delivery\_frequency) | The frequency with which AWS Config delivers configuration snapshots (One_Hour, Three_Hours, Six_Hours, Twelve_Hours, TwentyFour_Hours) | `string` | `"TwentyFour_Hours"` | no |
| <a name="input_notification_email"></a> [notification\_email](#input\_notification\_email) | Email address to receive monthly non-compliance notifications | `string` | `"support@thinkstack.co"` | no |
| <a name="input_create_monthly_compliance_report"></a> [create\_monthly\_compliance\_report](#input\_create\_monthly\_compliance\_report) | Whether to create a monthly compliance report sent via email | `bool` | `true` | no |
| <a name="input_customer_name"></a> [customer\_name](#input\_customer\_name) | Name of the customer whose AWS account this is being deployed in, used to identify the source of compliance reports | `string` | `""` | no |

## Outputs

| Name | Description |
|------|-------------|
| <a name="output_config_recorder_id"></a> [config\_recorder\_id](#output\_config\_recorder\_id) | The ID of the AWS Config recorder |
| <a name="output_config_bucket_id"></a> [config\_bucket\_id](#output\_config\_bucket\_id) | The ID of the S3 bucket used for AWS Config recordings |
| <a name="output_config_iam_role_arn"></a> [config\_iam\_role\_arn](#output\_config\_iam\_role\_arn) | The ARN of the IAM role used by AWS Config |
| <a name="output_config_rule_ids"></a> [config\_rule\_ids](#output\_config\_rule\_ids) | The IDs of the AWS Config rules |
| <a name="output_delivery_channel_id"></a> [delivery\_channel\_id](#output\_delivery\_channel\_id) | The ID of the AWS Config delivery channel |
| <a name="output_config_notification_topic_arn"></a> [config\_notification\_topic\_arn](#output\_config\_notification\_topic\_arn) | The ARN of the SNS topic used for AWS Config notifications |
| <a name="output_monthly_compliance_report_rule_arn"></a> [monthly\_compliance\_report\_rule\_arn](#output\_monthly\_compliance\_report\_rule\_arn) | The ARN of the CloudWatch event rule for monthly compliance reports |
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

* [Wesley Bey](https://github.com/beywesley)

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
