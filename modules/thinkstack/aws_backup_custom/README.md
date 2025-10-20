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
    <li><a href="#module-organization">Module Organization</a></li>
    <li><a href="#usage">Usage</a></li>
    <li><a href="#complete-module-examples">Complete Module Examples</a></li>
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

### Key Features:
- **Flexible Backup Schedules**: Hourly, daily, weekly, monthly, and yearly backup plans
- **Smart Tag-Based Selection**: Automatically includes resources in backups based on tags
- **Disaster Recovery (DR)**: Cross-region backup replication with separate retention policies
- **Vault Management**: Automatic creation of backup vaults with optional locking
- **KMS Encryption**: Optional KMS key creation or bring your own key
- **Windows VSS Support**: Consistent backups for Windows instances
- **Modular Architecture**: Use as a monolithic module or separate components

<p align="right">(<a href="#readme-top">back to top</a>)</p>

## Module Organization

This module is available in two forms:

### 1. **Monolithic Module** (this module)
All-in-one solution for backward compatibility. Use this for simple deployments where you want everything managed together.

### 2. **Separated Modules** (in `modules/` subdirectory)
Modular components for maximum flexibility:

#### `aws_backup_vault`
- Creates and manages backup vaults
- Supports scheduled vaults (hourly, daily, weekly, monthly, yearly)
- DR vault creation with cross-region provider
- Vault locking for compliance
- Smart naming conventions

#### `aws_backup_plans`
- Creates backup plans with flexible scheduling
- Integrated backup selection with IAM role management
- Smart default tag keys that include DR status
- Per-schedule tag customization
- Support for individual or combined plans
- DR copy actions with separate retention

#### `aws_backup_iam_role`
- Creates IAM roles for AWS Backup
- Supports custom policies
- Service-linked role management

For new implementations, consider using the separated modules for greater flexibility. See the [Migration Guide](MIGRATION_GUIDE.md) for details.

<p align="right">(<a href="#readme-top">back to top</a>)</p>

## Provider Configuration

When using DR functionality, this module requires two AWS provider configurations:

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

<p align="right">(<a href="#readme-top">back to top</a>)</p>

## Usage

### Basic Example: Daily Backups Only

```hcl
module "aws_backup_custom" {
  source = "github.com/thinkstack-co/terraform-modules//modules/thinkstack/aws_backup_custom"

  # Enable only daily backups
  create_daily_plan    = true
  daily_retention_days = 30

  # Create KMS key for encryption
  create_kms_key = true

  tags = {
    terraform   = "true"
    environment = "production"
  }
}

# Tag resources for backup
resource "aws_instance" "app_server" {
  # ... instance configuration ...

  tags = {
    Name            = "app-server"
    backup_schedule = "daily"  # Include in daily backups
  }
}
```

### Advanced Example: Multiple Schedules with DR

```hcl
module "aws_backup_custom" {
  source = "github.com/thinkstack-co/terraform-modules//modules/thinkstack/aws_backup_custom"

  # Provider configuration for DR
  providers = {
    aws    = aws
    aws.dr = aws.dr
  }

  # Enable multiple backup schedules
  create_hourly_plan  = true
  create_daily_plan   = true
  create_weekly_plan  = true
  create_monthly_plan = true

  # Configure retention
  hourly_retention_days  = 7
  daily_retention_days   = 30
  weekly_retention_days  = 90
  monthly_retention_days = 365

  # Enable DR with selective copying
  enable_dr               = true
  dr_region               = "us-west-2"
  daily_include_in_dr     = true
  weekly_include_in_dr    = true
  daily_dr_retention_days = 14
  weekly_dr_retention_days = 30

  # KMS and security
  create_kms_key      = true
  enable_vault_lock   = true
  enable_windows_vss  = true

  tags = {
    terraform   = "true"
    environment = "production"
  }
}

# Critical server with all backups and DR
resource "aws_instance" "critical_server" {
  # ... configuration ...

  tags = {
    Name            = "critical-server"
    backup_schedule = "all"        # All backup schedules
    add_to_dr       = "true"       # Include in DR copies
  }
}

# Standard server with daily/weekly only, no DR
resource "aws_instance" "standard_server" {
  # ... configuration ...

  tags = {
    Name            = "standard-server"
    backup_schedule = "daily-weekly"  # Daily and weekly only
    # No add_to_dr tag - won't be copied to DR
  }
}
```

