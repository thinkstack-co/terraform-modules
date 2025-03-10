# AWS Backup Custom Module

This module creates AWS Backup plans, vaults, and selections based on a flexible, opt-in architecture.

## Features

- Supports standard backup plans (hourly, daily, weekly, monthly, yearly)
- Allows custom backup plans with configurable schedules and retention periods
- Tag-based resource selection for both standard and custom backup plans
- Optional KMS key creation for encrypted backups
- Vault lock capabilities for enhanced security
- Windows VSS support for consistent backups of Windows instances

## Usage

### Basic Example

```hcl
module "aws_custom_backup" {
  source = "github.com/thinkstack-co/terraform-modules//modules/thinkstack/aws_backup_custom"

  enable_vault_lock = true
  
  # Enable standard backup plans
  create_daily_plan   = true
  create_weekly_plan  = true
  create_monthly_plan = true
  create_yearly_plan  = true
  
  # Optional: Configure retention periods
  daily_retention_days   = 7
  weekly_retention_days  = 30
  monthly_retention_days = 90
  yearly_retention_days  = 365
}
```

### Resource Tagging for Backup Selection

Resources are included in backup plans based on tags. The module supports including resources in multiple backup plans using a comma-separated string approach:

```hcl
# EC2 instance included in daily and weekly backup plans
resource "aws_instance" "example" {
  # ... other configuration ...
  
  tags = {
    Name            = "example-instance"
    backup_schedule = "daily,weekly"  # Include in both daily and weekly backup plans
  }
}

# EC2 instance included in all standard backup plans
resource "aws_instance" "critical_system" {
  # ... other configuration ...
  
  tags = {
    Name            = "critical-system"
    backup_schedule = "hourly,daily,weekly,monthly,yearly"
  }
}
```

The module uses the `STRINGCONTAINS` selection type to match resources with comma-separated backup schedule values. This allows you to include resources in multiple backup plans while maintaining compatibility with the `map(string)` tag type used by most AWS resources.

## Complete Example

```hcl
module "aws_custom_backup" {
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
  hourly_schedule               = "cron(0 * * * ? *)"  # Every hour at minute 0
  hourly_retention_days         = 1                    # Keep hourly backups for 1 day
  hourly_enable_continuous_backup = true               # Enable point-in-time recovery
  
  # Configure daily backup settings
  daily_schedule                = "cron(0 1 * * ? *)"  # Daily at 1:00 AM UTC
  daily_retention_days          = 7                    # Keep daily backups for 7 days
  daily_enable_continuous_backup = true                # Enable point-in-time recovery
  
  # Configure weekly backup settings
  weekly_schedule               = "cron(0 2 ? * 1 *)"  # Weekly on Sundays at 2:00 AM UTC
  weekly_retention_days         = 30                   # Keep weekly backups for 30 days
  
  # Configure monthly backup settings
  monthly_schedule              = "cron(0 3 1 * ? *)"  # 1st of each month at 3:00 AM UTC
  monthly_retention_days        = 90                   # Keep monthly backups for 90 days
  
  # Configure yearly backup settings
  yearly_schedule               = "cron(0 4 1 1 ? *)"  # January 1st at 4:00 AM UTC
  yearly_retention_days         = 365                  # Keep yearly backups for 365 days
  
  # Optional: Customize the tag key (defaults to "backup_schedule")
  standard_backup_tag_key       = "backup_schedule"
}
```

## Example Resources with Appropriate Tags

```hcl
# EC2 instance with standard backup tag
resource "aws_instance" "example" {
  # ... other configuration ...
  
  tags = {
    Name            = "example-instance"
    terraform       = "true"
    created_by      = "Terraform"
    environment     = "prod"
    project         = "server_infrastructure"
    service         = "ops"
    backup          = "true"
    backup_schedule = "daily,weekly,monthly"  # Include in daily, weekly, and monthly backup plans
  }
}

# RDS instance with standard backup tag
resource "aws_db_instance" "example" {
  # ... other configuration ...
  
  tags = {
    Name            = "example-db"
    backup_schedule = "hourly,daily"  # Include in hourly and daily backup plans
  }
}
```

## Variables

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| create_kms_key | Whether to create a new KMS key for backups | `bool` | `false` | no |
| create_hourly_plan | Whether to create an hourly backup plan | `bool` | `false` | no |
| create_daily_plan | Whether to create a daily backup plan | `bool` | `false` | no |
| create_weekly_plan | Whether to create a weekly backup plan | `bool` | `false` | no |
| create_monthly_plan | Whether to create a monthly backup plan | `bool` | `false` | no |
| create_yearly_plan | Whether to create a yearly backup plan | `bool` | `false` | no |
| enable_vault_lock | Whether to enable vault lock for all backup vaults | `bool` | `false` | no |
| standard_backup_tag_key | The tag key to use for standard backup plans | `string` | `"backup_schedule"` | no |
| hourly_retention_days | Number of days to retain hourly backups | `number` | `1` | no |
| daily_retention_days | Number of days to retain daily backups | `number` | `7` | no |
| weekly_retention_days | Number of days to retain weekly backups | `number` | `30` | no |
| monthly_retention_days | Number of days to retain monthly backups | `number` | `90` | no |
| yearly_retention_days | Number of days to retain yearly backups | `number` | `365` | no |

## Outputs

| Name | Description |
|------|-------------|
| backup_vaults | Map of backup vaults created by the module |
| backup_plans | Map of backup plans created by the module |
| kms_key_arn | ARN of the KMS key used for backup encryption (if created) |
| iam_role_arn | ARN of the IAM role used for AWS Backup |
