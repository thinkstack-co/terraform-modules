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
- **Disaster Recovery (DR) cross-region copies:** Automatically copy backups to a DR region with configurable retention per backup frequency

<p align="right">(<a href="#readme-top">back to top</a>)</p>

<!-- USAGE EXAMPLES -->
## Usage

### Complete Example: Production and DR Cross-Region Backup Configuration

This example demonstrates a complete, production-ready configuration including standard backup plans with selective cross-region DR copies, custom backup plans, KMS key creation, Vault Lock, Windows VSS, and proper tagging for resource selection.

```hcl
# Configure the providers
provider "aws" {
  region = "us-east-1"
}

provider "aws" {
  alias  = "dr"
  region = "us-west-2"
}

module "aws_backup_custom" {
  source = "github.com/thinkstack-co/terraform-modules//modules/thinkstack/aws_backup_custom"

  providers = {
    aws    = aws
    aws.dr = aws.dr
  }

  # Enable production backup plans
  create_hourly_plan  = true
  create_daily_plan   = true
  create_weekly_plan  = true
  create_monthly_plan = true
  create_yearly_plan  = true

  # Configure production hourly backup settings
  hourly_schedule                 = "cron(0 * * * ? *)"  # Every hour
  hourly_retention_days           = 2                    # Keep for 2 days
  hourly_enable_continuous_backup = true                 # Enable point-in-time recovery
  hourly_windows_vss              = true                 # Enable VSS for Windows

  # Configure production daily backup settings
  daily_schedule                 = "cron(0 3 * * ? *)"   # Daily at 3:00 AM UTC
  daily_retention_days           = 7                     # Keep for 7 days
  daily_enable_continuous_backup = true                  # Enable point-in-time recovery
  daily_windows_vss              = true                  # Enable VSS for Windows

  # Configure production weekly backup settings
  weekly_schedule       = "cron(0 3 ? * SUN *)"          # Sundays at 3:00 AM UTC
  weekly_retention_days = 30                             # Keep for 30 days
  weekly_windows_vss    = true                           # Enable VSS for Windows

  # Configure production monthly backup settings
  monthly_schedule       = "cron(0 3 1 * ? *)"           # 1st of month at 3:00 AM UTC
  monthly_retention_days = 365                           # Keep for 1 year
  monthly_windows_vss    = true                          # Enable VSS for Windows

  # Configure production yearly backup settings
  yearly_schedule       = "cron(0 3 1 1 ? *)"            # January 1st at 3:00 AM UTC
  yearly_retention_days = 2555                           # Keep for 7 years
  yearly_windows_vss    = true                           # Enable VSS for Windows

  # Enable Disaster Recovery (DR) cross-region copying
  enable_dr = true
  dr_region = "us-west-2"
  
  # DR backup vault configuration
  dr_vault_name       = "dr-backup-vault"
  dr_backup_role_name = "aws-backup-dr-role"
  
  # Configure which backup plans should copy to DR (selective DR copying)
  hourly_include_in_dr  = false  # Don't copy hourly backups to DR
  daily_include_in_dr   = true   # Copy daily backups to DR
  weekly_include_in_dr  = true   # Copy weekly backups to DR
  monthly_include_in_dr = true   # Copy monthly backups to DR
  yearly_include_in_dr  = false  # Don't copy yearly backups to DR

  # Configure DR retention (optional - defaults to source retention if not specified)
  daily_dr_retention_days   = 14   # Keep DR copies for 14 days (vs 7 in prod)
  weekly_dr_retention_days  = 60   # Keep DR copies for 60 days (vs 30 in prod)
  monthly_dr_retention_days = 730  # Keep DR copies for 2 years (vs 1 year in prod)
  
  # DR tag configuration - resources must have BOTH backup schedule AND DR tags
  dr_tag_key   = "add_to_dr"
  dr_tag_value = "true"
  
  # Tags for DR resources
  dr_tags = {
    environment = "dr"
    region      = "us-west-2"
    purpose     = "disaster-recovery"
  }

  # KMS key configuration for encryption
  create_kms_key               = true
  kms_alias_name               = "aws-backup"
  key_description              = "KMS key for AWS Backup encryption"
  key_enable_key_rotation      = true
  key_deletion_window_in_days  = 30

  # Enable Windows VSS globally
  enable_windows_vss = true
  
  # Enable vault lock for compliance
  enable_vault_lock                = true
  vault_lock_changeable_for_days   = 3
  vault_lock_max_retention_days    = 36500  # 100 years

  # Configure custom backup plans
  custom_backup_plans = {
    critical_databases = {
      schedule                 = "cron(0 */4 * * ? *)"  # Every 4 hours
      retention_days           = 30
      enable_continuous_backup = true
      vault_name               = "daily"
      tag_key                  = "backup_custom"
      tag_value                = "critical_db"
      windows_vss              = true
      tags = {
        backup_type = "critical"
        frequency   = "4-hourly"
      }
    }
    compliance_archives = {
      schedule                 = "cron(0 2 1 * ? *)"    # Monthly
      retention_days           = 2555                   # 7 years
      enable_continuous_backup = false
      vault_name               = "monthly"
      tag_key                  = "backup_custom"
      tag_value                = "compliance"
      windows_vss              = false
      tags = {
        backup_type = "compliance"
        retention   = "7-years"
      }
    }
  }
  
  # Tag configuration for standard backups
  standard_backup_tag_key       = "backup_schedule"
  default_custom_backup_tag_key = "backup_custom"

  # Global tags for all backup resources
  tags = {
    terraform    = "true"
    environment  = "production"
    project      = "backup_infrastructure"
    cost_center  = "operations"
  }
}

# Example EC2 instance with production backups AND DR copying
# This instance will have daily/weekly/monthly backups copied to DR
resource "aws_instance" "critical_web_server" {
  ami           = "ami-12345678"
  instance_type = "t3.medium"
  
  tags = {
    Name             = "critical-web-server"
    environment      = "production"
    backup_schedule  = "daily-weekly-monthly"  # Production backup schedule
    add_to_dr        = "true"                  # Include in DR copies
    backup_custom    = "critical_db"           # Include in custom backup plan
  }
}

# Example RDS instance with hourly and daily backups but NO DR
# Even though daily backups have DR enabled, this resource won't be copied
resource "aws_db_instance" "application_db" {
  identifier     = "app-database"
  engine         = "postgres"
  instance_class = "db.t3.small"
  
  tags = {
    Name            = "application-database"
    environment     = "production"
    backup_schedule = "hourly-daily"  # Hourly and daily production backups
    add_to_dr       = "false"         # Exclude from DR copies
  }
}

# Example EBS volume with DR copying for compliance
# Monthly backups will be copied to DR with 2-year retention
resource "aws_ebs_volume" "compliance_data" {
  availability_zone = "us-east-1a"
  size              = 100
  
  tags = {
    Name            = "compliance-data-volume"
    environment     = "production"
    backup_schedule = "monthly-yearly"  # Monthly and yearly backups
    add_to_dr       = "true"            # Copy to DR (only monthly since yearly DR is disabled)
    backup_custom   = "compliance"      # Compliance archive backup
  }
}

# Example instance that uses the "all" backup tag with DR
resource "aws_instance" "important_server" {
  ami           = "ami-12345678"
  instance_type = "t3.large"
  
  tags = {
    Name            = "important-server"
    environment     = "production"
    backup_schedule = "all"        # Include in ALL backup plans
    add_to_dr       = "true"       # Copy ALL eligible backups to DR
  }
}
```

