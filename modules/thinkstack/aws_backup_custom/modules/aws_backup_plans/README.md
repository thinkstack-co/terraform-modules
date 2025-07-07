# AWS Backup Plans Terraform Module

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

<h3 align="center">AWS Backup Plans Module</h3>
  <p align="center">
    This module creates and manages AWS Backup plans with support for multiple schedules (hourly, daily, weekly, monthly, yearly), disaster recovery (DR) replication, and tag-based resource selection.
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

This Terraform module creates and manages AWS Backup plans with comprehensive scheduling options and disaster recovery capabilities. The module features a powerful prefix-based naming system that allows you to create unlimited variations of backup plans with clear identification and organization.

Key features:
- **Multiple Schedule Types**: Hourly, daily, weekly, monthly, and yearly backup schedules
- **Disaster Recovery**: Built-in DR replication support with configurable retention
- **Flexible Resource Selection**: Tag-based and resource-specific backup selection
- **Prefix System**: Create multiple plan variations with automatic naming and tagging
- **Cold Storage Support**: Lifecycle management for cost optimization
- **Continuous Backup**: Point-in-time recovery support for compatible resources

<p align="right">(<a href="#readme-top">back to top</a>)</p>

<!-- USAGE EXAMPLES -->
## Usage

### Hourly Backup Example

```hcl
# First, create the backup vaults
module "backup_vaults" {
  source = "github.com/thinkstack-co/terraform-modules//modules/thinkstack/aws_backup_custom/modules/aws_backup_vault"
  
  create_single_vault = false
  vault_name_prefix   = "app-critical"
  
  enable_hourly_vault = true
  enable_daily_vault  = false
  enable_weekly_vault = false
  enable_monthly_vault = false
  enable_yearly_vault = false
  
  kms_key_arn = aws_kms_key.backup.arn
  
  tags = {
    terraform   = "true"
    created_by  = "Terraform"
    environment = "production"
  }
}

# Then, create the backup plan referencing the vault
module "hourly_backups" {
  source = "github.com/thinkstack-co/terraform-modules//modules/thinkstack/aws_backup_custom/modules/aws_backup_plans"
  
  name                    = "backup_plan"
  plan_prefix             = "app-critical"
  create_backup_selection = true
  
  # Simple server selection
  server_selection_tag   = "HourlyBackup"
  server_selection_value = "true"
  
  # Hourly backup configuration
  enable_hourly_plan              = true
  hourly_schedule                 = "cron(0 * ? * * *)"  # Every hour
  hourly_retention_days           = 7                   # Keep for 1 week
  hourly_vault_name               = module.backup_vaults.scheduled_vault_names["hourly"]
  hourly_enable_continuous_backup = false
  hourly_start_window             = 60
  hourly_completion_window        = 120
  
  tags = {
    terraform   = "true"
    created_by  = "Terraform"
    environment = "production"
  }
}
```

### Daily Backup Example with DR

