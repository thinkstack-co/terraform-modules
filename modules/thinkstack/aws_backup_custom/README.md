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
- Creating standard backup plans (hourly, daily, weekly, monthly, yearly) with configurable schedules and retention periods
- Creating custom backup plans with specific schedules and retention periods
- Targeting resources using tag-based selection
- Supporting EC2 instance backups with Windows VSS support

All resources are conditionally created based on the corresponding `create_*_plan` variables. When you enable a backup plan (e.g., `create_daily_plan = true`), the module automatically creates the corresponding vault and configures the plan to use it.

## Features

- Automatic backup vault creation based on enabled backup plans
- KMS key encryption for backup vaults
- Tag-based resource selection for backup plans
- Windows VSS support for EC2 instances with granular control
- Configurable backup schedules and retention periods
- Custom backup plans with flexible configuration

## Windows VSS Support

This module provides comprehensive Windows VSS (Volume Shadow Copy Service) support for EC2 instances, ensuring application-consistent backups for Windows workloads:

1. **Global VSS Control**: 
   - The `enable_windows_vss` variable acts as a master switch for Windows VSS support
   - When set to `true`, Windows VSS can be enabled for individual backup plans

2. **Plan-Specific VSS Control**:
   - Each backup plan has its own VSS control variable:
     - `hourly_windows_vss`
     - `daily_windows_vss`
     - `weekly_windows_vss`
     - `monthly_windows_vss`
     - `yearly_windows_vss`
   - Custom backup plans can also enable VSS via the `windows_vss` property

3. **Conditional Activation**:
   - Windows VSS is only enabled when both the global `enable_windows_vss` AND the plan-specific VSS variable are set to `true`
   - This provides granular control over which backup plans use VSS

Windows VSS is particularly important for consistent backups of Windows instances running applications like SQL Server, Exchange, and Active Directory.

## Tagging Strategy

This module uses a tag-based approach to select resources for backup:

1. **Standard Backup Plans** (hourly, daily, weekly, monthly, yearly):
   - Resources are selected based on the tag key specified by `standard_backup_tag_key` (defaults to "backup_schedule")
   - Tag values should match the plan name: "hourly", "daily", "weekly", "monthly", or "yearly"
   
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

  # Enable specific backup plans
  create_hourly_plan  = true
  create_daily_plan   = true
  create_weekly_plan  = true
  create_monthly_plan = true
  create_yearly_plan  = true
}
```

## Example Configurations

This section provides specific examples for different backup scenarios to help you understand how to configure the module for your needs.

### Example 1: Hourly Backup Plan

This example shows how to configure an hourly backup plan for critical workloads that need frequent backups.

```hcl
module "aws_backup_hourly" {
  source = "github.com/thinkstack-co/terraform-modules//modules/thinkstack/aws_backup_custom"

  # Enable only the hourly backup plan
  create_hourly_plan = true
  
  # Configure hourly backup settings
  hourly_schedule = "cron(0 * * * ? *)"  # Every hour at minute 0
  hourly_retention_days = 1              # Keep hourly backups for 1 day
  hourly_enable_continuous_backup = true # Enable point-in-time recovery
  
  # Windows VSS support for consistent Windows backups
  enable_windows_vss = true              # Enable global Windows VSS support
  hourly_windows_vss = true              # Enable VSS for hourly backups
  
  # Optional: Customize the tag key (defaults to "backup_schedule")
  standard_backup_tag_key = "backup_schedule"
}
```

#### Resource Tagging for Hourly Backups

To include resources in the hourly backup plan, tag them as follows:

```hcl
resource "aws_instance" "critical_server" {
  ami           = "ami-0c55b159cbfafe1f0"
  instance_type = "t3.micro"
  
  tags = {
    Name = "critical-server"
    backup_schedule = "hourly"  # This tag includes the instance in the hourly backup plan
  }
}
```

### Example 2: Standard Daily Backup Plan

This example shows how to configure a daily backup plan for EC2 instances.

```hcl
module "aws_backup_daily" {
  source = "github.com/thinkstack-co/terraform-modules//modules/thinkstack/aws_backup_custom"

