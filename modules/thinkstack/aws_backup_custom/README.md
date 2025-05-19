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
    <img src="/images/terraform_modules_logo.webp" alt="Logo" width="300" height="300">
  </a>

<h3 align="center">AWS Backup Custom Module</h3>
  <p align="center">
    This module creates and manages AWS Backup plans, vaults, and selections with a flexible, opt-in architecture.
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

This Terraform module creates and manages AWS Backup resources with a flexible, opt-in architecture. AWS Backup is a fully managed backup service that makes it easy to centralize and automate the backup of data across AWS services.

The module supports:
- Standard backup plans (hourly, daily, weekly, monthly, yearly)
- Custom backup plans with configurable schedules and retention periods
- Tag-based resource selection for both standard and custom backup plans
- Optional KMS key creation for encrypted backups
- Vault lock capabilities for enhanced security
- Windows VSS support for consistent backups of Windows instances
- **Disaster Recovery (DR) region support:** Optionally create backup vaults, plans, and selections in a separate AWS region for DR purposes.

<p align="right">(<a href="#readme-top">back to top</a>)</p>

<!-- USAGE EXAMPLES -->
## Usage

### Complete Example: All Features

This example demonstrates all features of the module, including hourly/daily/weekly/monthly/yearly/custom/DR plans, KMS key creation, Windows VSS, vault lock, tagging, and resource selection.

```hcl
module "aws_custom_backup" {
  source = "github.com/thinkstack-co/terraform-modules//modules/thinkstack/aws_backup_custom"

  # Enable all standard backup plans
  create_hourly_plan  = true
  create_daily_plan   = true
  create_weekly_plan  = true
  create_monthly_plan = true
  create_yearly_plan  = true

  # Enable Disaster Recovery (DR) region
  enable_dr         = true
  dr_region         = "us-west-2"
  dr_vault_name     = "dr-backup-vault"
  dr_plan_name      = "dr-backup-plan"
  dr_schedule       = "cron(0 2 * * ? *)"
  dr_retention_days = 30
  dr_tags = {
    environment = "dr"
    project     = "backup_dr"
  }
  dr_selection_tag_key   = "backup_schedule"
  dr_selection_tag_value = "dr"

  # KMS key configuration
  create_kms_key        = true
  kms_key_description   = "KMS key for AWS Backup encryption"
  key_enable_key_rotation = true
  key_deletion_window_in_days = 30

  # Vault lock and Windows VSS
  enable_vault_lock     = true
  enable_windows_vss    = true

  # Retention and schedule settings for each plan
  hourly_schedule               = "cron(0 * * * ? *)"
  hourly_retention_days         = 1
  hourly_enable_continuous_backup = true

  daily_schedule                = "cron(0 1 * * ? *)"
  daily_retention_days          = 7
  daily_enable_continuous_backup = true

  weekly_schedule               = "cron(0 2 ? * 1 *)"
  weekly_retention_days         = 30

  monthly_schedule              = "cron(0 3 1 * ? *)"
  monthly_retention_days        = 90

  yearly_schedule               = "cron(0 4 1 1 ? *)"
  yearly_retention_days         = 365

  # Custom backup plans
  custom_backup_plans = {
    database_backups = {
      schedule               = "cron(0 5 * * ? *)"
      retention_days         = 14
      enable_continuous_backup = true
      vault                  = "daily"
      tag_key                = "database_backup"
      tag_value              = "db"
    }
    app_backups = {
      schedule               = "cron(0 6 ? * 1 *)"
      retention_days         = 60
      enable_continuous_backup = false
      vault                  = "weekly"
      tag_key                = "app_backup"
      tag_value              = "app"
    }
  }

  # Tags for all resources
  tags = {
    terraform   = "true"
    environment = "production"
    project     = "backup_infrastructure"
  }
}

# Example EC2 instance included in daily and weekly backup plans
resource "aws_instance" "web_server" {
  # ... other configuration ...
  tags = {
    Name            = "web-server"
    environment     = "production"
    project         = "server_infrastructure"
    backup_schedule = "daily-weekly"
  }
}

# Example RDS instance included in hourly and daily backup plans
resource "aws_db_instance" "database" {
  # ... other configuration ...
  tags = {
    Name            = "example-db"
    backup_schedule = "hourly-daily"
  }
}

# Example EFS file system included in all enabled backup plans
resource "aws_efs_file_system" "efs" {
  # ... other configuration ...
  tags = {
    Name            = "example-efs"
    backup_schedule = "all"
  }
}

# Example EC2 instance included in custom backup plans
resource "aws_instance" "app" {
  # ... other configuration ...
  tags = {
    Name                  = "app-server"
    app_backup            = "app"
    database_backup       = "db"
  }
}
```

