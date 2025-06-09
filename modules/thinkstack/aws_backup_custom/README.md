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
- Tag-based resource selection for backup plans
- Optional KMS key creation for encrypted backups
- Vault lock capabilities for enhanced security
- Windows VSS support for consistent backups of Windows instances
- **Disaster Recovery (DR) cross-region copies:** Selectively copy backups to a DR region based on dual-tag selection with configurable retention per backup frequency

<p align="right">(<a href="#readme-top">back to top</a>)</p>

<!-- USAGE EXAMPLES -->
## Provider Configuration

When using DR functionality, this module requires two AWS provider configurations:

1. **Primary provider** - For the main region where backups are created
2. **DR provider** - For the disaster recovery region where backups are copied

```hcl
terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = ">= 4.0.0"
    }
  }
}

# Primary region provider
provider "aws" {
  region = "us-east-1"
}

# DR region provider (required when enable_dr = true)
provider "aws" {
  alias  = "dr"
  region = "us-west-2"
}
```

## Usage

### Complete Example: Production and DR Cross-Region Backup Configuration

This example demonstrates a complete, production-ready configuration including standard backup plans with selective cross-region DR copies, KMS key creation, Vault Lock, Windows VSS, and proper tagging for resource selection.

```hcl
module "aws_backup_custom" {
  source = "github.com/thinkstack-co/terraform-modules//modules/thinkstack/aws_backup_custom"

  # Provider configuration (required when using DR)
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

  # Enable Disaster Recovery (DR) cross-region copying
  enable_dr         = true
  dr_region         = "us-west-2"
  dr_vault_name     = "dr-backup-vault"
  
  # Choose which backup plans support DR copying
  hourly_include_in_dr  = false  # Don't copy hourly backups to DR
  daily_include_in_dr   = true   # Enable DR for daily backups
  weekly_include_in_dr  = true   # Enable DR for weekly backups
  monthly_include_in_dr = true   # Enable DR for monthly backups
  yearly_include_in_dr  = false  # Don't copy yearly backups to DR
  
  # Configure DR retention periods (optional - defaults to primary retention)
  daily_dr_retention_days   = 7    # Keep daily DR copies for 7 days
  weekly_dr_retention_days  = 14   # Keep weekly DR copies for 14 days  
  monthly_dr_retention_days = 730  # Keep monthly DR copies for 2 years
  
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

  # Tag configuration for standard backups
  standard_backup_tag_key = "backup_schedule"

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
module "aws_backup_custom" {
  source = "github.com/thinkstack-co/terraform-modules//modules/thinkstack/aws_backup_custom"

  # Provider configuration (required when using DR)
  providers = {
    aws    = aws
    aws.dr = aws.dr
  }

  # Enable only daily backups
  create_daily_plan = true
  daily_retention_days = 30

  # Enable DR for daily backups
  enable_dr = true
  dr_region = "us-west-2"  # Required when enable_dr is true
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

### Disaster Recovery (DR) Implementation

This module implements DR backup copying using AWS Backup's cross-region copy feature with a dual-tag selection mechanism. This provides granular control over which resources get their backups copied to the DR region.

#### How DR Cross-Region Copying Works

The module uses a **dual-tag selection mechanism** for DR backup copying:

1. **Enable DR at the Module Level**: Set `enable_dr = true` to enable DR functionality
2. **Enable DR for Specific Backup Plans**: Choose which backup plans should support DR copying:
   - `hourly_include_in_dr = true` - Enable DR capability for hourly backups
   - `daily_include_in_dr = true` - Enable DR capability for daily backups  
   - `weekly_include_in_dr = true` - Enable DR capability for weekly backups
   - `monthly_include_in_dr = true` - Enable DR capability for monthly backups
   - `yearly_include_in_dr = true` - Enable DR capability for yearly backups

3. **Tag Resources for DR**: Resources must have BOTH tags to be included in DR:
   - The standard backup schedule tag (e.g., `backup_schedule = "daily"`)
   - The DR inclusion tag: `add_to_dr = "true"`

#### Important Note on AWS Backup Copy Actions

AWS Backup's `copy_action` feature copies **ALL** backups in a plan to the destination region. It cannot selectively copy backups based on resource tags. To work around this limitation, the module implements smart selection logic:

- **Primary backup plans** (without copy_action): 
  - Backup resources with ONLY the `backup_schedule` tag
  - Automatically exclude resources that also have `add_to_dr = "true"` to prevent duplicate backups
  
- **Separate DR backup plans** (with copy_action):
  - Only backup resources with BOTH `backup_schedule` AND `add_to_dr = "true"` tags
  - Include cross-region copy to DR

This ensures:
- No duplicate backups are created
- Only resources explicitly tagged for DR have their backups copied to the DR region
- Resources are backed up by exactly one plan (either regular or DR, never both)

#### DR Summary

- **Module Level**: Enable DR with `enable_dr = true` and specify `dr_region`
- **Plan Level**: Enable specific plans for DR (e.g., `daily_include_in_dr = true`)
- **Resource Level**: Tag resources appropriately:
  - `backup_schedule = "daily"` only → Regular backup (no DR copy)
  - `backup_schedule = "daily"` + `add_to_dr = "true"` → DR backup (with copy to DR region)
- **Result**: 
  - Each resource is backed up by exactly one plan (no duplicates)
  - Only resources with BOTH tags have backups copied to DR
  - The module automatically routes resources to the correct plan based on their tags

#### Example DR Configuration

```hcl
module "aws_backup_custom" {
  # ... other configuration ...
  
