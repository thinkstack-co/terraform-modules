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

<!-- terraform-docs output will be input automatically below-->
<!-- terraform-docs markdown table --output-file README.md --output-mode inject .-->
<!-- BEGIN_TF_DOCS -->
# AWS Config Module

This Terraform module configures AWS Config to record and evaluate the configuration of your AWS resources. It provides compliance monitoring, resource inventory, and configuration history tracking.

## Features

- **AWS Config Recorder**: Records configuration changes for AWS resources
- **Delivery Channel**: Delivers configuration snapshots and history to S3
- **Compliance Reporting**: Generates configurable compliance reports (daily, weekly, or monthly)
- **Automatic Folder Organization**: Organizes reports into monthly folders (YYYY-MM format)
- **S3 Lifecycle Management**: Optional lifecycle rules for report retention and Glacier transitions
- **Config Rules**: Optional IAM password policy and EBS encryption rules
- **Notifications**: SNS notifications for compliance events

## Architecture

The module follows an opt-in architecture where:
- Basic AWS Config recording is enabled by default
- Additional features like compliance reports and lifecycle rules are disabled by default
- Resources are only created when explicitly enabled via variables

## Usage

### Complete Example with All Options

```hcl
module "aws_config" {
  source = "github.com/thinkstack-co/terraform-modules//modules/aws/config"

  # Basic Configuration
  config_recorder_name         = "example-config-recorder"
  config_bucket_prefix         = "example-config-recordings-"
  config_iam_role_name         = "example-config-role"
  include_global_resource_types = true
  tags = {
    Environment = "Production"
    Owner       = "Operations"
    Terraform   = "true"
  }

  # AWS Config Recording Settings
  recording_frequency         = "DAILY"  # How often AWS Config records configuration changes
  snapshot_delivery_frequency = "TwentyFour_Hours"  # How often AWS Config delivers snapshots
  s3_key_prefix               = "config"  # Base prefix for S3 bucket
  
  # Report Delivery Configuration
  create_compliance_report = true  # Whether to create compliance reports
  report_frequency         = "monthly"  # Options: daily, weekly, monthly
  report_delivery_schedule = "cron(0 8 1 * ? *)"  # 8:00 AM on the 1st day of every month
  
  # Notification Settings
  notification_email = "alerts@example.com"  # Email to receive notifications
  sns_topic_arn      = null  # Optional external SNS topic ARN (null to create a new one)
  customer_name      = "Acme Corp"  # Used in notification subjects
  
  # S3 Lifecycle Configuration
  enable_s3_lifecycle_rules = true  # Enable S3 lifecycle rules
  report_retention_days     = 365   # Keep reports for 1 year in standard storage
  enable_glacier_transition = true  # Enable transition to Glacier
  glacier_transition_days   = 90    # Move to Glacier after 90 days
  glacier_retention_days    = 730   # Delete from Glacier after 2 years
  
  # Password Policy Rules
  enable_config_rules       = true  # Enable AWS Config Rules
  password_min_length       = 16    # Minimum password length
  password_reuse_prevention = 24    # Number of previous passwords that can't be reused
  password_max_age          = 45    # Days before password must be changed
}
```

### Basic Example

```hcl
module "aws_config" {
  source = "github.com/thinkstack-co/terraform-modules//modules/aws/config"

  config_recorder_name = "prod-config-recorder"
  notification_email   = "alerts@example.com"
}
```

### Example with Daily Reports and 30-Day Retention

```hcl
module "aws_config" {
  source = "github.com/thinkstack-co/terraform-modules//modules/aws/config"

  config_recorder_name    = "prod-config-recorder"
  notification_email      = "alerts@example.com"
  
  # Configure daily reports
  create_compliance_report = true
  report_frequency        = "daily"
  
  # Set 30-day retention with no Glacier transition
  enable_s3_lifecycle_rules = true
  report_retention_days     = 30
  enable_glacier_transition = false
}
```

### Example with Weekly Reports and Glacier Archiving

```hcl
module "aws_config" {
  source = "github.com/thinkstack-co/terraform-modules//modules/aws/config"

  config_recorder_name    = "prod-config-recorder"
  notification_email      = "alerts@example.com"
  
  # Configure weekly reports on Mondays
  create_compliance_report = true
  report_frequency        = "weekly"
  
  # Set up Glacier archiving
  enable_s3_lifecycle_rules = true
  report_retention_days     = 0  # Don't delete from standard storage
  enable_glacier_transition = true
  glacier_transition_days   = 30  # Move to Glacier after 30 days
  glacier_retention_days    = 365 # Delete from Glacier after 1 year
}
```