```hcl
# Define providers for multi-region DR
provider "aws" {
  region = "us-east-1"
}

provider "aws" {
  alias  = "dr"
  region = "us-west-2"
}

# KMS keys for encryption
resource "aws_kms_key" "backup" {
  description = "KMS key for backup vault encryption"
}

resource "aws_kms_key" "dr_backup" {
  provider    = aws.dr
  description = "KMS key for DR backup vault encryption"
}

# Create the backup vaults with DR
module "backup_vaults" {
  source = "github.com/thinkstack-co/terraform-modules//modules/thinkstack/aws_backup_custom/modules/aws_backup_vault"
  
  providers = {
    aws    = aws
    aws.dr = aws.dr
  }
  
  create_single_vault = false
  vault_name_prefix   = "prod-database"
  
  # Enable daily vault
  enable_hourly_vault  = false
  enable_daily_vault   = true
  enable_weekly_vault  = false
  enable_monthly_vault = false
  enable_yearly_vault  = false
  
  # Enable DR
  enable_dr            = true
  enable_daily_dr_vault = true  # Enable DR for daily vault
  dr_vault_name_prefix = "prod-database-dr"
  
  kms_key_arn    = aws_kms_key.backup.arn
  dr_kms_key_arn = aws_kms_key.dr_backup.arn
  
  tags = {
    terraform   = "true"
    created_by  = "Terraform"
    environment = "production"
  }
}

# Create the backup plan referencing the vaults
module "daily_backups_with_dr" {
  source = "github.com/thinkstack-co/terraform-modules//modules/thinkstack/aws_backup_custom/modules/aws_backup_plans"
  
  name                    = "backup_plan"
  plan_prefix             = "prod-database"
  create_backup_selection = true
  
  # Simple server selection
  server_selection_tag   = "DailyBackup"
  server_selection_value = "enabled"
  
  # Daily backup configuration
  enable_daily_plan              = true
  daily_schedule                 = "cron(0 3 ? * * *)"  # 3 AM daily
  daily_retention_days           = 30                  # Keep for 30 days
  daily_vault_name               = module.backup_vaults.scheduled_vault_names["daily"]
  daily_enable_continuous_backup = true                # Enable PITR
  daily_start_window             = 60
  daily_completion_window        = 180
  
  # Daily DR configuration
  enable_daily_dr_copy        = true
  daily_dr_vault_arn          = module.backup_vaults.dr_vault_arns["daily"]
  daily_dr_retention_days     = 14  # DR copies kept for 14 days
  daily_dr_cold_storage_after = null
  
  tags = {
    terraform   = "true"
    created_by  = "Terraform"
    environment = "production"
    compliance  = "required"
  }
  
  # Providers for multi-region DR
  providers = {
    aws    = aws
    aws.dr = aws.dr
  }
}
```

### Weekly Backup Example

```hcl
# Create the backup vaults
module "backup_vaults" {
  source = "github.com/thinkstack-co/terraform-modules//modules/thinkstack/aws_backup_custom/modules/aws_backup_vault"
  
  create_single_vault = false
  vault_name_prefix   = "weekly-archives"
  
  enable_hourly_vault  = false
  enable_daily_vault   = false
  enable_weekly_vault  = true
  enable_monthly_vault = false
  enable_yearly_vault  = false
  
  kms_key_arn = aws_kms_key.backup.arn
  
  tags = {
    terraform   = "true"
    created_by  = "Terraform"
    environment = "production"
  }
}

# Create the backup plan
module "weekly_backups" {
  source = "github.com/thinkstack-co/terraform-modules//modules/thinkstack/aws_backup_custom/modules/aws_backup_plans"
  
  name                    = "backup_plan"
  plan_prefix             = "weekly-archives"
  create_backup_selection = true
  
  # Simple server selection
  server_selection_tag   = "WeeklyBackup"
  server_selection_value = "true"
  
  # Weekly backup configuration
  enable_weekly_plan              = true
  weekly_schedule                 = "cron(0 2 ? * 1 *)"  # Monday at 2 AM
  weekly_retention_days           = 90                  # Keep for 90 days
  weekly_vault_name               = module.backup_vaults.scheduled_vault_names["weekly"]
  weekly_enable_continuous_backup = false
  weekly_start_window             = 60
  weekly_completion_window        = 360
  weekly_cold_storage_after       = 30  # Move to cold storage after 30 days
  
  tags = {
    terraform   = "true"
    created_by  = "Terraform"
    environment = "production"
  }
}
```

### Monthly Backup Example

