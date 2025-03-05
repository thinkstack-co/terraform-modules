# AWS Backup Custom Module

<a name="readme-top"></a>

<!-- PROJECT SHIELDS -->
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
    <img src="https://raw.githubusercontent.com/thinkstack-co/terraform-modules/main/images/thinkstack_logo.png" alt="ThinkStack Logo" width="300" height="100">
  </a>

<h3 align="center">AWS Backup Custom Module</h3>
  <p align="center">
    This module creates custom AWS Backup plans and vaults that allow you to target EC2 instances and other resources based on tags.
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
    <li><a href="#overview">Overview</a></li>
    <li><a href="#usage">Usage</a></li>
    <li><a href="#requirements">Requirements</a></li>
    <li><a href="#providers">Providers</a></li>
    <li><a href="#resources">Resources</a></li>
    <li><a href="#inputs">Inputs</a></li>
    <li><a href="#outputs">Outputs</a></li>
    <li><a href="#license">License</a></li>
    <li><a href="#contact">Contact</a></li>
    <li><a href="#acknowledgments">Acknowledgments</a></li>
  </ol>
</details>

## Overview

This Terraform module creates custom AWS Backup plans and vaults that allow you to target EC2 instances and other resources based on tags. This enables you to create different backup schedules and retention policies for different resources based on their backup requirements.

The module supports:
- Creating backup vaults with KMS encryption
- Creating standard backup plans (daily, weekly, monthly, yearly) with configurable schedules and retention periods
- Creating custom backup plans with specific schedules and retention periods
- Targeting resources using tag-based selection
- Supporting EC2 instance backups with Windows VSS support

All resources are conditionally created based on the corresponding `create_*_plan` variables. When you enable a backup plan (e.g., `create_daily_plan = true`), the module automatically creates the corresponding vault and configures the plan to use it.

## Features

- Automatic backup vault creation based on enabled backup plans
- KMS key encryption for backup vaults
- Tag-based resource selection for backup plans
- Windows VSS support for EC2 instances
- Configurable backup schedules and retention periods
- Custom backup plans with flexible configuration

## Tagging Strategy

This module uses a tag-based approach to select resources for backup:

1. **Standard Backup Plans** (daily, weekly, monthly, yearly):
   - Resources are selected based on the tag key specified by `standard_backup_tag_key` (defaults to "backup_schedule")
   - Tag values should match the plan name: "daily", "weekly", "monthly", or "yearly"
   
   Example:
   ```hcl
   tags = {
     backup_schedule = "daily"  # This resource will be included in the daily backup plan
   }
   ```

2. **Custom Backup Plans**:
   - Resources are selected based on the tag key specified in each custom plan (or `default_custom_backup_tag_key` if not specified)
   - The default custom backup tag key is "backup_custom"
   - Tag values should match the value specified in the custom plan configuration
   
   Example:
   ```hcl
   tags = {
     backup_custom = "database"  # This resource will be included in a custom plan with tag_value = "database"
   }
   ```

You can customize both the standard and custom tag keys to fit your tagging strategy.

## Usage

### Basic Usage

```hcl
module "aws_backup_custom" {
  source = "github.com/thinkstack-co/terraform-modules//modules/thinkstack/aws_backup_custom"

  # Enable KMS key creation
  create_kms_key = true
  
  # Enable specific backup plans - vaults will be created automatically
  create_daily_plan = true
  create_weekly_plan = true
  
  # All other resources use default settings
}
```

### Custom Backup Plans

```hcl
module "aws_backup_custom" {
  source = "github.com/thinkstack-co/terraform-modules//modules/thinkstack/aws_backup_custom"

  # Enable KMS key creation
  create_kms_key = true

  # Enable specific backup plans - vaults will be created automatically
  create_daily_plan = false
  create_weekly_plan = true
  create_monthly_plan = true
  create_yearly_plan = false

  # Customize weekly backup settings
  weekly_schedule = "cron(0 3 ? * SUN *)" # Every Sunday at 3:00 AM UTC
  weekly_retention_days = 60

  # Customize monthly backup settings
  monthly_schedule = "cron(0 2 1 * ? *)" # 1st of each month at 2:00 AM UTC
  monthly_retention_days = 180

  # Define custom backup plans
  custom_backup_plans = {
    database_backup = {
      vault_name               = "monthly"  # Use the monthly vault
      schedule                 = "cron(0 2 15 * ? *)"  # 15th of each month at 2:00 AM UTC
      enable_continuous_backup = true
      retention_days           = 180
      resource_type            = "EC2"
      tag_key                  = "backup_custom"
      tag_value                = "database"
      tags = {
        backup_type = "database"
      }
    },
    critical_servers = {
      vault_name               = "weekly"
      schedule                 = "cron(0 3 ? * SAT *)"  # Every Saturday at 3:00 AM UTC
      enable_continuous_backup = false
      retention_days           = 90
      resource_type            = "EC2"
      tag_key                  = "backup_custom"
      tag_value                = "critical"
      tags = {
        backup_type = "critical"
      }
    }
  }

  # Custom tags
  tags = {
    terraform   = "true"
    created_by  = "ThinkStack"
    environment = "prod"
    project     = "backup-implementation"
  }
}
```

### Tagging Resources for Backup

To include an EC2 instance in a backup plan, add the appropriate tag:

```hcl
resource "aws_instance" "example" {
  # ... other configuration ...

  tags = {
    Name            = "example-instance"
    backup_schedule = "monthly"  # Will be included in the monthly backup plan
    # OR
    backup_custom   = "database"  # Will be included in the custom database_backup plan
  }
}
```

<p align="right">(<a href="#readme-top">back to top</a>)</p>

<!-- REQUIREMENTS -->
## Requirements

| Name | Version |
|------|---------|
| terraform | >= 1.0.0 |
| aws | >= 4.0.0 |

## Providers

| Name | Version |
|------|---------|
| aws | >= 4.0.0 |

## Resources

| Name | Type | Documentation |
|------|------|--------------|
| [aws_kms_key.backup_key](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/kms_key) | resource | [AWS Documentation](https://docs.aws.amazon.com/kms/latest/developerguide/overview.html) |
| [aws_kms_alias.backup_alias](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/kms_alias) | resource | [AWS Documentation](https://docs.aws.amazon.com/kms/latest/developerguide/kms-alias.html) |
| [aws_iam_role.backup_role](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/iam_role) | resource | [AWS Documentation](https://docs.aws.amazon.com/IAM/latest/UserGuide/id_roles.html) |
| [aws_backup_vault.backup_vault](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/backup_vault) | resource | [AWS Documentation](https://docs.aws.amazon.com/aws-backup/latest/devguide/vaults.html) |
| [aws_backup_plan.daily_backup_plan](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/backup_plan) | resource | [AWS Documentation](https://docs.aws.amazon.com/aws-backup/latest/devguide/about-backup-plans.html) |
| [aws_backup_selection.daily_selection](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/backup_selection) | resource | [AWS Documentation](https://docs.aws.amazon.com/aws-backup/latest/devguide/assigning-resources.html) |

<p align="right">(<a href="#readme-top">back to top</a>)</p>

<!-- INPUTS -->
## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| create_kms_key | Whether to create a new KMS key for backups | `bool` | `false` | no |
| kms_alias_name | The alias name for the KMS key | `string` | `"backup-custom-key"` | no |
| backup_role_name | The name of the IAM role for AWS Backup | `string` | `"aws-backup-custom-role"` | no |
| backup_start_window | The amount of time in minutes before beginning a backup | `number` | `60` | no |
| backup_completion_window | The amount of time in minutes AWS Backup attempts a backup before canceling | `number` | `1440` | no |
| create_daily_plan | Whether to create a daily backup plan | `bool` | `false` | no |
| daily_plan_name | The name of the daily backup plan | `string` | `"daily-backup-plan"` | no |
| daily_schedule | CRON expression for daily backups | `string` | `"cron(0 1 * * ? *)"` | no |
| daily_retention_days | Number of days to retain daily backups | `number` | `3` | no |
| create_weekly_plan | Whether to create a weekly backup plan | `bool` | `false` | no |
| weekly_plan_name | The name of the weekly backup plan | `string` | `"weekly-backup-plan"` | no |
| weekly_schedule | CRON expression for weekly backups | `string` | `"cron(0 1 ? * SUN *)"` | no |
| weekly_retention_days | Number of days to retain weekly backups | `number` | `30` | no |
| create_monthly_plan | Whether to create a monthly backup plan | `bool` | `false` | no |
| monthly_plan_name | The name of the monthly backup plan | `string` | `"monthly-backup-plan"` | no |
| monthly_schedule | CRON expression for monthly backups | `string` | `"cron(0 1 1 * ? *)"` | no |
| monthly_retention_days | Number of days to retain monthly backups | `number` | `365` | no |
| create_yearly_plan | Whether to create a yearly backup plan | `bool` | `false` | no |
| yearly_plan_name | The name of the yearly backup plan | `string` | `"yearly-backup-plan"` | no |
| yearly_schedule | CRON expression for yearly backups | `string` | `"cron(0 1 1 1 ? *)"` | no |
| yearly_retention_days | Number of days to retain yearly backups | `number` | `365` | no |
| custom_backup_plans | Map of custom backup plans | `map(object)` | `{}` | no |
| standard_backup_tag_key | The tag key used for standard backup plans | `string` | `"backup_schedule"` | no |
| default_custom_backup_tag_key | The default tag key used for custom backup plans | `string` | `"backup_custom"` | no |
| tags | A mapping of tags to assign to all resources | `map(any)` | See variables.tf | no |

## Outputs

| Name | Description |
|------|-------------|
| kms_key_arn | The ARN of the KMS key |
| kms_key_id | The ID of the KMS key |
| backup_role_arn | The ARN of the IAM role used for AWS Backup |
| backup_role_name | The name of the IAM role used for AWS Backup |
| backup_vault_arns | Map of backup vault names to their ARNs |
| backup_vault_ids | Map of backup vault names to their IDs |
| daily_backup_plan_id | The ID of the daily backup plan |
| weekly_backup_plan_id | The ID of the weekly backup plan |
| monthly_backup_plan_id | The ID of the monthly backup plan |
| yearly_backup_plan_id | The ID of the yearly backup plan |
| custom_backup_plan_ids | Map of custom backup plan names to their IDs |

<p align="right">(<a href="#readme-top">back to top</a>)</p>

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
* [Zachary Hill](https://zacharyhill.co)
* [Jake Jones](https://github.com/jakeasarus)

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