_For more examples, please refer to the [Documentation](https://github.com/thinkstack-co/terraform-modules)_

<p align="right">(<a href="#readme-top">back to top</a>)</p>

## Report Delivery Schedule

The module automatically sets appropriate CloudWatch Event schedules based on the `report_frequency`:

- **daily**: Runs at 8:00 AM every day (`cron(0 8 * * ? *)`)
- **weekly**: Runs at 8:00 AM every Monday (`cron(0 8 ? * MON *)`)
- **monthly**: Runs at 8:00 AM on the 1st of every month (`cron(0 8 1 * ? *)`)

You can override these defaults by setting the `report_delivery_schedule` variable with your own cron expression.

### Customizing Cron Expressions

AWS CloudWatch Events uses a cron expression format with six required fields:

```
cron(minutes hours day-of-month month day-of-week year)
```

Here's how to customize each part of the cron expression:

#### Daily Reports

Default: `cron(0 8 * * ? *)`
- `0` - Minutes (0-59)
- `8` - Hours (0-23) in UTC
- `*` - Any day of month
- `*` - Any month
- `?` - No specific day of week
- `*` - Any year

To change the time to 2:30 PM UTC:
```
cron(30 14 * * ? *)
```

#### Weekly Reports

Default: `cron(0 8 ? * MON *)`
- `0` - Minutes (0-59)
- `8` - Hours (0-23) in UTC
- `?` - No specific day of month
- `*` - Any month
- `MON` - Monday (options: SUN, MON, TUE, WED, THU, FRI, SAT)
- `*` - Any year

To change to Friday at 9:15 AM UTC:
```
cron(15 9 ? * FRI *)
```

#### Monthly Reports

Default: `cron(0 8 1 * ? *)`
- `0` - Minutes (0-59)
- `8` - Hours (0-23) in UTC
- `1` - Day 1 of the month
- `*` - Any month
- `?` - No specific day of week
- `*` - Any year

To change to the 15th of each month at 12:00 PM UTC:
```
cron(0 12 15 * ? *)
```

#### Quarterly Reports

To run on the first day of each quarter (Jan, Apr, Jul, Oct) at 8:00 AM UTC:
```
cron(0 8 1 1,4,7,10 ? *)
```

#### Notes on Cron Expressions

- The `?` character is required in either the day-of-month or day-of-week field (but not both)
- All times are in UTC
- For day-of-week, both 1-7 (where 1 is Sunday) or SUN-SAT can be used
- Use commas to specify multiple values (e.g., `MON,WED,FRI`)
- Use hyphens for ranges (e.g., `1-15` for first half of the month)
- Use asterisk `*` to include all values
- Use forward slash with a number for "every x" (e.g., `*/2` for every 2nd value)

For more details on cron expressions, refer to the [AWS CloudWatch Events documentation](https://docs.aws.amazon.com/AmazonCloudWatch/latest/events/ScheduledEvents.html).

## Report Storage Organization

All reports are automatically organized into monthly folders using the format `YYYY-MM` (e.g., "2025-03"). 
This organization applies regardless of the report frequency, making it easy to locate reports for a specific month.

## Email Delivery

The module automatically sends compliance reports via email to the address specified in the `notification_email` variable. Here's how the email delivery works:

1. **Individual Report Emails**: 
   - Each time a compliance report is generated, an email notification is sent
   - Contains a link to download the specific compliance report from S3
   - Follows the schedule defined by `report_frequency` (daily, weekly, or monthly)
   - Emails arrive around 8:00 AM UTC on the scheduled day

2. **Monthly Summary Email**:
   - A monthly summary email is automatically sent on the 1st of each month at 8:15 AM UTC
   - Contains a link to the previous month's folder of reports
   - For example, on April 1st, you'll receive a summary email with a link to March's reports folder
   - This summary is sent regardless of your `report_frequency` setting
   - Provides a convenient way to access all reports from the previous month in one place

3. **Email Content**: Each email includes:
   - A subject line identifying the AWS account and report type
   - A link to access the report(s) from S3
   - The report's expiration date (if lifecycle rules are enabled)

4. **Customization**:
   - The `customer_name` variable can be set to identify the source of the report
   - The email subject will include this name (e.g., "Acme Corp - AWS Config Compliance Report")

5. **Report Links**:
   - Links in the email are pre-signed URLs that provide temporary access to the report
   - Links expire after 7 days by default
   - No AWS credentials are required to access the report via the link

## S3 Lifecycle Management

When enabled, the module can manage the lifecycle of your compliance reports:

1. **Standard Storage**: Reports are initially stored in S3 Standard
2. **Optional Glacier Transition**: Reports can transition to Glacier after a specified number of days
3. **Optional Expiration**: Reports can be deleted after a specified retention period

To disable automatic deletion, set `report_retention_days = 0`.

## Requirements

| Name | Version |
|------|---------|
| <a name="requirement_terraform"></a> [terraform](#requirement\_terraform) | >= 1.0.0 |
| <a name="requirement_aws"></a> [aws](#requirement\_aws) | >= 4.0.0 |

## Providers

| Name | Version |
|------|---------|
| <a name="provider_aws"></a> [aws](#provider\_aws) | >= 4.0.0 |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_config_bucket_prefix"></a> [config\_bucket\_prefix](#input\_config\_bucket\_prefix) | The prefix for the S3 bucket name where AWS Config delivers configuration snapshots and history files | `string` | `"aws-config-"` | no |
| <a name="input_config_iam_role_name"></a> [config\_iam\_role\_name](#input\_config\_iam\_role\_name) | The name of the IAM role that AWS Config will use to make read or write requests to the delivery channel and to call AWS Config API operations | `string` | `"aws-config-role"` | no |
| <a name="input_config_recorder_name"></a> [config\_recorder\_name](#input\_config\_recorder\_name) | The name of the AWS Config recorder | `string` | `"aws-config-recorder"` | no |
| <a name="input_enable_config_rules"></a> [enable\_config\_rules](#input\_enable\_config\_rules) | Whether to enable AWS Config rules | `bool` | `false` | no |
| <a name="input_include_global_resource_types"></a> [include\_global\_resource\_types](#input\_include\_global\_resource\_types) | Whether to include global resource types in AWS Config recording | `bool` | `true` | no |
| <a name="input_password_max_age"></a> [password\_max\_age](#input\_password\_max\_age) | The maximum age in days for IAM user passwords | `number` | `90` | no |
| <a name="input_password_min_length"></a> [password\_min\_length](#input\_password\_min\_length) | The minimum length for IAM user passwords | `number` | `14` | no |
| <a name="input_password_require_lowercase"></a> [password\_require\_lowercase](#input\_password\_require\_lowercase) | Whether IAM user passwords must contain at least one lowercase letter | `bool` | `true` | no |
| <a name="input_password_require_numbers"></a> [password\_require\_numbers](#input\_password\_require\_numbers) | Whether IAM user passwords must contain at least one number | `bool` | `true` | no |
| <a name="input_password_require_symbols"></a> [password\_require\_symbols](#input\_password\_require\_symbols) | Whether IAM user passwords must contain at least one symbol | `bool` | `true` | no |
| <a name="input_password_require_uppercase"></a> [password\_require\_uppercase](#input\_password\_require\_uppercase) | Whether IAM user passwords must contain at least one uppercase letter | `bool` | `true` | no |
| <a name="input_password_reuse_prevention"></a> [password\_reuse\_prevention](#input\_password\_reuse\_prevention) | The number of previous passwords that IAM users are prevented from reusing | `number` | `24` | no |
| <a name="input_recording_frequency"></a> [recording\_frequency](#input\_recording\_frequency) | The frequency with which AWS Config records configuration changes (CONTINUOUS or DAILY) | `string` | `"CONTINUOUS"` | no |
| <a name="input_s3_key_prefix"></a> [s3\_key\_prefix](#input\_s3\_key\_prefix) | The prefix for the S3 bucket where AWS Config delivers configuration snapshots and history files | `string` | `"config"` | no |
| <a name="input_sns_topic_arn"></a> [sns\_topic\_arn](#input\_sns\_topic\_arn) | The ARN of the SNS topic that AWS Config delivers notifications to | `string` | `null` | no |
| <a name="input_snapshot_delivery_frequency"></a> [snapshot\_delivery\_frequency](#input\_snapshot\_delivery\_frequency) | The frequency with which AWS Config delivers configuration snapshots (One_Hour, Three_Hours, Six_Hours, Twelve_Hours, TwentyFour_Hours) | `string` | `"TwentyFour_Hours"` | no |
| <a name="input_notification_email"></a> [notification\_email](#input\_notification\_email) | Email address to receive compliance notifications | `string` | `"support@thinkstack.co"` | no |
| <a name="input_create_compliance_report"></a> [create\_compliance\_report](#input\_create\_compliance\_report) | Whether to create a compliance report sent via email based on the report_frequency setting | `bool` | `true` | no |
| <a name="input_customer_name"></a> [customer\_name](#input\_customer\_name) | Name of the customer whose AWS account this is being deployed in, used to identify the source of compliance reports | `string` | `""` | no |
| <a name="input_report_delivery_schedule"></a> [report\_delivery\_schedule](#input\_report\_delivery\_schedule) | Cron expression for when to deliver the config report (default is 8:00 AM on the 1st day of every month) | `string` | `"cron(0 8 1 * ? *)"` | no |
| <a name="input_report_frequency"></a> [report\_frequency](#input\_report\_frequency) | Frequency of config report generation (daily, weekly, or monthly) | `string` | `"monthly"` | no |
| <a name="input_enable_s3_lifecycle_rules"></a> [enable\_s3\_lifecycle\_rules](#input\_enable\_s3\_lifecycle\_rules) | Whether to enable S3 lifecycle rules for config reports | `bool` | `false` | no |
| <a name="input_report_retention_days"></a> [report\_retention\_days](#input\_report\_retention\_days) | Number of days to retain config reports in S3 before deletion (set to 0 to disable deletion) | `number` | `365` | no |
| <a name="input_enable_glacier_transition"></a> [enable\_glacier\_transition](#input\_enable\_glacier\_transition) | Whether to transition config reports to Glacier storage class | `bool` | `false` | no |
| <a name="input_glacier_transition_days"></a> [glacier\_transition\_days](#input\_glacier\_transition\_days) | Number of days after which to transition config reports to Glacier storage class | `number` | `90` | no |
| <a name="input_glacier_retention_days"></a> [glacier\_retention\_days](#input\_glacier\_retention\_days) | Number of days to retain config reports in Glacier before deletion (set to 0 to disable deletion) | `number` | `730` | no |
| <a name="input_tags"></a> [tags](#input\_tags) | A map of tags to add to all resources | `map(string)` | `{}` | no |

## Outputs

| Name | Description |
|------|-------------|
| <a name="output_config_bucket_arn"></a> [config\_bucket\_arn](#output\_config\_bucket\_arn) | The ARN of the S3 bucket used for AWS Config recordings |
| <a name="output_config_bucket_id"></a> [config\_bucket\_id](#output\_config\_bucket\_id) | The ID of the S3 bucket used for AWS Config recordings |
| <a name="output_config_iam_role_arn"></a> [config\_iam\_role\_arn](#output\_config\_iam\_role\_arn) | The ARN of the IAM role used for AWS Config |
| <a name="output_config_notification_topic_arn"></a> [config\_notification\_topic\_arn](#output\_config\_notification\_topic\_arn) | The ARN of the SNS topic used for AWS Config notifications |
| <a name="output_config_recorder_id"></a> [config\_recorder\_id](#output\_config\_recorder\_id) | The ID of the AWS Config recorder |
| <a name="output_config_rules_arns"></a> [config\_rules\_arns](#output\_config\_rules\_arns) | Map of all Config rules ARNs |
| <a name="output_compliance_report_rule_arn"></a> [compliance\_report\_rule\_arn](#output\_compliance\_report\_rule\_arn) | The ARN of the CloudWatch event rule for compliance reports |
| <a name="output_delivery_channel_id"></a> [delivery\_channel\_id](#output\_delivery\_channel\_id) | The ID of the AWS Config delivery channel |
| <a name="output_ebs_encryption_rule_arn"></a> [ebs\_encryption\_rule\_arn](#output\_ebs\_encryption\_rule\_arn) | The ARN of the EBS encryption Config rule |
| <a name="output_password_policy_rule_arn"></a> [password\_policy\_rule\_arn](#output\_password\_policy\_rule\_arn) | The ARN of the IAM password policy Config rule |
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