```hcl
# Create the backup vaults with DR
module "backup_vaults" {
  source = "github.com/thinkstack-co/terraform-modules//modules/thinkstack/aws_backup_custom/modules/aws_backup_vault"
  
  providers = {
    aws    = aws
    aws.dr = aws.dr
  }
  
  create_single_vault = false
  vault_name_prefix   = "compliance-monthly"
  
  enable_hourly_vault  = false
  enable_daily_vault   = false
  enable_weekly_vault  = false
  enable_monthly_vault = true
  enable_yearly_vault  = false
  
  # Enable DR for monthly vault
  enable_dr             = true
  enable_monthly_dr_vault = true
  dr_vault_name_prefix  = "compliance-monthly-dr"
  
  kms_key_arn    = aws_kms_key.backup.arn
  dr_kms_key_arn = aws_kms_key.dr_backup.arn
  
  tags = {
    terraform   = "true"
    created_by  = "Terraform"
    environment = "production"
    compliance  = "sox"
  }
}

# Create the backup plan
module "monthly_backups" {
  source = "github.com/thinkstack-co/terraform-modules//modules/thinkstack/aws_backup_custom/modules/aws_backup_plans"
  
  name                    = "backup_plan"
  plan_prefix             = "compliance-monthly"
  create_backup_selection = true
  
  # Simple server selection
  server_selection_tag   = "MonthlyBackup"
  server_selection_value = "true"
  
  # Monthly backup configuration
  enable_monthly_plan              = true
  monthly_schedule                 = "cron(0 1 1 * ? *)"  # 1st of month at 1 AM
  monthly_retention_days           = 365                 # Keep for 1 year
  monthly_vault_name               = module.backup_vaults.scheduled_vault_names["monthly"]
  monthly_enable_continuous_backup = false
  monthly_start_window             = 60
  monthly_completion_window        = 720
  monthly_cold_storage_after       = 90  # Cold storage after 3 months
  
  # Monthly DR configuration
  enable_monthly_dr_copy        = true
  monthly_dr_vault_arn          = module.backup_vaults.dr_vault_arns["monthly"]
  monthly_dr_retention_days     = 180  # DR copies kept for 6 months
  monthly_dr_cold_storage_after = 30   # DR cold storage after 1 month
  
  tags = {
    terraform   = "true"
    created_by  = "Terraform"
    environment = "production"
    compliance  = "sox"
  }
  
  providers = {
    aws    = aws
    aws.dr = aws.dr
  }
}
```

### Yearly Backup Example

```hcl
# Create the backup vaults with DR
module "backup_vaults" {
  source = "github.com/thinkstack-co/terraform-modules//modules/thinkstack/aws_backup_custom/modules/aws_backup_vault"
  
  providers = {
    aws    = aws
    aws.dr = aws.dr
  }
  
  create_single_vault = false
  vault_name_prefix   = "long-term-retention"
  
  enable_hourly_vault  = false
  enable_daily_vault   = false
  enable_weekly_vault  = false
  enable_monthly_vault = false
  enable_yearly_vault  = true
  
  # Enable DR for yearly vault
  enable_dr            = true
  enable_yearly_dr_vault = true
  dr_vault_name_prefix = "long-term-retention-dr"
  
  kms_key_arn    = aws_kms_key.backup.arn
  dr_kms_key_arn = aws_kms_key.dr_backup.arn
  
  # Enable vault lock for compliance
  enable_vault_lock             = true
  yearly_min_retention_days     = 2555  # 7 years minimum
  
  tags = {
    terraform   = "true"
    created_by  = "Terraform"
    environment = "production"
    retention   = "long-term"
  }
}

# Create the backup plan
module "yearly_backups" {
  source = "github.com/thinkstack-co/terraform-modules//modules/thinkstack/aws_backup_custom/modules/aws_backup_plans"
  
  name                    = "backup_plan"
  plan_prefix             = "long-term-retention"
  create_backup_selection = true
  
  # Simple server selection
  server_selection_tag   = "YearlyBackup"
  server_selection_value = "true"
  
  # Yearly backup configuration
  enable_yearly_plan              = true
  yearly_schedule                 = "cron(0 0 1 1 ? *)"  # Jan 1st at midnight
  yearly_retention_days           = 2555                # Keep for 7 years
  yearly_vault_name               = module.backup_vaults.scheduled_vault_names["yearly"]
  yearly_enable_continuous_backup = false
  yearly_start_window             = 60
  yearly_completion_window        = 1440  # 24 hours
  yearly_cold_storage_after       = 365   # Cold storage after 1 year
  
  # Yearly DR configuration
  enable_yearly_dr_copy        = true
  yearly_dr_vault_arn          = module.backup_vaults.dr_vault_arns["yearly"]
  yearly_dr_retention_days     = 1825  # DR copies kept for 5 years
  yearly_dr_cold_storage_after = 180   # DR cold storage after 6 months
  
  tags = {
    terraform   = "true"
    created_by  = "Terraform"
    environment = "production"
    retention   = "long-term"
  }
  
  providers = {
    aws    = aws
    aws.dr = aws.dr
  }
}
```