### Example: Excluding Individual Resources from Backups

```hcl
module "aws_backup_custom" {
  source = "github.com/thinkstack-co/terraform-modules//modules/thinkstack/aws_backup_custom"

  # Enable daily and weekly backups
  create_daily_plan   = true
  create_weekly_plan  = true
  
  # Enable backup exclusions feature
  enable_backup_exclusions  = true
  backup_exclusion_tag_key  = "backup_exclude"  # Default
  backup_exclusion_tag_value = "true"           # Default

  # Create KMS key for encryption
  create_kms_key = true

  tags = {
    terraform   = "true"
    environment = "production"
  }
}

# EC2 instance with EBS volumes - some volumes excluded
resource "aws_instance" "database_server" {
  ami           = "ami-12345678"
  instance_type = "m5.xlarge"
  
  tags = {
    Name            = "database-server"
    backup_schedule = "daily"  # Instance will be backed up
  }
}

# Root volume - will be backed up with the instance
resource "aws_ebs_volume" "root_volume" {
  availability_zone = "us-east-1a"
  size              = 100
  
  tags = {
    Name = "database-root"
    # No backup_exclude tag - will be included
  }
}

# Data volume - will be backed up with the instance
resource "aws_ebs_volume" "data_volume" {
  availability_zone = "us-east-1a"
  size              = 500
  
  tags = {
    Name = "database-data"
    # No backup_exclude tag - will be included
  }
}

# Temp volume - EXCLUDED from backups
resource "aws_ebs_volume" "temp_volume" {
  availability_zone = "us-east-1a"
  size              = 200
  
  tags = {
    Name           = "database-temp"
    backup_exclude = "true"  # This volume will be EXCLUDED
  }
}

# Attach all volumes to instance
resource "aws_volume_attachment" "root_attach" {
  device_name = "/dev/sda1"
  volume_id   = aws_ebs_volume.root_volume.id
  instance_id = aws_instance.database_server.id
}

resource "aws_volume_attachment" "data_attach" {
  device_name = "/dev/sdf"
  volume_id   = aws_ebs_volume.data_volume.id
  instance_id = aws_instance.database_server.id
}

resource "aws_volume_attachment" "temp_attach" {
  device_name = "/dev/sdg"
  volume_id   = aws_ebs_volume.temp_volume.id
  instance_id = aws_instance.database_server.id
}
```

**How Exclusions Work:**

- When `enable_backup_exclusions = true`, the module adds conditions to all backup selections
- Resources (EBS volumes, RDS instances, etc.) with `backup_exclude = "true"` are **excluded** from backups
- This works at the **individual resource level**, allowing you to exclude specific EBS volumes while backing up others
- The exclusion applies to **all backup plans** (hourly, daily, weekly, monthly, yearly)

**Important Notes:**

- AWS Backup evaluates tags on **each resource** independently when using conditions
- For EC2 instances, each attached EBS volume is evaluated separately
- Volumes without the exclusion tag will be backed up normally
- This is the **only way** to selectively exclude individual EBS volumes from EC2 instance backups

<p align="right">(<a href="#readme-top">back to top</a>)</p>

## Complete Module Examples

### 1. AWS Backup Vault Module - Complete Example