  # Enable only the daily backup plan
  create_daily_plan = true
  
  # Configure daily backup settings
  daily_schedule = "cron(0 1 * * ? *)"  # Daily at 1:00 AM UTC
  daily_retention_days = 7              # Keep daily backups for 7 days
  daily_enable_continuous_backup = true # Enable point-in-time recovery
  
  # Optional: Customize the tag key (defaults to "backup_schedule")
  standard_backup_tag_key = "backup_schedule"
}
```

#### Resource Tagging for Daily Backups

To include an EC2 instance in the daily backup plan, tag it as follows:

```hcl
resource "aws_instance" "app_server" {
  ami           = "ami-0c55b159cbfafe1f0"
  instance_type = "t3.micro"
  
  tags = {
    Name = "app-server"
    backup_schedule = "daily"  # This tag includes the instance in the daily backup plan
  }
}
```

### Example 3: Weekly and Monthly Backup Plans

This example shows how to configure both weekly and monthly backup plans with different retention periods.

```hcl
module "aws_backup_weekly_monthly" {
  source = "github.com/thinkstack-co/terraform-modules//modules/thinkstack/aws_backup_custom"

  # Enable weekly and monthly backup plans
  create_weekly_plan  = true
  create_monthly_plan = true
  
  # Weekly backup configuration
  weekly_schedule = "cron(0 2 ? * SUN *)"  # Every Sunday at 2:00 AM UTC
  weekly_retention_days = 30               # Keep weekly backups for 30 days
  
  # Monthly backup configuration
  monthly_schedule = "cron(0 3 1 * ? *)"    # 1st of each month at 3:00 AM UTC
  monthly_retention_days = 90               # Keep monthly backups for 90 days
}
```

#### Resource Tagging for Weekly and Monthly Backups

To include resources in these backup plans, tag them as follows:

```hcl
# EC2 instance for weekly backups
resource "aws_instance" "weekly_backup_server" {
  ami           = "ami-0c55b159cbfafe1f0"
  instance_type = "t3.micro"
  
  tags = {
    Name = "weekly-backup-server"
    backup_schedule = "weekly"  # This tag includes the instance in the weekly backup plan
  }
}

# RDS instance for monthly backups
resource "aws_db_instance" "monthly_backup_db" {
  # ... RDS configuration ...
  
  tags = {
    Name = "monthly-backup-db"
    backup_schedule = "monthly"  # This tag includes the database in the monthly backup plan
  }
}
```

### Example 4: Custom Database Backup Plan

This example shows how to create a custom backup plan specifically for databases, using the monthly vault.

```hcl
module "aws_backup_custom_db" {
  source = "github.com/thinkstack-co/terraform-modules//modules/thinkstack/aws_backup_custom"

  # Enable monthly plan to create the monthly vault
  create_monthly_plan = true
  
  # Set the default custom backup tag key
  default_custom_backup_tag_key = "backup_custom"
  
