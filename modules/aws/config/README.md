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
    Module for deploying AWS Config with configuration recorder, delivery channel to S3, and optional config rules.
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

## Complete Example Usage

```hcl
module "example_aws_config" {
  source = "github.com/thinkstack-co/terraform-modules//modules/aws/config?ref=dev-config"

  # Core settings
  customer_name         = "Acme Corp" # Optional: label for easier identification in reports and tags
  config_recorder_name  = "example-config-recorder"
  config_bucket_prefix  = "example-config-bucket-"
  config_iam_role_name  = "example-config-role"
  recording_frequency   = "DAILY"

  # --- Config Rules (opt-in for each rule) ---
  enable_iam_password_policy_rule   = true
  # IAM password policy arguments (only needed if the rule above is enabled)
  password_min_length       = 16
  password_reuse_prevention = 24
  password_max_age          = 45

  enable_encrypted_volumes_rule     = true
  enable_ebs_encryption_rule        = true
  enable_s3_public_access_rules     = true
  enable_iam_root_key_rule          = true
  enable_mfa_for_iam_console_rule   = true
  enable_ec2_volume_inuse_rule      = true
  enable_eip_attached_rule          = true
  enable_rds_storage_encrypted_rule = true

  # --- S3 Lifecycle and Retention ---
  enable_s3_lifecycle_rules = true
  report_retention_days     = 30
  enable_glacier_transition = true
  glacier_transition_days   = 90

  snapshot_delivery_frequency = "TwentyFour_Hours"
  s3_key_prefix               = "config"

  # --- Compliance reporter Lambda (optional) ---
  enable_compliance_reporter   = true
  reporter_schedule_expression = "cron(0 8 ? * WED *)" # Run every Wednesday at 8 AM UTC
  reporter_output_s3_prefix    = "compliance-reports/weekly/"

  # --- Tags ---
  tags = {
    Environment = "prod"
    Project     = "config"
    Owner       = "security-team"
  }
}
```
## Compliance Reporter Account Name Logic

By default, the compliance reporter Lambda will attempt to display the AWS account's display name at the top of each report. The logic for determining the account name is as follows:

1. **AWS Organizations Account Name:**
   - If the Lambda function has access to the Organizations API, it will use the display name from AWS Organizations (the friendly name you see in the AWS SSO/Access Portal).
2. **Environment Variable Override:**
   - If the Organizations API is not accessible (e.g., due to permissions or SCPs), you can set the `account_display_name` variable in this module. This value will be passed to the Lambda as the `ACCOUNT_DISPLAY_NAME` environment variable and used in the report.
   - Example:

     ```hcl
     module "aws_config" {
       # ...
       account_display_name = "example-account-display-name"
     }
     ```
3. **IAM Account Alias Fallback:**
   - If neither of the above is available, the Lambda will fall back to using the IAM account alias (if set).
4. **N/A:**
   - If none of the above are available, the report will show `N/A` for the account name.

**This gives you full control and ensures the correct account name is always displayed in compliance reports, even in restricted environments.**

### Example Usage with Display Name

```hcl
module "aws_config" {
  # ...
  enable_compliance_reporter = true
  account_display_name       = "example-account-display-name" # Optional, for environments without Organizations API access
}
```

<!-- terraform-docs output will be input automatically below-->
<!-- terraform-docs markdown table --output-file README.md --output-mode inject .-->
<!-- BEGIN_TF_DOCS -->
# AWS Config Module

This Terraform module configures AWS Config to record and evaluate the configuration of your AWS resources. It establishes continuous monitoring, resource inventory, and configuration history tracking, storing data in an S3 bucket.

## Features