### Comprehensive Multi-Schedule Example

```hcl
# Create all backup vaults with selective DR
module "backup_vaults" {
  source = "github.com/thinkstack-co/terraform-modules//modules/thinkstack/aws_backup_custom/modules/aws_backup_vault"
  
  providers = {
    aws    = aws
    aws.dr = aws.dr
  }
  
  create_single_vault = false
  vault_name_prefix   = "prod-critical"
  
  # Enable all scheduled vaults
  enable_hourly_vault  = true
  enable_daily_vault   = true
  enable_weekly_vault  = true
  enable_monthly_vault = true
  enable_yearly_vault  = true
  
  # Enable DR with selective vault DR
  enable_dr            = true
  dr_vault_name_prefix = "prod-critical-dr"
  
  # Selective DR - only for important schedules
  enable_hourly_dr_vault  = false  # No DR for hourly
  enable_daily_dr_vault   = true   # DR for daily
  enable_weekly_dr_vault  = true   # DR for weekly
  enable_monthly_dr_vault = true   # DR for monthly
  enable_yearly_dr_vault  = true   # DR for yearly
  
  kms_key_arn    = aws_kms_key.backup.arn
  dr_kms_key_arn = aws_kms_key.dr_backup.arn
  
  # Vault lock for compliance
  enable_vault_lock         = true
  vault_lock_changeable_for = 3  # 3 days grace period
  
  tags = {
    terraform   = "true"
    created_by  = "Terraform"
    environment = "production"
    criticality = "high"
  }
}

# Create comprehensive backup plans
module "comprehensive_backup_plan" {
  source = "github.com/thinkstack-co/terraform-modules//modules/thinkstack/aws_backup_custom/modules/aws_backup_plans"
  
  # Core configuration
  name                     = "backup_plan"
  plan_prefix              = "prod-critical"
  use_individual_plans     = true   # Create separate plans per schedule
  create_separate_dr_plans = false  # Use copy actions for DR
  create_backup_selection  = true
  enable_s3_backup         = true   # Include S3 backup permissions
  
  # Simple server selection
  server_selection_tag   = "CriticalInfrastructure"
  server_selection_value = "true"
  
  # Enable all backup schedules
  enable_hourly_plan  = true
  enable_daily_plan   = true
  enable_weekly_plan  = true
  enable_monthly_plan = true
  enable_yearly_plan  = true
  
  # Reference vault names from vault module
  hourly_vault_name  = module.backup_vaults.scheduled_vault_names["hourly"]
  daily_vault_name   = module.backup_vaults.scheduled_vault_names["daily"]
  weekly_vault_name  = module.backup_vaults.scheduled_vault_names["weekly"]
  monthly_vault_name = module.backup_vaults.scheduled_vault_names["monthly"]
  yearly_vault_name  = module.backup_vaults.scheduled_vault_names["yearly"]
  
  # Enable DR for critical schedules (no DR for hourly)
  enable_daily_dr_copy   = true
  enable_weekly_dr_copy  = true
  enable_monthly_dr_copy = true
  enable_yearly_dr_copy  = true
  
  # Reference DR vault ARNs from vault module
  daily_dr_vault_arn   = module.backup_vaults.dr_vault_arns["daily"]
  weekly_dr_vault_arn  = module.backup_vaults.dr_vault_arns["weekly"]
  monthly_dr_vault_arn = module.backup_vaults.dr_vault_arns["monthly"]
  yearly_dr_vault_arn  = module.backup_vaults.dr_vault_arns["yearly"]
  
  tags = {
    terraform   = "true"
    created_by  = "Terraform"
    environment = "production"
    criticality = "high"
    cost_center = "infrastructure"
  }
  
  providers = {
    aws    = aws
    aws.dr = aws.dr
  }
}
```

