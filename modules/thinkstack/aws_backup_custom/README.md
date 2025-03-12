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

Resources are included in backup plans based on tags. The module supports including resources in multiple backup plans using a hyphen-separated string approach:

```hcl
# EC2 instance included in daily and weekly backup plans
resource "aws_instance" "example" {
  # ... other configuration ...
  
  tags = {
    Name            = "example-instance"
    backup_schedule = "daily-weekly"  # Include in both daily and weekly backup plans
  }
}

# RDS instance included in only the monthly backup plan
resource "aws_db_instance" "example" {
  # ... other configuration ...
  
  tags = {
    Name            = "example-db"
    backup_schedule = "monthly"  # Include in only the monthly backup plan
  }
}

# EFS file system included in all standard backup plans
resource "aws_efs_file_system" "example" {
  # ... other configuration ...
  
  tags = {
    Name            = "example-efs"
    backup_schedule = "all"  # Include in all enabled backup plans
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

### Custom Backup Plans

For custom backup plans, you can use a different tag key:

```hcl
# EC2 instance included in custom backup plan
resource "aws_instance" "example" {
  # ... other configuration ...
  
  tags = {
    Name            = "example-instance"
    custom_backup_schedule = "custom-plan-1-custom-plan-2"  # Include in custom backup plans
  }
}
```

### Complete Example

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
    backup_schedule = "daily-weekly"  # Include in daily and weekly backup plans
  }
}

# RDS instance with standard backup tag
resource "aws_db_instance" "example" {
  # ... other configuration ...
  
  tags = {
    Name            = "example-db"
    backup_schedule = "hourly-daily"  # Include in hourly and daily backup plans
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