  # Custom database backup plan
  custom_backup_plans = {
    database_backup = {
      vault_name               = "monthly"        # Uses the monthly vault
      schedule                 = "cron(0 5 15 * ? *)"  # 15th of each month at 5:00 AM UTC
      enable_continuous_backup = true             # Enable continuous backup for point-in-time recovery
      retention_days           = 120              # Keep backups for 120 days
      resource_type            = "RDS"            # Target RDS resources
      tag_key                  = ""               # Empty string will use the default_custom_backup_tag_key
      tag_value                = "database"       # Resources with backup_custom=database will be backed up
      windows_vss              = true             # Enable Windows VSS for database backups
      tags = {
        backup_type = "database"
      }
    }
  }
}
```

#### Resource Tagging for Custom Database Backups

When `tag_key` is empty, the module uses the `default_custom_backup_tag_key` (in this case, "backup_custom"). Tag your RDS instances as follows:

```hcl
resource "aws_db_instance" "production_database" {
  # ... RDS configuration ...
  
  tags = {
    Name = "production-database"
    backup_custom = "database"  # This tag includes the database in the database_backup plan
    # The tag key "backup_custom" comes from default_custom_backup_tag_key
    # The tag value "database" matches the tag_value in the custom_backup_plans configuration
  }
}
```

### Example 5: Custom Application Backup Plan with Custom Tag Key

This example shows how to create a custom backup plan with a custom tag key for critical applications.

```hcl
module "aws_backup_custom_app" {
  source = "github.com/thinkstack-co/terraform-modules//modules/thinkstack/aws_backup_custom"

  # Enable weekly plan to create the weekly vault
  create_weekly_plan = true
  
  # Enable Windows VSS support
  enable_windows_vss = true
  
  # Custom application backup plan with custom tag key
  custom_backup_plans = {
    critical_app_backup = {
      vault_name               = "weekly"         # Uses the weekly vault
      schedule                 = "cron(0 4 ? * MON-FRI *)"  # Weekdays at 4:00 AM UTC
      enable_continuous_backup = false            # Disable continuous backup
      retention_days           = 14               # Keep backups for 14 days
      resource_type            = "EC2"            # Target EC2 resources
      tag_key                  = "app_backup"     # Custom tag key
      tag_value                = "critical"       # Resources with app_backup=critical will be backed up
      windows_vss              = true             # Enable Windows VSS for this custom plan
      tags = {
        backup_type = "application"
      }
    }
  }
}
```

#### Resource Tagging for Custom Application Backups

When `tag_key` is explicitly set (in this case, "app_backup"), use that tag key instead of the default. Tag your EC2 instances as follows:

```hcl
resource "aws_instance" "critical_application" {
  ami           = "ami-0c55b159cbfafe1f0"
  instance_type = "t3.medium"
  
  tags = {
    Name = "critical-application"
    app_backup = "critical"  # This tag includes the instance in the critical_app_backup plan
    # The tag key "app_backup" comes from the tag_key in the custom_backup_plans configuration
    # The tag value "critical" matches the tag_value in the custom_backup_plans configuration
  }
}
```

### Example 6: EFS Backup Plan Using Daily Vault

This example shows how to create a custom backup plan for EFS filesystems using the daily vault.

```hcl
module "aws_backup_efs" {
  source = "github.com/thinkstack-co/terraform-modules//modules/thinkstack/aws_backup_custom"

  # Enable daily plan to create the daily vault
  create_daily_plan = true
  
  # Set the default custom backup tag key
  default_custom_backup_tag_key = "backup_custom"
  
  # Custom EFS backup plan
  custom_backup_plans = {
    efs_backup = {
      vault_name               = "daily"          # Uses the daily vault
      schedule                 = "cron(0 2 * * ? *)"  # Daily at 2:00 AM UTC
      enable_continuous_backup = true             # Enable continuous backup
      retention_days           = 7                # Keep backups for 7 days
      resource_type            = "EFS"            # Target EFS resources
      tag_key                  = "backup_custom"  # Explicitly use backup_custom tag key
      tag_value                = "efs"            # Resources with backup_custom=efs will be backed up
      tags = {
        backup_type = "filesystem"
      }
    }
  }
}
```

#### Resource Tagging for EFS Backups

Tag your EFS filesystems as follows:

```hcl
resource "aws_efs_file_system" "shared_storage" {
  creation_token = "shared-storage"
  
  tags = {
    Name = "shared-storage"
    backup_custom = "efs"  # This tag includes the filesystem in the efs_backup plan
    # The tag key "backup_custom" matches the tag_key in the custom_backup_plans configuration
    # The tag value "efs" matches the tag_value in the custom_backup_plans configuration
  }
}
```

### Example 7: Complete Configuration with All Plans and Windows VSS

This example shows a complete configuration with all standard backup plans and Windows VSS support.

```hcl
module "aws_backup_complete" {
  source = "github.com/thinkstack-co/terraform-modules//modules/thinkstack/aws_backup_custom"