```hcl
# Complete example showing all features of the backup vault module
module "backup_vaults" {
  source = "./modules/aws_backup_vault"

  # Provider configuration for DR
  providers = {
    aws    = aws
    aws.dr = aws.dr
  }

  # Single custom vault (optional - set to false to use only scheduled vaults)
  create_single_vault = true
  name                = "custom-backup-vault"

  # KMS encryption key (required)
  kms_key_arn = aws_kms_key.backup.arn

  # Force destroy allows deletion even with recovery points
  force_destroy = false

  # Scheduled vaults - enable the ones you need
  enable_hourly_vault  = true
  enable_daily_vault   = true
  enable_weekly_vault  = true
  enable_monthly_vault = true
  enable_yearly_vault  = true

  # Vault naming prefix (results in: myapp-hourly, myapp-daily, etc.)
  vault_name_prefix = "myapp"

  # Enable vault lock for compliance
  enable_vault_lock              = true
  vault_lock_changeable_for_days = 3
  vault_lock_max_retention_days  = 36500  # 100 years
  vault_lock_min_retention_days  = 7      # For single vault

  # Per-schedule minimum retention (for vault lock)
  hourly_min_retention_days  = 1
  daily_min_retention_days   = 7
  weekly_min_retention_days  = 30
  monthly_min_retention_days = 90
  yearly_min_retention_days  = 365

  # DR Configuration
  enable_dr            = true
  dr_vault_name        = "dr-custom-vault"           # For single vault DR
  dr_vault_name_prefix = "myapp-dr"                  # For scheduled vault DR
  dr_kms_key_arn       = aws_kms_key.dr_backup.arn  # Optional separate DR key

  # Enable specific DR vaults (allows selective DR)
  enable_hourly_dr_vault  = false  # No DR for hourly
  enable_daily_dr_vault   = true   # Enable DR for daily
  enable_weekly_dr_vault  = true   # Enable DR for weekly
  enable_monthly_dr_vault = true   # Enable DR for monthly
  enable_yearly_dr_vault  = false  # No DR for yearly

  # Tags
  tags = {
    terraform    = "true"
    environment  = "production"
    cost_center  = "operations"
  }

  # DR-specific tags
  dr_tags = {
    dr_region = "us-west-2"
    purpose   = "disaster-recovery"
  }
}

# KMS keys referenced above
resource "aws_kms_key" "backup" {
  description             = "KMS key for primary backup encryption"
  deletion_window_in_days = 30
  enable_key_rotation     = true
}

resource "aws_kms_key" "dr_backup" {
  provider                = aws.dr
  description             = "KMS key for DR backup encryption"
  deletion_window_in_days = 30
  enable_key_rotation     = true
}

# Outputs you can reference
output "vault_arns" {
  value = {
    custom        = module.backup_vaults.arn
    scheduled     = module.backup_vaults.scheduled_vault_arns
    dr_custom     = module.backup_vaults.dr_single_arn
    dr_scheduled  = module.backup_vaults.dr_vault_arns
  }
}
```

### 2. AWS Backup Plans Module - Complete Example