*   Sets up AWS Config Configuration Recorder and Delivery Channel.
*   Creates an S3 bucket for storing configuration snapshots and history.
*   Records specific resource types (`AWS::EC2::Volume`, `AWS::IAM::User`) required for the optional rules, including global IAM types.
*   Optionally enables AWS Managed Config rules:
    *   `IAM_PASSWORD_POLICY`: Checks account password policy.
    *   `ENCRYPTED_VOLUMES`: Checks if attached EBS volumes are encrypted.
    *   `S3_BUCKET_PUBLIC_READ_PROHIBITED`: Checks that your S3 buckets do not allow public read access.
    *   `S3_BUCKET_PUBLIC_WRITE_PROHIBITED`: Checks that your S3 buckets do not allow public write access.
    *   `ROOT_ACCOUNT_MFA_ENABLED`: Checks whether the root user requires MFA.
    *   `MFA_ENABLED_FOR_IAM_CONSOLE_ACCESS`: Checks whether IAM users with console passwords have MFA enabled.
    *   `EC2_VOLUME_INUSE_CHECK`: Checks whether EBS volumes are attached to EC2 instances.
    *   `EIP_ATTACHED`: Checks whether Elastic IP addresses are attached.
    *   `RDS_STORAGE_ENCRYPTED`: Checks whether storage encryption is enabled for RDS DB instances.
*   Optionally deploys a Lambda function to generate scheduled PDF compliance reports summarizing the status of Config Rules and storing them in the Config S3 bucket.

## Architecture

The module follows an opt-in architecture where:
- Basic AWS Config recording to S3 is enabled by default.
- Additional features like AWS Config Rules and S3 lifecycle management are disabled by default and can be enabled via input variables.
- Resources are only created when explicitly enabled.

## Usage

### Basic Example (Core Recording to S3)

```hcl
module "aws_config" {
  source = "github.com/thinkstack-co/terraform-modules//modules/aws/config"

  # Required names (can use defaults)
  config_recorder_name = "my-config-recorder"
  config_bucket_prefix = "my-config-recordings-"
  config_iam_role_name = "my-config-role"

  # Optional: Add tags
  tags = {
    Environment = "Production"
    Terraform   = "true"
  }
}
```

### Example with Config Rules Enabled

```hcl
module "aws_config" {
  source = "github.com/thinkstack-co/terraform-modules//modules/aws/config"

  config_recorder_name = "prod-config-recorder"

  # Enable Config Rules
  enable_config_rules       = true
  password_min_length       = 16  # Customize password policy rules
  password_reuse_prevention = 24
  password_max_age          = 45

  tags = {
    CostCenter = "IT-Security"
  }
}
```

### Example with S3 Lifecycle Rules (Retention & Glacier)

```hcl
module "aws_config" {
  source = "github.com/thinkstack-co/terraform-modules//modules/aws/config"

  config_recorder_name = "prod-config-recorder"

  # Configure S3 Lifecycle
  enable_s3_lifecycle_rules = true
  report_retention_days     = 365   # Keep data for 1 year in standard storage
  enable_glacier_transition = true  # Enable transition to Glacier Deep Archive
  glacier_transition_days   = 90    # Move to Glacier after 90 days
  glacier_retention_days    = 2555  # Keep in Glacier for 7 years (approx)
}
```

### Example 2: Enabling Compliance Reporter with Custom Settings

```hcl
module "aws_config_with_reporter" {
  source = "../../modules/aws/config" # Adjust path as needed

  config_recorder_name = "my-app-config-recorder-with-report"
  config_iam_role_name = "my-app-config-role-with-report"
  config_bucket_prefix = "my-app-config-delivery-"

  # Enable the core rules
  enable_config_rules = true

  # Enable and configure the compliance reporter
  enable_compliance_reporter = true
  reporter_schedule_expression = "cron(0 8 ? * MON *)" # Run every Monday at 8 AM UTC
  reporter_output_s3_prefix  = "compliance-reports/weekly/"
  reporter_lambda_memory_size = 512 # Increase memory
  reporter_lambda_timeout     = 180 # Increase timeout

  tags = {
    Environment = "production"
    Project     = "ComplianceReporting"
  }
}
```

### Example 3: Basic Setup with All Rules Enabled

```hcl
module "aws_config_all_rules" {
  source = "../../modules/aws/config"

  config_bucket_prefix = "my-org-config-"
  config_recorder_name = "my-org-recorder"

  # Enable specific rules (Explicitly setting defaults for clarity)
  enable_encrypted_volumes_rule    = true
  enable_iam_password_policy_rule  = true
  enable_s3_public_access_rules    = true
  enable_iam_root_key_rule         = true
  enable_mfa_for_iam_console_rule  = true
  enable_ec2_volume_inuse_rule     = true
  enable_eip_attached_rule         = true
  enable_rds_storage_encrypted_rule= true

  # Compliance reporter is disabled by default
  enable_compliance_reporter       = false

  tags = {
    Environment = "Development"
    ManagedBy   = "Terraform"
  }
}
```