#### Supported Tag Values

The module supports all possible combinations of backup schedules. Here are some examples:

| Tag Value | Included in Backup Plans |
|-----------|--------------------------|
| `"hourly"` | Hourly |
| `"daily"` | Daily |
| `"weekly"` | Weekly |
| `"monthly"` | Monthly |
| `"yearly"` | Yearly |
| `"hourly-daily"` | Hourly, Daily |
| `"daily-weekly"` | Daily, Weekly |
| `"weekly-monthly"` | Weekly, Monthly |
| `"monthly-yearly"` | Monthly, Yearly |
| `"hourly-daily-weekly"` | Hourly, Daily, Weekly |
| `"daily-weekly-monthly"` | Daily, Weekly, Monthly |
| `"weekly-monthly-yearly"` | Weekly, Monthly, Yearly |
| `"hourly-daily-weekly-monthly"` | Hourly, Daily, Weekly, Monthly |
| `"daily-weekly-monthly-yearly"` | Daily, Weekly, Monthly, Yearly |
| `"hourly-daily-weekly-monthly-yearly"` | All backup plans |
| `"all"` | All enabled backup plans |

> **Note:** Resources will only be included in backup plans that are enabled in the module configuration. For example, if a resource is tagged with `"daily-weekly"` but only the daily plan is enabled, the resource will only be backed up by the daily plan.

  source = "github.com/thinkstack-co/terraform-modules//modules/thinkstack/aws_backup_custom"

  # Enable Windows VSS for consistent backups of Windows instances
  enable_windows_vss = true
  
  # Enable vault lock to prevent configuration changes and deletions of backups
  enable_vault_lock = true
  
  # Enable all standard backup plans
  create_hourly_plan  = true
  create_daily_plan   = true
  create_weekly_plan  = true
  create_monthly_plan = true
  create_yearly_plan  = true
  
  # Configure hourly backup settings
  hourly_schedule               = "cron(0 * * * ? *)"  # Every hour at minute 0 (1:00 AM, 2:00 AM, etc. UTC / 8:00 PM, 9:00 PM, etc. EST)
  hourly_retention_days         = 1                    # Keep hourly backups for 1 day
  hourly_enable_continuous_backup = true               # Enable point-in-time recovery
  
  # Configure daily backup settings
  daily_schedule                = "cron(0 1 * * ? *)"  # Daily at 1:00 AM UTC / 8:00 PM EST
  daily_retention_days          = 7                    # Keep daily backups for 7 days
  daily_enable_continuous_backup = true                # Enable point-in-time recovery
  
  # Configure weekly backup settings
  weekly_schedule               = "cron(0 2 ? * 1 *)"  # Weekly on Sundays at 2:00 AM UTC / 9:00 PM EST
  weekly_retention_days         = 30                   # Keep weekly backups for 30 days
  
  # Configure monthly backup settings
  monthly_schedule              = "cron(0 3 1 * ? *)"  # 1st of each month at 3:00 AM UTC / 10:00 PM EST
  monthly_retention_days        = 90                   # Keep monthly backups for 90 days
  
  # Configure yearly backup settings
  yearly_schedule               = "cron(0 4 1 1 ? *)"  # January 1st at 4:00 AM UTC / 11:00 PM EST
  yearly_retention_days         = 365                  # Keep yearly backups for 365 days
  
  # Create a KMS key for backup encryption
  create_kms_key                = true
  kms_key_description           = "KMS key for AWS Backup encryption"
  
  # Configure custom backup plans
  custom_backup_plans = {
    database_backups = {
      schedule               = "cron(0 5 * * ? *)"  # Daily at 5:00 AM UTC / 12:00 AM EST
      retention_days         = 14                   # Keep backups for 14 days
      enable_continuous_backup = true               # Enable point-in-time recovery
      vault                  = "daily"              # Use the daily vault
      tag_key                = "database_backup"    # Custom tag key
    }
    app_backups = {
      schedule               = "cron(0 6 ? * 1 *)"  # Weekly on Sundays at 6:00 AM UTC / 1:00 AM EST
      retention_days         = 60                   # Keep backups for 60 days
      enable_continuous_backup = false              # Disable point-in-time recovery
      vault                  = "weekly"             # Use the weekly vault
      tag_key                = "app_backup"         # Custom tag key
    }
  }
  
  # Tag all resources created by this module
  tags = {
    terraform   = "true"
    environment = "production"
    project     = "backup_infrastructure"
  }
}