  # Create KMS key for encryption
  create_kms_key = true
  
  # Enable all standard backup plans
  create_hourly_plan  = true
  create_daily_plan   = true
  create_weekly_plan  = true
  create_monthly_plan = true
  create_yearly_plan  = true
  
  # Configure backup schedules
  hourly_schedule  = "cron(0 * * * ? *)"    # Every hour at minute 0
  daily_schedule   = "cron(0 1 * * ? *)"    # Daily at 1:00 AM UTC
  weekly_schedule  = "cron(0 2 ? * SUN *)"  # Weekly on Sunday at 2:00 AM UTC
  monthly_schedule = "cron(0 3 1 * ? *)"    # Monthly on the 1st at 3:00 AM UTC
  yearly_schedule  = "cron(0 4 1 1 ? *)"    # Yearly on January 1st at 4:00 AM UTC
  
  # Configure retention periods
  hourly_retention_days  = 1    # Keep hourly backups for 1 day
  daily_retention_days   = 7    # Keep daily backups for 7 days
  weekly_retention_days  = 30   # Keep weekly backups for 30 days
  monthly_retention_days = 365  # Keep monthly backups for 365 days
  yearly_retention_days  = 1825 # Keep yearly backups for 5 years (1825 days)
  
  # Enable continuous backup for hourly and daily plans
  hourly_enable_continuous_backup = true
  daily_enable_continuous_backup = true
  
  # Configure Windows VSS support
  enable_windows_vss = true       # Enable global Windows VSS support
  hourly_windows_vss = true       # Enable VSS for hourly backups
  daily_windows_vss = true        # Enable VSS for daily backups
  weekly_windows_vss = false      # Disable VSS for weekly backups
  monthly_windows_vss = false     # Disable VSS for monthly backups
  yearly_windows_vss = false      # Disable VSS for yearly backups
  
  # Custom backup plan for database servers
  custom_backup_plans = {
    database_backup = {
      vault_name               = "daily"         # Uses the daily vault
      schedule                 = "cron(30 1 * * ? *)"  # Daily at 1:30 AM UTC
      enable_continuous_backup = true            # Enable continuous backup
      retention_days           = 14              # Keep backups for 14 days
      resource_type            = "EC2"           # Target EC2 resources
      tag_key                  = ""              # Use default_custom_backup_tag_key
      tag_value                = "database"      # Resources with backup_custom=database will be backed up
      windows_vss              = true            # Enable Windows VSS for database backups
      tags = {
        backup_type = "database"
      }
    }
  }
}
```

#### Resource Tagging for Complete Configuration

Tag your resources as follows:

```hcl
# EC2 instance with hourly backups
resource "aws_instance" "critical_app_server" {
  ami           = "ami-0c55b159cbfafe1f0"
  instance_type = "t3.micro"
  
  tags = {
    Name = "critical-app-server"
    backup_schedule = "hourly"  # This tag includes the instance in the hourly backup plan
  }
}