```hcl
# Complete example showing all features of the backup plans module
module "backup_plans" {
  source = "./modules/aws_backup_plans"

  # Basic configuration
  name = "production-backup-plans"

  # Enable backup selection (creates IAM role and selection resources)
  create_backup_selection = true
  enable_s3_backup        = true  # Include S3 backup permissions

  # Plan organization
  use_individual_plans = true  # Create separate plan per schedule (false = combined plan)

  # Hourly backup configuration
  enable_hourly_plan              = true
  hourly_schedule                 = "cron(0 * ? * * *)"      # Every hour (default)
  hourly_retention_days           = 7
  hourly_vault_name               = module.backup_vaults.scheduled_vault_names["hourly"]
  hourly_start_window             = 60                       # Minutes
  hourly_completion_window        = 120                      # Minutes
  hourly_cold_storage_after       = null                    # Days (null = disabled)
  hourly_enable_continuous_backup = false

  # Hourly DR configuration
  enable_hourly_dr_copy         = true
  hourly_dr_vault_arn           = module.backup_vaults.dr_vault_arns["hourly"]
  hourly_dr_retention_days      = 3
  hourly_dr_cold_storage_after  = null

  # Hourly selection tags (uses smart defaults if not specified)
  hourly_selection_tag_key   = null  # Will use "hourly_prod_dr_backups" (because DR is enabled)
  hourly_selection_tag_value = "true"

  # Daily backup configuration
  enable_daily_plan              = true
  daily_schedule                 = "cron(0 5 ? * * *)"       # 5 AM daily (default)
  daily_retention_days           = 30
  daily_vault_name               = module.backup_vaults.scheduled_vault_names["daily"]
  daily_start_window             = 60
  daily_completion_window        = 180
  daily_cold_storage_after       = null
  daily_enable_continuous_backup = false

  # Daily DR configuration
  enable_daily_dr_copy         = true
  daily_dr_vault_arn           = module.backup_vaults.dr_vault_arns["daily"]
  daily_dr_retention_days      = 14
  daily_dr_cold_storage_after  = null

  # Daily selection tags (custom override)
  daily_selection_tag_key   = "DailyBackupRequired"
  daily_selection_tag_value = "yes"

  # Weekly backup configuration
  enable_weekly_plan              = true
  weekly_schedule                 = "cron(0 5 ? * 1 *)"      # Monday 5 AM (default)
  weekly_retention_days           = 90
  weekly_vault_name               = module.backup_vaults.scheduled_vault_names["weekly"]
  weekly_start_window             = 60
  weekly_completion_window        = 360
  weekly_cold_storage_after       = 30                      # Move to cold storage after 30 days
  weekly_enable_continuous_backup = false

  # Weekly DR configuration
  enable_weekly_dr_copy         = true
  weekly_dr_vault_arn           = module.backup_vaults.dr_vault_arns["weekly"]
  weekly_dr_retention_days      = 30
  weekly_dr_cold_storage_after  = 7

  # Monthly backup configuration
  enable_monthly_plan              = true
  monthly_schedule                 = "cron(0 5 1 * ? *)"     # 1st of month 5 AM (default)
  monthly_retention_days           = 365
  monthly_vault_name               = module.backup_vaults.scheduled_vault_names["monthly"]
  monthly_start_window             = 60
  monthly_completion_window        = 720
  monthly_cold_storage_after       = 90
  monthly_enable_continuous_backup = false

  # Monthly DR configuration
  enable_monthly_dr_copy         = false  # No DR for monthly

  # Yearly backup configuration
  enable_yearly_plan              = true
  yearly_schedule                 = "cron(0 5 1 1 ? *)"      # Jan 1st 5 AM (default)
  yearly_retention_days           = 2555                    # 7 years
  yearly_vault_name               = module.backup_vaults.scheduled_vault_names["yearly"]
  yearly_start_window             = 60
  yearly_completion_window        = 1440                    # 24 hours
  yearly_cold_storage_after       = 365                     # Move to cold storage after 1 year
  yearly_enable_continuous_backup = false

  # Yearly DR configuration
  enable_yearly_dr_copy         = true
  yearly_dr_vault_arn           = module.backup_vaults.dr_vault_arns["yearly"]
  yearly_dr_retention_days      = 1095                      # 3 years
  yearly_dr_cold_storage_after  = 90

  # Global backup selection tags (apply to all schedules)
  backup_selection_tags = [
    {
      type  = "STRINGEQUALS"
      key   = "Environment"
      value = "production"
    },
    {
      type  = "STRINGEQUALS"
      key   = "BackupEnabled"
      value = "true"
    }
  ]

  # Additional specific resources to backup
  backup_selection_resources = [
    "arn:aws:rds:us-east-1:123456789012:db:critical-database",
    "arn:aws:dynamodb:us-east-1:123456789012:table/important-table"
  ]

  # Resources to exclude from backup
  backup_selection_not_resources = [
    "arn:aws:ec2:us-east-1:123456789012:instance/i-temporary"
  ]

  # Advanced selection conditions
  backup_selection_conditions = [
    {
      string_equals = [
        {
          key   = "aws:ResourceTag/Department"
          value = "Finance"
        }
      ]
      string_not_equals = [
        {
          key   = "aws:ResourceTag/Temporary"
          value = "true"
        }
      ]
    }
  ]

  # Advanced backup settings
  advanced_backup_settings = [
    {
      resource_type = "EC2"
      backup_options = {
        WindowsVSS = "enabled"
      }
    }
  ]

  # Legacy custom rules (for backward compatibility)
  rules = []

  tags = {
    terraform    = "true"
    environment  = "production"
    module       = "backup-plans"
  }
}

# Example resources with proper tagging
resource "aws_instance" "critical_server" {
  ami           = data.aws_ami.amazon_linux.id
  instance_type = "t3.large"

  tags = {
    Name                    = "critical-server"
    Environment             = "production"
    BackupEnabled           = "true"
    hourly_prod_dr_backups  = "true"  # Smart default tag for hourly with DR
    DailyBackupRequired     = "yes"   # Custom tag for daily
    weekly_prod_dr_backups  = "true"  # Smart default tag for weekly with DR
    monthly_prod_backups    = "true"  # Smart default tag for monthly without DR
    yearly_prod_dr_backups  = "true"  # Smart default tag for yearly with DR
  }
}

resource "aws_db_instance" "finance_db" {
  identifier     = "finance-database"
  engine         = "postgres"
  instance_class = "db.t3.medium"

  tags = {
    Name          = "finance-database"
    Environment   = "production"
    BackupEnabled = "true"
    Department    = "Finance"  # Matches advanced condition
    # Will be included in all backups due to Department tag
  }
}
```

### 3. AWS Backup IAM Role Module - Complete Example