### Simple Example: Basic Daily Backups with Optional DR

This example shows a minimal configuration with daily backups and selective DR copying:

```hcl
# Configure providers if using DR
provider "aws" {
  region = "us-east-1"
}

provider "aws" {
  alias  = "dr"
  region = "us-west-2"
}

module "aws_backup_custom" {
  source = "github.com/thinkstack-co/terraform-modules//modules/thinkstack/aws_backup_custom"

  providers = {
    aws    = aws
    aws.dr = aws.dr
  }

  # Enable only daily backups
  create_daily_plan = true
  daily_retention_days = 30

  # Enable DR for daily backups
  enable_dr = true
  daily_include_in_dr = true
  daily_dr_retention_days = 7  # Keep DR copies for only 7 days

  # Create KMS key for encryption
  create_kms_key = true

  tags = {
    terraform = "true"
    project   = "my-project"
  }
}

# Tag resources for backups
resource "aws_instance" "app_server" {
  # ... instance configuration ...
  
  tags = {
    Name            = "app-server"
    backup_schedule = "daily"      # Include in daily backups
    add_to_dr       = "true"       # Also copy to DR
  }
}

resource "aws_instance" "dev_server" {
  # ... instance configuration ...
  
  tags = {
    Name            = "dev-server"
    backup_schedule = "daily"      # Include in daily backups
    # No add_to_dr tag - won't be copied to DR
  }
}
```