### How to Tag Your Servers

Each backup plan uses a simple tag-based selection system. You need to tag your resources with the appropriate tag key and value:

```hcl
# Example: Tag servers for different backup plans
resource "aws_instance" "web_server" {
  # ... instance configuration ...
  
  tags = {
    Name          = "WebServer01"
    Environment   = "Production"
    
    # Backup tags - add the ones you need
    HourlyBackup  = "true"      # Will be backed up by hourly plan
    DailyBackup   = "enabled"   # Will be backed up by daily plan
    WeeklyBackup  = "true"      # Will be backed up by weekly plan
    # MonthlyBackup = "true"    # Not tagged, won't be in monthly backups
    # YearlyBackup  = "true"    # Not tagged, won't be in yearly backups
  }
}

# Example: Tag RDS database for daily backups only
resource "aws_db_instance" "main" {
  # ... database configuration ...
  
  tags = {
    Name         = "MainDatabase"
    Environment  = "Production"
    DailyBackup  = "enabled"    # Only daily backups for this database
  }
}

# Example: Tag S3 bucket for long-term retention
resource "aws_s3_bucket" "archives" {
  # ... bucket configuration ...
  
  tags = {
    Name          = "CompanyArchives"
    YearlyBackup  = "true"      # Only yearly backups for archives
  }
}

# Example: Using custom tag keys and values
resource "aws_instance" "critical_server" {
  tags = {
    Name                   = "CriticalApp"
    CriticalInfrastructure = "true"     # Custom tag for comprehensive example
    BackupPlanA            = "active"   # Custom tag key/value
    ProdBackup            = "enabled"   # Another custom option
  }
}
```

### Argument Reference