# RDS instance with custom database backup plan
resource "aws_db_instance" "critical_database" {
  # ... RDS configuration ...
  
  tags = {
    Name = "critical-database"
    backup_custom = "database"  # This tag includes the database in the database_backup plan
  }
}
```

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| create_kms_key | Whether to create a new KMS key for backups | `bool` | `false` | no |
| kms_key_arn | The ARN of an existing KMS key to use for encrypting backups | `string` | `null` | no |
| kms_key_description | The description of the KMS key | `string` | `"AWS Backup KMS key for encrypting backups"` | no |
| kms_key_deletion_window | Duration in days after which the key is deleted | `number` | `30` | no |
| kms_key_enable_key_rotation | Specifies whether key rotation is enabled | `bool` | `true` | no |
| key_bypass_policy_lockout_safety_check | Specifies whether to disable the policy lockout check | `bool` | `false` | no |
| key_customer_master_key_spec | Specifies the key spec | `string` | `"SYMMETRIC_DEFAULT"` | no |
| key_usage | Specifies the intended use of the key | `string` | `"ENCRYPT_DECRYPT"` | no |
| key_is_enabled | Specifies whether the key is enabled | `bool` | `true` | no |
| key_policy | A valid policy JSON document | `string` | `null` | no |
| force_destroy | Whether all recovery points should be deleted when destroying the vault | `bool` | `false` | no |
| backup_role_name | The name of the IAM role for AWS Backup | `string` | `"aws-backup-custom-role"` | no |
| backup_start_window | The amount of time in minutes before beginning a backup | `number` | `60` | no |
| backup_completion_window | The amount of time in minutes AWS Backup attempts a backup before canceling | `number` | `1440` | no |
| create_hourly_plan | Whether to create an hourly backup plan | `bool` | `false` | no |
| hourly_plan_name | The name of the hourly backup plan | `string` | `"hourly-backup-plan"` | no |
| hourly_schedule | CRON expression for hourly backups | `string` | `"cron(0 * * * ? *)"` | no |
| hourly_retention_days | Number of days to retain hourly backups | `number` | `1` | no |
| hourly_enable_continuous_backup | Whether to enable continuous backups for hourly backup plan | `bool` | `true` | no |
| hourly_windows_vss | Whether to enable Windows VSS for hourly backup plan | `bool` | `false` | no |
| create_daily_plan | Whether to create a daily backup plan | `bool` | `false` | no |
| daily_plan_name | The name of the daily backup plan | `string` | `"daily-backup-plan"` | no |
| daily_schedule | CRON expression for daily backups | `string` | `"cron(0 1 * * ? *)"` | no |
| daily_retention_days | Number of days to retain daily backups | `number` | `7` | no |
| daily_enable_continuous_backup | Whether to enable continuous backups for daily backup plan | `bool` | `false` | no |
| create_weekly_plan | Whether to create a weekly backup plan | `bool` | `false` | no |
| weekly_plan_name | The name of the weekly backup plan | `string` | `"weekly-backup-plan"` | no |
| weekly_schedule | CRON expression for weekly backups | `string` | `"cron(0 2 ? * SUN *)"` | no |
| weekly_retention_days | Number of days to retain weekly backups | `number` | `30` | no |
| weekly_enable_continuous_backup | Whether to enable continuous backups for weekly backup plan | `bool` | `false` | no |
| create_monthly_plan | Whether to create a monthly backup plan | `bool` | `false` | no |
| monthly_plan_name | The name of the monthly backup plan | `string` | `"monthly-backup-plan"` | no |
| monthly_schedule | CRON expression for monthly backups | `string` | `"cron(0 3 1 * ? *)"` | no |
| monthly_retention_days | Number of days to retain monthly backups | `number` | `90` | no |
| monthly_enable_continuous_backup | Whether to enable continuous backups for monthly backup plan | `bool` | `false` | no |
| create_yearly_plan | Whether to create a yearly backup plan | `bool` | `false` | no |
| yearly_plan_name | The name of the yearly backup plan | `string` | `"yearly-backup-plan"` | no |
| yearly_schedule | CRON expression for yearly backups | `string` | `"cron(0 4 1 1 ? *)"` | no |
| yearly_retention_days | Number of days to retain yearly backups | `number` | `365` | no |
| yearly_enable_continuous_backup | Whether to enable continuous backups for yearly backup plan | `bool` | `false` | no |
| enable_windows_vss | Whether to enable Windows VSS for all backup plans that support it | `bool` | `false` | no |
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
| hourly_backup_plan_id | The ID of the hourly backup plan |
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