# Example EC2 instance with standard backup tag
resource "aws_instance" "web_server" {
  # ... other configuration ...
  
  tags = {
    Name            = "web-server"
    environment     = "production"
    project         = "server_infrastructure"
    service         = "ops"
    backup          = "true"
    backup_schedule = "daily-weekly"  # Include in daily and weekly backup plans
  }
}

# Example RDS instance with standard backup tag
resource "aws_db_instance" "database" {
  # ... other configuration ...
  
  tags = {
    Name            = "example-db"
    backup_schedule = "hourly-daily"  # Include in hourly and daily backup plans
  }
}
```

### Argument Reference

* `create_hourly_plan` - (Optional) Whether to create an hourly backup plan. Default is `false`.
* `create_daily_plan` - (Optional) Whether to create a daily backup plan. Default is `false`.
* `create_weekly_plan` - (Optional) Whether to create a weekly backup plan. Default is `false`.
* `create_monthly_plan` - (Optional) Whether to create a monthly backup plan. Default is `false`.
* `create_yearly_plan` - (Optional) Whether to create a yearly backup plan. Default is `false`.
* `hourly_schedule` - (Optional) Cron expression for the hourly backup schedule. Default is `cron(0 * * * ? *)` (runs at minute 0 of every hour, every day - 1:00 AM, 2:00 AM, etc. UTC / 8:00 PM, 9:00 PM, etc. EST).
* `daily_schedule` - (Optional) Cron expression for the daily backup schedule. Default is `cron(0 1 * * ? *)` (runs at 1:00 AM UTC / 8:00 PM EST every day).
* `weekly_schedule` - (Optional) Cron expression for the weekly backup schedule. Default is `cron(0 2 ? * 1 *)` (runs at 2:00 AM UTC / 9:00 PM EST every Sunday).
* `monthly_schedule` - (Optional) Cron expression for the monthly backup schedule. Default is `cron(0 3 1 * ? *)` (runs at 3:00 AM UTC / 10:00 PM EST on the 1st day of every month).
* `yearly_schedule` - (Optional) Cron expression for the yearly backup schedule. Default is `cron(0 4 1 1 ? *)` (runs at 4:00 AM UTC / 11:00 PM EST on January 1st every year).
* `hourly_retention_days` - (Optional) Number of days to retain hourly backups. Default is `1`.
* `daily_retention_days` - (Optional) Number of days to retain daily backups. Default is `7`.
* `weekly_retention_days` - (Optional) Number of days to retain weekly backups. Default is `30`.
* `monthly_retention_days` - (Optional) Number of days to retain monthly backups. Default is `90`.
* `yearly_retention_days` - (Optional) Number of days to retain yearly backups. Default is `365`.
* `create_kms_key` - (Optional) Whether to create a KMS key for backup encryption. Default is `false`.
* `kms_key_arn` - (Optional) ARN of an existing KMS key to use for backup encryption. Required if `create_kms_key` is `false`.
* `enable_vault_lock` - (Optional) Whether to enable vault lock for all backup vaults. Default is `false`.
* `enable_windows_vss` - (Optional) Whether to enable Windows VSS for consistent backups of Windows instances. Default is `false`.
* `standard_backup_tag_key` - (Optional) Tag key to use for standard backup plans. Default is `backup_schedule`.
* `default_custom_backup_tag_key` - (Optional) Default tag key to use for custom backup plans. Default is `backup_custom`.
* `custom_backup_plans` - (Optional) Map of custom backup plans to create. See example for structure.
* `tags` - (Optional) Map of tags to apply to all resources created by this module.

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
| [aws_backup_vault](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/backup_vault) | resource | [AWS Documentation](https://docs.aws.amazon.com/aws-backup/latest/devguide/vaults.html) |
| [aws_backup_vault_lock_configuration](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/backup_vault_lock_configuration) | resource | [AWS Documentation](https://docs.aws.amazon.com/aws-backup/latest/devguide/vault-lock.html) |
| [aws_backup_plan](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/backup_plan) | resource | [AWS Documentation](https://docs.aws.amazon.com/aws-backup/latest/devguide/about-backup-plans.html) |
| [aws_backup_selection](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/backup_selection) | resource | [AWS Documentation](https://docs.aws.amazon.com/aws-backup/latest/devguide/assigning-resources.html) |
| [aws_kms_key](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/kms_key) | resource | [AWS Documentation](https://docs.aws.amazon.com/kms/latest/developerguide/overview.html) |
| [aws_kms_alias](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/kms_alias) | resource | [AWS Documentation](https://docs.aws.amazon.com/kms/latest/developerguide/kms-alias.html) |
| [aws_iam_role](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/iam_role) | resource | [AWS Documentation](https://docs.aws.amazon.com/IAM/latest/UserGuide/id_roles.html) |
| [aws_iam_policy](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/iam_policy) | resource | [AWS Documentation](https://docs.aws.amazon.com/IAM/latest/UserGuide/access_policies.html) |
| [aws_iam_role_policy_attachment](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/iam_role_policy_attachment) | resource | [AWS Documentation](https://docs.aws.amazon.com/IAM/latest/UserGuide/id_roles_manage_modify.html) |

<p align="right">(<a href="#readme-top">back to top</a>)</p>

<!-- INPUTS -->
## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| create_hourly_plan | Whether to create an hourly backup plan | `bool` | `false` | no |
| create_daily_plan | Whether to create a daily backup plan | `bool` | `false` | no |
| create_weekly_plan | Whether to create a weekly backup plan | `bool` | `false` | no |
| create_monthly_plan | Whether to create a monthly backup plan | `bool` | `false` | no |
| create_yearly_plan | Whether to create a yearly backup plan | `bool` | `false` | no |
| hourly_schedule | Cron expression for the hourly backup schedule | `string` | `"cron(0 * * * ? *)"` | no |
| daily_schedule | Cron expression for the daily backup schedule | `string` | `"cron(0 1 * * ? *)"` | no |
| weekly_schedule | Cron expression for the weekly backup schedule | `string` | `"cron(0 2 ? * 1 *)"` | no |
| monthly_schedule | Cron expression for the monthly backup schedule | `string` | `"cron(0 3 1 * ? *)"` | no |
| yearly_schedule | Cron expression for the yearly backup schedule | `string` | `"cron(0 4 1 1 ? *)"` | no |
| hourly_retention_days | Number of days to retain hourly backups | `number` | `1` | no |
| daily_retention_days | Number of days to retain daily backups | `number` | `7` | no |
| weekly_retention_days | Number of days to retain weekly backups | `number` | `30` | no |
| monthly_retention_days | Number of days to retain monthly backups | `number` | `90` | no |
| yearly_retention_days | Number of days to retain yearly backups | `number` | `365` | no |
| create_kms_key | Whether to create a KMS key for backup encryption | `bool` | `false` | no |
| kms_key_arn | ARN of an existing KMS key to use for backup encryption | `string` | `null` | no |
| enable_vault_lock | Whether to enable vault lock for all backup vaults | `bool` | `false` | no |
| enable_windows_vss | Whether to enable Windows VSS for consistent backups of Windows instances | `bool` | `false` | no |
| standard_backup_tag_key | Tag key to use for standard backup plans | `string` | `"backup_schedule"` | no |
| default_custom_backup_tag_key | Default tag key to use for custom backup plans | `string` | `"backup_custom"` | no |
| custom_backup_plans | Map of custom backup plans to create | `map(object)` | `{}` | no |
| tags | Map of tags to apply to all resources created by this module | `map(any)` | `{}` | no |
| enable_dr | Whether to enable DR (Disaster Recovery) backup in a separate AWS region | `bool` | `false` | no |
| dr_region | The AWS region to use for DR backups | `string` | `null` | no |
| dr_vault_name | The name of the backup vault to create in the DR region | `string` | `"dr-backup-vault"` | no |
| dr_plan_name | The name of the backup plan to create in the DR region | `string` | `"dr-backup-plan"` | no |
| dr_schedule | CRON expression for the DR backup plan schedule | `string` | `"cron(0 2 * * ? *)"` | no |
| dr_retention_days | Number of days to retain DR backups | `number` | `30` | no |
| dr_tags | Tags to apply to DR region resources | `map(any)` | `{}` | no |
| dr_selection_tag_key | Tag key for selecting resources to back up in the DR plan | `string` | `"backup_schedule"` | no |
| dr_selection_tag_value | Tag value for selecting resources to back up in the DR plan | `string` | `"dr"` | no |

## Outputs

| Name | Description |
|------|-------------|
| backup_vaults | Map of backup vaults created by the module |
| backup_plans | Map of backup plans created by the module |
| kms_key_arn | ARN of the KMS key used for backup encryption (if created) |
| iam_role_arn | ARN of the IAM role used for AWS Backup |
| hourly_selection_id | The ID of the hourly backup selection (for resources tagged with "hourly") |
| daily_selection_id | The ID of the daily backup selection (for resources tagged with "daily") |
| weekly_selection_id | The ID of the weekly backup selection (for resources tagged with "weekly") |
| monthly_selection_id | The ID of the monthly backup selection (for resources tagged with "monthly") |
| yearly_selection_id | The ID of the yearly backup selection (for resources tagged with "yearly") |
| hourly_all_selection_ids | Map of hourly 'all' tag backup selection names to their IDs |
| daily_all_selection_ids | Map of daily 'all' tag backup selection names to their IDs |
| weekly_all_selection_ids | Map of weekly 'all' tag backup selection names to their IDs |
| monthly_all_selection_ids | Map of monthly 'all' tag backup selection names to their IDs |
| yearly_all_selection_ids | Map of yearly 'all' tag backup selection names to their IDs |
| hourly_combinations_selection_ids | Map of hourly combination backup selection names to their IDs |
| daily_combinations_selection_ids | Map of daily combination backup selection names to their IDs |
| weekly_combinations_selection_ids | Map of weekly combination backup selection names to their IDs |
| monthly_combinations_selection_ids | Map of monthly combination backup selection names to their IDs |
| yearly_combinations_selection_ids | Map of yearly combination backup selection names to their IDs |
| multi_plan_selection_ids | Map of multi-plan backup selection names to their IDs |
| custom_selection_ids | Map of custom backup selection names to their IDs |

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