```hcl
# Complete example showing all features of the IAM role module
module "backup_iam_role" {
  source = "./modules/aws_backup_iam_role"

  # Role configuration
  role_name        = "aws-backup-service-role"
  role_path        = "/service-role/"
  role_description = "IAM role for AWS Backup service"

  # Permissions boundary (optional)
  role_permissions_boundary = "arn:aws:iam::123456789012:policy/PermissionsBoundary"

  # Maximum session duration in seconds (1-12 hours)
  role_max_session_duration = 3600  # 1 hour

  # Force detach policies on delete
  role_force_detach_policies = true

  # Custom assume role policy (optional - defaults to AWS Backup service)
  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = "sts:AssumeRole"
        Effect = "Allow"
        Principal = {
          Service = [
            "backup.amazonaws.com",
            "restore.backup.amazonaws.com"
          ]
        }
      }
    ]
  })

  # Attach AWS managed policies
  aws_managed_policies = [
    "arn:aws:iam::aws:policy/service-role/AWSBackupServiceRolePolicyForBackup",
    "arn:aws:iam::aws:policy/service-role/AWSBackupServiceRolePolicyForRestores",
    "arn:aws:iam::aws:policy/AWSBackupServiceRolePolicyForS3Backup",
    "arn:aws:iam::aws:policy/AWSBackupServiceRolePolicyForS3Restore"
  ]

  # Create and attach a custom policy
  create_custom_policy = true
  custom_policy_name   = "aws-backup-custom-policy"
  custom_policy_path   = "/service-policy/"
  custom_policy_description = "Custom policy for additional backup permissions"

  # Custom policy document
  custom_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Action = [
          "rds:DescribeDBSnapshots",
          "rds:CreateDBSnapshot",
          "rds:CopyDBSnapshot",
          "rds:DescribeDBInstances",
          "rds:CreateDBClusterSnapshot",
          "rds:DescribeDBClusters"
        ]
        Resource = "*"
      },
      {
        Effect = "Allow"
        Action = [
          "dynamodb:CreateBackup",
          "dynamodb:DescribeBackup",
          "dynamodb:ListBackups"
        ]
        Resource = "*"
      },
      {
        Effect = "Allow"
        Action = [
          "tag:GetResources",
          "tag:GetTagKeys",
          "tag:GetTagValues"
        ]
        Resource = "*"
      }
    ]
  })

  # Additional custom policies to attach (existing policy ARNs)
  custom_policies = [
    "arn:aws:iam::123456789012:policy/MyExistingBackupPolicy"
  ]

  tags = {
    terraform    = "true"
    environment  = "production"
    purpose      = "backup-service"
  }
}

# Output the role ARN for use in backup selections
output "backup_role_arn" {
  value = module.backup_iam_role.role_arn
}

# Example using the role with a backup selection (without the backup plans module)
resource "aws_backup_selection" "custom" {
  iam_role_arn = module.backup_iam_role.role_arn
  name         = "custom-backup-selection"
  plan_id      = aws_backup_plan.custom.id

  selection_tag {
    type  = "STRINGEQUALS"
    key   = "BackupPolicy"
    value = "custom"
  }
}
```

### 4. Complete Integration Example - All Modules Together