_For detailed variable and output descriptions, please refer to the Inputs and Outputs sections below (these are auto-generated by terraform-docs)._

<p align="right">(<a href="#readme-top">back to top</a>)</p>

## Resources

| Name | Type | Documentation |
|------|------|---------------|
| [aws_config_configuration_recorder.config](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/config_configuration_recorder) | resource | [AWS Config Recorder Docs](https://docs.aws.amazon.com/config/latest/developerguide/config-concepts.html#config-recorder) |
| [aws_config_config_rule.ebs_encryption](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/config_config_rule) | resource | [AWS Config Rules Docs](https://docs.aws.amazon.com/config/latest/developerguide/evaluate-config_use-managed-rules.html) |
| [aws_config_config_rule.iam_password_policy](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/config_config_rule) | resource | [AWS Config Rules Docs](https://docs.aws.amazon.com/config/latest/developerguide/evaluate-config_use-managed-rules.html) |
| [aws_config_delivery_channel.config](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/config_delivery_channel) | resource | [AWS Config Delivery Channel Docs](https://docs.aws.amazon.com/config/latest/developerguide/config-concepts.html#delivery-channel) |
| [aws_config_configuration_recorder_status.config](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/config_configuration_recorder_status) | resource | [AWS Config Recorder Status Docs](https://docs.aws.amazon.com/config/latest/developerguide/stop-start-recorder.html) |
| [aws_iam_role.config_role](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/iam_role) | resource | [AWS IAM Roles Docs](https://docs.aws.amazon.com/IAM/latest/UserGuide/id_roles.html) |
| [aws_iam_role_policy_attachment.config](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/iam_role_policy_attachment) | resource | [AWS IAM Policy Attachment Docs](https://docs.aws.amazon.com/IAM/latest/UserGuide/access_policies_manage-attach-detach.html#add-policies-console) |
| [aws_s3_bucket.config_bucket](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/s3_bucket) | resource | [AWS S3 Bucket Docs](https://docs.aws.amazon.com/AmazonS3/latest/userguide/creating-buckets.html) |
| [aws_s3_bucket_lifecycle_configuration.config_lifecycle](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/s3_bucket_lifecycle_configuration) | resource | [AWS S3 Lifecycle Docs](https://docs.aws.amazon.com/AmazonS3/latest/userguide/object-lifecycle-mgmt.html) |
| [aws_s3_bucket_policy.config](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/s3_bucket_policy) | resource | [AWS S3 Policy Docs](https://docs.aws.amazon.com/AmazonS3/latest/userguide/access-policy-language-overview.html) |
| [aws_caller_identity.current](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/caller_identity) | data source | [AWS STS Caller Identity Docs](https://docs.aws.amazon.com/STS/latest/APIReference/API_GetCallerIdentity.html) |
| [aws_iam_policy_document.config_assume_role](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/iam_policy_document) | data source | [IAM Policy Document Docs](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/iam_policy_document) |
| [aws_iam_policy_document.config_bucket_policy](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/iam_policy_document) | data source | [IAM Policy Document Docs](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/iam_policy_document) |
| [aws_iam_policy_document.reporter_lambda_assume_role](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/iam_policy_document) | data source | *(conditional)* [IAM Policy Document Docs](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/iam_policy_document) |
| [aws_iam_policy_document.reporter_lambda_policy](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/iam_policy_document) | data source | *(conditional)* [IAM Policy Document Docs](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/iam_policy_document) |
| [aws_iam_role.reporter_lambda_role](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/iam_role) | resource | *(conditional)* [AWS IAM Roles Docs](https://docs.aws.amazon.com/IAM/latest/UserGuide/id_roles.html) |
| [aws_iam_role_policy.reporter_lambda_policy](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/iam_role_policy) | resource | *(conditional)* [AWS IAM Role Policy Docs](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/iam_role_policy) |
| [aws_lambda_function.compliance_reporter](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/lambda_function) | resource | *(conditional)* [AWS Lambda Function Docs](https://docs.aws.amazon.com/lambda/latest/dg/lambda-functions.html) |
| [aws_cloudwatch_event_rule.reporter_schedule](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/cloudwatch_event_rule) | resource | *(conditional)* [CloudWatch Event Rule Docs](https://docs.aws.amazon.com/AmazonCloudWatch/latest/events/WhatIsCloudWatchEvents.html) |
| [aws_cloudwatch_event_target.reporter_lambda_target](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/cloudwatch_event_target) | resource | *(conditional)* [CloudWatch Event Target Docs](https://docs.aws.amazon.com/AmazonCloudWatch/latest/events/WhatIsCloudWatchEvents.html) |
| [aws_lambda_permission.allow_cloudwatch](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/lambda_permission) | resource | *(conditional)* [Lambda Permission Docs](https://docs.aws.amazon.com/lambda/latest/dg/access-control-resource-based.html) |
| [archive_file.lambda_compliance_reporter_zip](https://registry.terraform.io/providers/hashicorp/archive/latest/docs/data-sources/archive_file) | data source | *(conditional)* [Archive File Data Source Docs](https://registry.terraform.io/providers/hashicorp/archive/latest/docs/data-sources/archive_file) |

## Requirements

| Name | Version |
|------|---------|
| <a name="requirement_terraform"></a> [terraform](#requirement\_terraform) | >= 1.0.0 |
| <a name="requirement_aws"></a> [aws](#requirement\_aws) | >= 5.0 |

## Providers

| Name | Version |
|------|---------|
| <a name="provider_aws"></a> [aws](#provider\_aws) | >= 5.0 |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_config_bucket_prefix"></a> [config\_bucket\_prefix](#input\_config\_bucket\_prefix) | The prefix for the S3 bucket name where AWS Config delivers configuration snapshots and history files | `string` | `"aws-config-"` | no |
| <a name="input_config_iam_role_name"></a> [config\_iam\_role\_name](#input\_config\_iam\_role\_name) | The name of the IAM role that AWS Config will use to make read or write requests to the delivery channel and to call AWS Config API operations | `string` | `"aws-config-role"` | no |
| <a name="input_config_recorder_name"></a> [config\_recorder\_name](#input\_config\_recorder\_name) | The name of the AWS Config recorder | `string` | `"aws-config-recorder"` | no |
| <a name="input_enable_config_rules"></a> [enable\_config\_rules](#input\_enable\_config\_rules) | Whether to enable AWS Config rules | `bool` | `false` | no |
| <a name="input_password_max_age"></a> [password\_max\_age](#input\_password\_max\_age) | The maximum age in days for IAM user passwords | `number` | `90` | no |
| <a name="input_password_min_length"></a> [password\_min\_length](#input\_password\_min\_length) | The minimum length for IAM user passwords | `number` | `14` | no |
| <a name="input_password_require_lowercase"></a> [password\_require\_lowercase](#input\_password\_require\_lowercase) | Whether IAM user passwords must contain at least one lowercase letter | `bool` | `true` | no |
| <a name="input_password_require_numbers"></a> [password\_require\_numbers](#input\_password\_require\_numbers) | Whether IAM user passwords must contain at least one number | `bool` | `true` | no |
| <a name="input_password_require_symbols"></a> [password\_require\_symbols](#input\_password\_require\_symbols) | Whether IAM user passwords must contain at least one symbol | `bool` | `true` | no |
| <a name="input_password_require_uppercase"></a> [password\_require\_uppercase](#input\_password\_require\_uppercase) | Whether IAM user passwords must contain at least one uppercase letter | `bool` | `true` | no |
| <a name="input_password_reuse_prevention"></a> [password\_reuse\_prevention](#input\_password\_reuse\_prevention) | The number of previous passwords that IAM users are prevented from reusing | `number` | `24` | no |
| <a name="input_recording_frequency"></a> [recording\_frequency](#input\_recording\_frequency) | The frequency with which AWS Config records configuration changes (CONTINUOUS or DAILY) | `string` | `"CONTINUOUS"` | no |
| <a name="input_s3_key_prefix"></a> [s3\_key\_prefix](#input\_s3\_key\_prefix) | The prefix for the S3 bucket where AWS Config delivers configuration snapshots and history files | `string` | `"config"` | no |
| <a name="input_enable_s3_lifecycle_rules"></a> [enable\_s3\_lifecycle\_rules](#input\_enable\_s3\_lifecycle\_rules) | Whether to enable S3 lifecycle rules for config reports | `bool` | `false` | no |
| <a name="input_report_retention_days"></a> [report\_retention\_days](#input\_report\_retention\_days) | Number of days to retain config reports in S3 before deletion (set to 0 to disable deletion) | `number` | `365` | no |
| <a name="input_enable_glacier_transition"></a> [enable\_glacier\_transition](#input\_enable\_glacier\_transition) | Whether to transition config reports to Glacier storage class | `bool` | `false` | no |
| <a name="input_glacier_transition_days"></a> [glacier\_transition\_days](#input\_glacier\_transition\_days) | Number of days after which to transition config reports to Glacier storage class | `number` | `90` | no |
| <a name="input_glacier_retention_days"></a> [glacier\_retention\_days](#input\_glacier\_retention\_days) | Number of days to retain config reports in Glacier before deletion (set to 0 to disable deletion) | `number` | `730` | no |
| <a name="input_tags"></a> [tags](#input\_tags) | A map of tags to add to all resources | `map(string)` | `{}` | no |
| <a name="input_enable_compliance_reporter"></a> [enable\_compliance\_reporter](#input\_enable\_compliance\_reporter) | Set to true to enable the scheduled Lambda function that generates PDF compliance reports | `bool` | `false` | no |
| <a name="input_reporter_schedule_expression"></a> [reporter\_schedule\_expression](#input\_reporter\_schedule\_expression) | Cron expression for triggering the compliance report Lambda | `string` | `"cron(0 6 ? * MON *)" | no |
| <a name="input_reporter_output_s3_prefix"></a> [reporter\_output\_s3\_prefix](#input\_reporter\_output\_s3\_prefix) | S3 key prefix within the Config bucket where PDF compliance reports will be stored | `string` | `"compliance-reports/"` | no |
| <a name="input_reporter_lambda_memory_size"></a> [reporter\_lambda\_memory\_size](#input\_reporter\_lambda\_memory\_size) | Memory size (MB) allocated to the compliance reporter Lambda function | `number` | `256` | no |
| <a name="input_reporter_lambda_timeout"></a> [reporter\_lambda\_timeout](#input\_reporter\_lambda\_timeout) | Timeout (seconds) for the compliance reporter Lambda function | `number` | `120` | no |
| <a name="input_enable_encrypted_volumes_rule"></a> [enable\_encrypted\_volumes\_rule](#input\_enable\_encrypted\_volumes\_rule) | Enable the `ENCRYPTED_VOLUMES` managed rule | `bool` | `true` | no |
| <a name="input_enable_iam_password_policy_rule"></a> [enable\_iam\_password\_policy\_rule](#input\_enable\_iam\_password\_policy\_rule) | Enable the `IAM_PASSWORD_POLICY` managed rule | `bool` | `true` | no |
| <a name="input_enable_s3_public_access_rules"></a> [enable\_s3\_public\_access\_rules](#input\_enable\_s3\_public\_access\_rules) | Enable `S3_BUCKET_PUBLIC_READ_PROHIBITED` and `S3_BUCKET_PUBLIC_WRITE_PROHIBITED` rules | `bool` | `true` | no |
| <a name="input_enable_iam_root_key_rule"></a> [enable\_iam\_root\_key\_rule](#input\_enable\_iam\_root\_key\_rule) | Enable the `ROOT_ACCOUNT_MFA_ENABLED` rule (checks root user MFA) | `bool` | `true` | no |
| <a name="input_enable_mfa_for_iam_console_rule"></a> [enable\_mfa\_for\_iam\_console\_rule](#input\_enable\_mfa\_for\_iam\_console\_rule) | Enable the `MFA_ENABLED_FOR_IAM_CONSOLE_ACCESS` rule | `bool` | `true` | no |
| <a name="input_enable_ec2_volume_inuse_rule"></a> [enable\_ec2\_volume\_inuse\_rule](#input\_enable\_ec2\_volume\_inuse\_rule) | Enable the `EC2_VOLUME_INUSE_CHECK` rule | `bool` | `true` | no |
| <a name="input_enable_eip_attached_rule"></a> [enable\_eip\_attached\_rule](#input\_enable\_eip\_attached\_rule) | Enable the `EIP_ATTACHED` rule | `bool` | `true` | no |
| <a name="input_enable_rds_storage_encrypted_rule"></a> [enable\_rds\_storage\_encrypted\_rule](#input\_enable\_rds\_storage\_encrypted\_rule) | Enable the `RDS_STORAGE_ENCRYPTED` rule | `bool` | `true` | no |

## Outputs

| Name | Description |
|------|-------------|
| <a name="output_config_bucket_arn"></a> [config\_bucket\_arn](#output\_config\_bucket\_arn) | The ARN of the S3 bucket used for AWS Config recordings |
| <a name="output_config_bucket_id"></a> [config\_bucket\_id](#output\_config\_bucket\_id) | The ID of the S3 bucket used for AWS Config recordings |
| <a name="output_config_iam_role_arn"></a> [config\_iam\_role\_arn](#output\_config\_iam\_role\_arn) | The ARN of the IAM role used for AWS Config |
| <a name="output_config_recorder_id"></a> [config\_recorder\_id](#output\_config\_recorder\_id) | The ID of the AWS Config recorder |
| <a name="output_config_rules_arns"></a> [config\_rules\_arns](#output\_config\_rules\_arns) | Map of all Config rules ARNs |
| <a name="output_delivery_channel_id"></a> [delivery\_channel\_id](#output\_delivery\_channel\_id) | The ID of the AWS Config delivery channel |
| <a name="output_ebs_encryption_rule_arn"></a> [ebs\_encryption\_rule\_arn](#output\_ebs\_encryption\_rule\_arn) | The ARN of the EBS encryption Config rule |
| <a name="output_password_policy_rule_arn"></a> [password\_policy\_rule\_arn](#output\_password\_policy\_rule\_arn) | The ARN of the IAM password policy Config rule |
| <a name="output_compliance_reporter_lambda_arn"></a> [compliance\_reporter\_lambda\_arn](#output\_compliance\_reporter\_lambda\_arn) | The ARN of the compliance reporter Lambda function (only if enabled) |
| <a name="output_compliance_reporter_lambda_role_arn"></a> [compliance\_reporter\_lambda\_role\_arn](#output\_compliance\_reporter\_lambda\_role\_arn) | The ARN of the IAM role for the compliance reporter Lambda function (only if enabled) |

<p align="right">(<a href="#readme-top">back to top</a>)</p>

+## Optional Compliance Reporter
+
+This module includes an optional feature to automatically generate PDF compliance reports on a schedule.
+
+**How it works:**
+
+1.  If `enable_compliance_reporter` is set to `true`, a Lambda function is deployed.
+2.  A CloudWatch Event Rule triggers this Lambda function based on the `reporter_schedule_expression` (defaults to the 1st of every month at 6 AM UTC).
+3.  The Lambda function uses the AWS SDK (`boto3`) to query the AWS Config service for the current compliance status of all Config Rules in the account and region.
+4.  It generates a PDF report summarizing:
+    *   Overall compliance status (Counts of Compliant/Non-Compliant rules).
+    *   A list of Non-Compliant rules.
+    *   For each Non-Compliant rule, a list of associated Non-Compliant resources (Resource Type and ID).
+    *   The AWS Account ID.
+5.  The generated PDF report is uploaded to the main Config S3 bucket under the prefix specified by `reporter_output_s3_prefix` (defaults to `compliance-reports/`). The filename includes the date and time of generation.
+
+**Note:** This reporter queries the *live* compliance status from the AWS Config service API. It does not parse the historical logs stored in the S3 bucket.
+
+<p align="right">(<a href="#readme-top">back to top</a>)</p>
+
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