  # Enable DR functionality
  enable_dr = true
  dr_region = "us-west-2"
  
  # Choose which backup plans support DR
  daily_include_in_dr   = true
  weekly_include_in_dr  = true
  monthly_include_in_dr = false  # Monthly backups won't have DR option
  
  # Configure DR retention (optional - defaults to primary retention)
  daily_dr_retention_days  = 7   # Keep DR copies for 7 days
  weekly_dr_retention_days = 14  # Keep DR copies for 14 days
}

# Resource WITH DR - backups will be copied to DR region
resource "aws_instance" "production_server" {
  # ... instance configuration ...
  
  tags = {
    Name            = "production-server"
    backup_schedule = "daily"      # Primary backup schedule
    add_to_dr       = "true"       # Include in DR copies
  }
}

# Resource WITHOUT DR - backups stay in primary region only
resource "aws_instance" "development_server" {
  # ... instance configuration ...
  
  tags = {
    Name            = "development-server"
    backup_schedule = "daily"      # Primary backup schedule
    # No add_to_dr tag - won't be copied to DR
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
| tags | Map of tags to apply to all resources created by this module | `map(any)` | `{}` | no |
| enable_dr | Whether to enable DR (Disaster Recovery) backup in a separate AWS region | `bool` | `false` | no |
| dr_region | The AWS region to use for DR backups | `string` | `null` | no |
| dr_vault_name | The name of the backup vault to create in the DR region | `string` | `"dr-backup-vault"` | no |
| dr_tags | Tags to apply to DR region resources | `map(any)` | `{}` | no |
| dr_tag_key | Tag key for selecting resources to include in DR copies | `string` | `"add_to_dr"` | no |
| dr_tag_value | Tag value for selecting resources to include in DR copies | `string` | `"true"` | no |
| hourly_include_in_dr | Whether to copy hourly backups to DR region | `bool` | `false` | no |
| daily_include_in_dr | Whether to copy daily backups to DR region | `bool` | `false` | no |
| weekly_include_in_dr | Whether to copy weekly backups to DR region | `bool` | `false` | no |
| monthly_include_in_dr | Whether to copy monthly backups to DR region | `bool` | `false` | no |
| yearly_include_in_dr | Whether to copy yearly backups to DR region | `bool` | `false` | no |
| hourly_dr_retention_days | Retention period in days for hourly DR backup copies. If null, uses hourly_retention_days | `number` | `null` | no |
| daily_dr_retention_days | Retention period in days for daily DR backup copies. If null, uses daily_retention_days | `number` | `null` | no |
| weekly_dr_retention_days | Retention period in days for weekly DR backup copies. If null, uses weekly_retention_days | `number` | `null` | no |
| monthly_dr_retention_days | Retention period in days for monthly DR backup copies. If null, uses monthly_retention_days | `number` | `null` | no |
| yearly_dr_retention_days | Retention period in days for yearly DR backup copies. If null, uses yearly_retention_days | `number` | `null` | no |

## Outputs

| Name | Description |
|------|-------------|
| backup_vault_arns | Map of backup vault names to their ARNs |
| backup_vault_ids | Map of backup vault names to their IDs |
| kms_key_arn | ARN of the KMS key used for backup encryption (if created) |
| kms_key_id | The globally unique identifier for the KMS key |
| backup_role_arn | The Amazon Resource Name (ARN) of the IAM role used for AWS Backup |
| backup_role_name | The name of the IAM role used for AWS Backup |
| hourly_backup_plan_id | The ID of the hourly backup plan |
| daily_backup_plan_id | The ID of the daily backup plan |
| weekly_backup_plan_id | The ID of the weekly backup plan |
| monthly_backup_plan_id | The ID of the monthly backup plan |
| yearly_backup_plan_id | The ID of the yearly backup plan |
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
| account_id | The AWS account ID |
| caller_arn | The ARN of the current IAM identity |
| region | The AWS region |
| dr_kms_key_arn | The Amazon Resource Name (ARN) of the DR KMS key |
| dr_kms_key_id | The globally unique identifier for the DR KMS key |
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