### How DR Cross-Region Copying Works

The module provides two-level control for DR backup copying:

1. **Plan Level Control**: Enable/disable DR copying for each backup frequency
   - Set `*_include_in_dr = true` to enable DR copying for that frequency
   - Example: `daily_include_in_dr = true` enables DR copying for daily backups

2. **Resource Level Control**: Tag resources to include/exclude from DR
   - Resources must have the DR tag (default: `add_to_dr = "true"`)
   - Only resources with BOTH the backup schedule tag AND the DR tag are copied

This means:
- If `daily_include_in_dr = false`, NO daily backups are copied to DR
- If `daily_include_in_dr = true`, only daily backups from resources tagged with `add_to_dr = "true"` are copied to DR
- Resources without the DR tag are never copied to DR, even if the plan has DR enabled

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
| dr_tags | Tags to apply to DR region resources | `map(any)` | `{}` | no |
| dr_backup_role_name | Name of the IAM role for AWS Backup in DR region | `string` | `"aws-backup-dr-role"` | no |
| dr_tag_key | Tag key for selecting resources to include in DR copies | `string` | `"add_to_dr"` | no |
| dr_tag_value | Tag value for selecting resources to include in DR copies | `string` | `"true"` | no |
| hourly_include_in_dr | Whether to copy hourly backups to DR region | `bool` | `false` | no |
| hourly_dr_retention_days | Retention period in days for hourly DR backup copies | `number` | `null` | no |
| daily_include_in_dr | Whether to copy daily backups to DR region | `bool` | `false` | no |
| daily_dr_retention_days | Retention period in days for daily DR backup copies | `number` | `null` | no |
| weekly_include_in_dr | Whether to copy weekly backups to DR region | `bool` | `false` | no |
| weekly_dr_retention_days | Retention period in days for weekly DR backup copies | `number` | `null` | no |
| monthly_include_in_dr | Whether to copy monthly backups to DR region | `bool` | `false` | no |
| monthly_dr_retention_days | Retention period in days for monthly DR backup copies | `number` | `null` | no |
| yearly_include_in_dr | Whether to copy yearly backups to DR region | `bool` | `false` | no |
| yearly_dr_retention_days | Retention period in days for yearly DR backup copies | `number` | `null` | no |

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
| dr_kms_key_arn | The Amazon Resource Name (ARN) of the DR KMS key |
| dr_kms_key_id | The globally unique identifier for the DR KMS key |
| dr_backup_role_arn | The ARN of the IAM role used for AWS Backup in DR region |
| dr_backup_role_name | The name of the IAM role used for AWS Backup in DR region |
| dr_backup_vault_arn | The ARN of the DR backup vault |
| dr_backup_vault_id | The ID of the DR backup vault |
| hourly_backup_plan_dr_id | The ID of the hourly backup plan with DR copy |
| daily_backup_plan_dr_id | The ID of the daily backup plan with DR copy |
| weekly_backup_plan_dr_id | The ID of the weekly backup plan with DR copy |
| monthly_backup_plan_dr_id | The ID of the monthly backup plan with DR copy |
| yearly_backup_plan_dr_id | The ID of the yearly backup plan with DR copy |

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