```hcl
# Complete production setup using all modules together

# 1. Create backup vaults with DR
module "backup_vaults" {
  source = "./modules/aws_backup_vault"

  providers = {
    aws    = aws
    aws.dr = aws.dr
  }

  create_single_vault = false  # Use only scheduled vaults
  kms_key_arn         = aws_kms_key.backup.arn
  vault_name_prefix   = "prod"

  # Enable all scheduled vaults
  enable_hourly_vault  = true
  enable_daily_vault   = true
  enable_weekly_vault  = true
  enable_monthly_vault = true
  enable_yearly_vault  = true

  # Enable DR for daily and weekly only
  enable_dr              = true
  enable_daily_dr_vault  = true
  enable_weekly_dr_vault = true

  # Vault lock for compliance
  enable_vault_lock = true

  tags = local.common_tags
}

# 2. Create backup plans with integrated selections
module "backup_plans" {
  source = "./modules/aws_backup_plans"

  name                    = "prod-backup-strategy"
  create_backup_selection = true
  use_individual_plans    = true

  # Hourly backups for critical systems
  enable_hourly_plan    = true
  hourly_retention_days = 7
  hourly_vault_name     = module.backup_vaults.scheduled_vault_names["hourly"]

  # Daily backups with DR
  enable_daily_plan       = true
  daily_retention_days    = 30
  daily_vault_name        = module.backup_vaults.scheduled_vault_names["daily"]
  enable_daily_dr_copy    = true
  daily_dr_vault_arn      = module.backup_vaults.dr_vault_arns["daily"]
  daily_dr_retention_days = 14

  # Weekly backups with DR
  enable_weekly_plan       = true
  weekly_retention_days    = 90
  weekly_vault_name        = module.backup_vaults.scheduled_vault_names["weekly"]
  enable_weekly_dr_copy    = true
  weekly_dr_vault_arn      = module.backup_vaults.dr_vault_arns["weekly"]
  weekly_dr_retention_days = 30
  weekly_cold_storage_after = 30

  # Monthly backups (no DR)
  enable_monthly_plan       = true
  monthly_retention_days    = 365
  monthly_vault_name        = module.backup_vaults.scheduled_vault_names["monthly"]
  monthly_cold_storage_after = 90

  # Yearly backups (no DR)
  enable_yearly_plan        = true
  yearly_retention_days     = 2555
  yearly_vault_name         = module.backup_vaults.scheduled_vault_names["yearly"]
  yearly_cold_storage_after = 365

  # Global selection tags
  backup_selection_tags = [
    {
      type  = "STRINGEQUALS"
      key   = "Environment"
      value = "production"
    }
  ]

  # Windows VSS for EC2
  advanced_backup_settings = [
    {
      resource_type = "EC2"
      backup_options = {
        WindowsVSS = "enabled"
      }
    }
  ]

  tags = local.common_tags
}

# 3. Create additional IAM role for custom backup jobs (optional)
module "custom_backup_role" {
  source = "./modules/aws_backup_iam_role"

  role_name = "custom-backup-role"

  aws_managed_policies = [
    "arn:aws:iam::aws:policy/service-role/AWSBackupServiceRolePolicyForBackup"
  ]

  create_custom_policy = true
  custom_policy_name   = "custom-backup-permissions"
  custom_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Action = [
          "ec2:CreateSnapshot",
          "ec2:DescribeSnapshots",
          "ec2:DescribeVolumes"
        ]
        Resource = "*"
        Condition = {
          StringEquals = {
            "aws:RequestedRegion" = data.aws_region.current.name
          }
        }
      }
    ]
  })

  tags = local.common_tags
}

# Supporting resources
resource "aws_kms_key" "backup" {
  description             = "KMS key for backup encryption"
  deletion_window_in_days = 30
  enable_key_rotation     = true

  tags = merge(local.common_tags, {
    Name = "backup-encryption-key"
  })
}

locals {
  common_tags = {
    terraform    = "true"
    environment  = "production"
    cost_center  = "operations"
    project      = "backup-infrastructure"
  }
}

# Example resources with smart default tags
resource "aws_instance" "web_servers" {
  count         = 3
  ami           = data.aws_ami.amazon_linux.id
  instance_type = "t3.medium"

  tags = {
    Name                   = "web-server-${count.index + 1}"
    Environment            = "production"
    hourly_prod_backups    = "true"  # Hourly without DR
    daily_prod_dr_backups  = "true"  # Daily with DR
    weekly_prod_dr_backups = "true"  # Weekly with DR
  }
}

resource "aws_db_instance" "app_database" {
  identifier             = "app-database"
  engine                 = "postgres"
  engine_version         = "14.7"
  instance_class         = "db.t3.large"
  allocated_storage      = 100
  storage_encrypted      = true
  skip_final_snapshot    = false

  tags = {
    Name                  = "app-database"
    Environment           = "production"
    daily_prod_dr_backups = "true"  # Daily with DR
    monthly_prod_backups  = "true"  # Monthly without DR
    yearly_prod_backups   = "true"  # Yearly without DR
  }
}

# Outputs for reference
output "backup_infrastructure" {
  value = {
    vaults = {
      primary = module.backup_vaults.scheduled_vault_arns
      dr      = module.backup_vaults.dr_vault_arns
    }
    plans = {
      ids              = module.backup_plans.all_plan_ids
      enabled_schedules = module.backup_plans.enabled_schedules
    }
    selections = {
      role_arn = module.backup_plans.backup_selection_role_arn
      ids      = module.backup_plans.all_backup_selection_ids
    }
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
| aws.dr | >= 4.0.0 (when using DR features) |

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