See the [Inputs](#inputs) section for a complete list of available arguments.

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
| aws.dr | >= 4.0.0 |

## Resources

| Name | Type | Documentation |
|------|------|--------------|
| [aws_backup_plan.individual](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/backup_plan) | resource | [AWS Documentation](https://docs.aws.amazon.com/aws-backup/latest/devguide/creating-a-backup-plan.html) |
| [aws_backup_plan.combined](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/backup_plan) | resource | [AWS Documentation](https://docs.aws.amazon.com/aws-backup/latest/devguide/creating-a-backup-plan.html) |
| [aws_backup_plan.dr_individual](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/backup_plan) | resource | [AWS Documentation](https://docs.aws.amazon.com/aws-backup/latest/devguide/creating-a-backup-plan.html) |
| [aws_backup_selection.individual](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/backup_selection) | resource | [AWS Documentation](https://docs.aws.amazon.com/aws-backup/latest/devguide/assigning-resources.html) |
| [aws_backup_selection.combined](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/backup_selection) | resource | [AWS Documentation](https://docs.aws.amazon.com/aws-backup/latest/devguide/assigning-resources.html) |
| [aws_iam_role.backup_selection](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/iam_role) | resource | [AWS Documentation](https://docs.aws.amazon.com/aws-backup/latest/devguide/iam-service-roles.html) |
| [aws_iam_role_policy_attachment.backup_selection](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/iam_role_policy_attachment) | resource | [AWS Documentation](https://docs.aws.amazon.com/aws-backup/latest/devguide/iam-service-roles.html) |

<p align="right">(<a href="#readme-top">back to top</a>)</p>

<!-- INPUTS -->
## Inputs

### Core Configuration

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| name | Base name for the backup plan (prefix will be prepended) | `string` | n/a | yes |
| plan_prefix | Prefix to prepend to all resource names for identification | `string` | `""` | no |
| server_selection_tag | Tag key to look for on servers/resources | `string` | `null` | no |
| server_selection_value | Tag value to match | `string` | `"true"` | no |
| use_individual_plans | Create separate plans per schedule or one combined plan | `bool` | `false` | no |
| create_separate_dr_plans | Create DR as separate plans instead of copy actions | `bool` | `false` | no |
| create_backup_selection | Create backup selection resources | `bool` | `false` | no |
| enable_s3_backup | Enable S3 backup capabilities | `bool` | `false` | no |
| tags | Tags to apply to all resources | `map(string)` | `{}` | no |

### Schedule Enable Flags

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| enable_hourly_plan | Enable hourly backup schedule | `bool` | `false` | no |
| enable_daily_plan | Enable daily backup schedule | `bool` | `false` | no |
| enable_weekly_plan | Enable weekly backup schedule | `bool` | `false` | no |
| enable_monthly_plan | Enable monthly backup schedule | `bool` | `false` | no |
| enable_yearly_plan | Enable yearly backup schedule | `bool` | `false` | no |

### Schedule Configuration

For each schedule type (hourly, daily, weekly, monthly, yearly):

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| `<schedule>_schedule` | Custom cron expression | `string` | See defaults | no |
| `<schedule>_retention_days` | Days to retain backups | `number` | Varies | no |
| `<schedule>_vault_name` | Target vault name | `string` | `<schedule>` | no |
| `<schedule>_enable_continuous_backup` | Enable continuous backup | `bool` | `false` | no |
| `<schedule>_start_window` | Start window in minutes | `number` | `60` | no |
| `<schedule>_completion_window` | Completion window in minutes | `number` | Varies | no |
| `<schedule>_cold_storage_after` | Days before cold storage | `number` | `null` | no |

### DR Configuration

For each schedule type:

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| enable_`<schedule>`_dr_copy | Enable DR copy for schedule | `bool` | `false` | no |
| `<schedule>_dr_vault_arn` | ARN of DR vault | `string` | `null` | no |
| `<schedule>_dr_vault_name` | Name of DR vault | `string` | `null` | no |
| `<schedule>_dr_retention_days` | DR retention period | `number` | `null` | no |
| `<schedule>_dr_cold_storage_after` | Days before DR cold storage | `number` | `null` | no |

### Resource Selection

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| backup_selection_tags | Tags to select resources for backup | `list(object({type = string, key = string, value = string}))` | `[]` | no |
| backup_selection_resources | Specific resource ARNs to include | `list(string)` | `[]` | no |
| backup_selection_not_resources | Resource ARNs to exclude | `list(string)` | `[]` | no |
| backup_selection_conditions | Advanced selection conditions | `list(object)` | `[]` | no |

### Per-Schedule Selection Tags

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| `<schedule>_selection_tag_key` | Tag key for schedule selection | `string` | Smart default | no |
| `<schedule>_selection_tag_value` | Tag value for schedule selection | `string` | `"true"` | no |

## Outputs

| Name | Description |
|------|-------------|
| plan_prefix | The prefix used for all plan names |
| plan_base_name | The base name used for all plans (includes prefix) |
| individual_plan_ids | Map of plan IDs by schedule type |
| individual_plan_arns | Map of plan ARNs by schedule type |
| dr_plan_ids | Map of DR plan IDs (if using separate DR plans) |
| dr_plan_arns | Map of DR plan ARNs (if using separate DR plans) |
| backup_selection_role_arn | ARN of the IAM role for selections |
| enabled_schedules | List of enabled schedule types |
| enabled_dr_schedules | List of enabled DR schedule types |

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