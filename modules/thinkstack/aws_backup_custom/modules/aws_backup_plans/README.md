# AWS Backup Plans Module

This module creates AWS Backup plans with support for multiple schedules (hourly, daily, weekly, monthly, yearly), disaster recovery (DR) replication, and tag-based resource selection. The module features a powerful **prefix-based naming system** that allows you to create unlimited variations of backup plans with clear identification and organization.

## Key Features

### 1. Simple Server Selection
The module now includes `server_selection_tag` and `server_selection_value` variables for easy server tagging:

```hcl
# Plan A - Backs up servers tagged with "Plan_A = true"
module "backup_plan_a" {
  source = "../"
  
  name                   = "backup"
  plan_prefix            = "plan-a"
  create_backup_selection = true
  
  # Simple server selection
  server_selection_tag   = "Plan_A"
  server_selection_value = "true"
  
  # ... backup schedules ...
}

# Tag your servers
resource "aws_instance" "server" {
  tags = {
    Plan_A = "true"  # This server will be backed up by Plan A
  }
}
```

### 2. Flexible Prefix System
The `plan_prefix` variable allows you to create any number of distinct backup plan sets. This prefix gets prepended to all resources created by the module, enabling you to:

- Create multiple instances of the module with different configurations
- Automatically tag backup plan resources with the prefix name
- Organize plans by ANY categorization that makes sense for your organization

### Quick Examples

```hcl
# By Plan Type
plan_prefix = "plan-a"      # Creates: plan-a-backup_plan-daily, plan-a-backup_plan-weekly
plan_prefix = "plan-b"      # Creates: plan-b-backup_plan-daily, plan-b-backup_plan-weekly

# By Environment
plan_prefix = "prod"        # Creates: prod-backup_plan-daily, prod-backup_plan-weekly
plan_prefix = "staging"     # Creates: staging-backup_plan-daily, staging-backup_plan-weekly

# By Team
plan_prefix = "finance"     # Creates: finance-backup_plan-daily, finance-backup_plan-weekly
plan_prefix = "engineering" # Creates: engineering-backup_plan-daily, engineering-backup_plan-weekly

# By Compliance
plan_prefix = "hipaa"       # Creates: hipaa-backup_plan-daily, hipaa-backup_plan-weekly
plan_prefix = "pci"         # Creates: pci-backup_plan-daily, pci-backup_plan-weekly

# By Application
plan_prefix = "webapp"      # Creates: webapp-backup_plan-daily, webapp-backup_plan-weekly
plan_prefix = "database"    # Creates: database-backup_plan-daily, database-backup_plan-weekly

# Any combination
plan_prefix = "prod-critical"    # Creates: prod-critical-backup_plan-daily
plan_prefix = "dev-standard"     # Creates: dev-standard-backup_plan-daily
plan_prefix = "finance-hipaa"    # Creates: finance-hipaa-backup_plan-daily
```

## Complete Variable Reference

### Core Variables

| Variable | Type | Description | Default |
|----------|------|-------------|---------|
| `name` | string | Base name for the backup plan (prefix will be prepended) | Required |
| `plan_prefix` | string | Prefix to prepend to all resource names for identification | `""` |
| `server_selection_tag` | string | Tag key to look for on servers/resources (e.g., 'Plan_A', 'BackupPlan') | `null` |
| `server_selection_value` | string | Tag value to match (e.g., 'true', 'Yes', 'enabled') | `"true"` |
| `use_individual_plans` | bool | Create separate plans per schedule or one combined plan | `false` |
| `create_separate_dr_plans` | bool | Create DR as separate plans instead of copy actions | `false` |
| `create_backup_selection` | bool | Create backup selection resources | `false` |
| `enable_s3_backup` | bool | Enable S3 backup capabilities | `false` |
| `tags` | map(string) | Tags to apply to all resources | `{}` |

### Schedule Configuration (for each of: hourly, daily, weekly, monthly, yearly)

Replace `<schedule>` with one of: `hourly`, `daily`, `weekly`, `monthly`, `yearly`

| Variable | Type | Description | Default |
|----------|------|-------------|---------|
| `enable_<schedule>_plan` | bool | Enable this schedule type | `false` |
| `<schedule>_schedule` | string | Custom cron expression | See defaults below |
| `<schedule>_retention_days` | number | Days to retain backups | Varies by schedule |
| `<schedule>_vault_name` | string | Target vault name | `<schedule>` |
| `<schedule>_enable_continuous_backup` | bool | Enable continuous backup | `false` |
| `<schedule>_start_window` | number | Start window in minutes | `60` |
| `<schedule>_completion_window` | number | Completion window in minutes | Varies |
| `<schedule>_cold_storage_after` | number | Days before cold storage | `null` |

### DR Configuration (for each schedule)

| Variable | Type | Description | Default |
|----------|------|-------------|---------|
| `enable_<schedule>_dr_copy` | bool | Enable DR copy for schedule | `false` |
| `<schedule>_dr_vault_arn` | string | ARN of DR vault | `null` |
| `<schedule>_dr_vault_name` | string | Name of DR vault (alternative to ARN) | `null` |
| `<schedule>_dr_retention_days` | number | DR retention period | `null` |
| `<schedule>_dr_cold_storage_after` | number | Days before DR cold storage | `null` |

### Resource Selection Variables

| Variable | Type | Description | Default |
|----------|------|-------------|---------|
| `backup_selection_tags` | list(object) | Tags to select resources for backup | `[]` |
| `backup_selection_resources` | list(string) | Specific resource ARNs to include | `[]` |
| `backup_selection_not_resources` | list(string) | Resource ARNs to exclude | `[]` |
| `backup_selection_conditions` | list(object) | Advanced selection conditions | `[]` |

### Per-Schedule Selection Tags

| Variable | Type | Description | Default |
|----------|------|-------------|---------|
| `<schedule>_selection_tag_key` | string | Tag key for schedule selection | Smart default |
| `<schedule>_selection_tag_value` | string | Tag value for schedule selection | `"true"` |

### Additional Variables

| Variable | Type | Description | Default |
|----------|------|-------------|---------|
| `dr_schedules` | object | Custom DR backup schedules | `{}` |
| `rules` | list(object) | Legacy custom rules (backward compatibility) | `[]` |
| `advanced_backup_settings` | list(object) | Advanced backup settings | `[]` |

## Complete Usage Example

This example shows ALL possible configurations:

```hcl
module "comprehensive_backup_plan" {
  source = "../"
  
  # Core configuration
  name        = "backup_plan"
  plan_prefix = "prod-critical"  # All resources will start with "prod-critical-"
  
  # Plan organization
  use_individual_plans     = true   # Create separate plans per schedule
  create_separate_dr_plans = false  # Use copy actions for DR (not separate plans)
  
  # Enable backup selection
  create_backup_selection = true
  enable_s3_backup       = true  # Include S3 backup permissions
  
  # Simple server selection - servers need "prod-critical = true" tag
  server_selection_tag   = "prod-critical"
  server_selection_value = "true"
  
  # === HOURLY BACKUPS ===
  enable_hourly_plan              = true
  hourly_schedule                 = "cron(0 * ? * * *)"  # Every hour
  hourly_retention_days           = 7
  hourly_vault_name               = "prod-critical-hourly-vault"
  hourly_enable_continuous_backup = false
  hourly_start_window             = 60
  hourly_completion_window        = 120
  hourly_cold_storage_after       = null  # No cold storage for hourly
  
  # Hourly DR configuration
  enable_hourly_dr_copy        = true
  hourly_dr_vault_name         = "dr-prod-critical-hourly"
  hourly_dr_retention_days     = 3
  hourly_dr_cold_storage_after = null
  
  # Hourly selection tags
  hourly_selection_tag_key   = "HourlyBackup"
  hourly_selection_tag_value = "enabled"
  
  # === DAILY BACKUPS ===
  enable_daily_plan              = true
  daily_schedule                 = "cron(0 5 ? * * *)"  # 5 AM daily
  daily_retention_days           = 30
  daily_vault_name               = "prod-critical-daily-vault"
  daily_enable_continuous_backup = true  # Enable continuous backup
  daily_start_window             = 60
  daily_completion_window        = 180
  daily_cold_storage_after       = null
  
  # Daily DR configuration
  enable_daily_dr_copy        = true
  daily_dr_vault_arn          = "arn:aws:backup:us-west-2:123456789012:backup-vault:dr-daily"
  daily_dr_retention_days     = 14
  daily_dr_cold_storage_after = null
  
  # Daily selection tags (using defaults)
  # Will automatically use "daily_prod_dr_backups" as tag key
  
  # === WEEKLY BACKUPS ===
  enable_weekly_plan              = true
  weekly_schedule                 = "cron(0 5 ? * 1 *)"  # Monday 5 AM
  weekly_retention_days           = 90
  weekly_vault_name               = "prod-critical-weekly-vault"
  weekly_enable_continuous_backup = false
  weekly_start_window             = 60
  weekly_completion_window        = 360
  weekly_cold_storage_after       = 30  # Move to cold storage after 30 days
  
  # Weekly DR configuration
  enable_weekly_dr_copy        = true
  weekly_dr_vault_name         = "dr-prod-critical-weekly"
  weekly_dr_retention_days     = 45
  weekly_dr_cold_storage_after = 14
  
  # === MONTHLY BACKUPS ===
  enable_monthly_plan              = true
  monthly_schedule                 = "cron(0 5 1 * ? *)"  # 1st of month at 5 AM
  monthly_retention_days           = 365
  monthly_vault_name               = "prod-critical-monthly-vault"
  monthly_enable_continuous_backup = false
  monthly_start_window             = 60
  monthly_completion_window        = 720
  monthly_cold_storage_after       = 90  # Cold storage after 3 months
  
  # Monthly DR configuration
  enable_monthly_dr_copy        = true
  monthly_dr_vault_name         = "dr-prod-critical-monthly"
  monthly_dr_retention_days     = 180
  monthly_dr_cold_storage_after = 30
  
  # === YEARLY BACKUPS ===
  enable_yearly_plan              = true
  yearly_schedule                 = "cron(0 5 1 1 ? *)"  # Jan 1st at 5 AM
  yearly_retention_days           = 2555  # 7 years
  yearly_vault_name               = "prod-critical-yearly-vault"
  yearly_enable_continuous_backup = false
  yearly_start_window             = 60
  yearly_completion_window        = 1440
  yearly_cold_storage_after       = 365  # Cold storage after 1 year
  
  # Yearly DR configuration
  enable_yearly_dr_copy        = true
  yearly_dr_vault_name         = "dr-prod-critical-yearly"
  yearly_dr_retention_days     = 1825  # 5 years
  yearly_dr_cold_storage_after = 180   # 6 months
  
  # === RESOURCE SELECTION ===
  
  # Global selection tags (apply to all schedules)
  backup_selection_tags = [
    {
      type  = "STRINGEQUALS"
      key   = "Environment"
      value = "Production"
    },
    {
      type  = "STRINGEQUALS"
      key   = "Critical"
      value = "true"
    }
  ]
  
  # Specific resources to include
  backup_selection_resources = [
    "arn:aws:rds:us-east-1:123456789012:db:prod-primary-db",
    "arn:aws:dynamodb:us-east-1:123456789012:table/prod-users",
    "arn:aws:s3:::prod-critical-data/*"
  ]
  
  # Resources to exclude
  backup_selection_not_resources = [
    "arn:aws:ec2:us-east-1:123456789012:instance/i-temporary",
    "arn:aws:rds:us-east-1:123456789012:db:test-*"
  ]
  
  # Advanced conditions
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
          key   = "aws:ResourceTag/ExcludeFromBackup"
          value = "true"
        }
      ]
    }
  ]
  
  # === TAGS ===
  tags = {
    Team        = "Infrastructure"
    Environment = "Production"
    CostCenter  = "IT-OPS"
    Compliance  = "Required"
    ManagedBy   = "Terraform"
  }
  
  # === PROVIDERS ===
  providers = {
    aws    = aws
    aws.dr = aws.us_west_2  # DR region
  }
}

# If using separate DR plans
module "backup_with_separate_dr_plans" {
  source = "../"
  
  name                     = "backup_plan"
  plan_prefix              = "app-xyz"
  create_separate_dr_plans = true  # This creates dedicated DR plans
  
  # DR schedules (optional - defaults to same as primary)
  dr_schedules = {
    hourly  = "cron(30 * ? * * *)"   # 30 minutes after primary
    daily   = "cron(0 10 ? * * *)"   # 10 AM for DR
    weekly  = "cron(0 10 ? * 1 *)"   # Monday 10 AM for DR
    monthly = "cron(0 10 5 * ? *)"   # 5th at 10 AM for DR
    yearly  = "cron(0 10 1 1 ? *)"   # Jan 1st at 10 AM for DR
  }
  
  # ... rest of configuration ...
}
```

## How Resources Are Named

With `plan_prefix = "prod-critical"` and `name = "backup_plan"`:

### Backup Plans
- Individual plans: `prod-critical-backup_plan-hourly`, `prod-critical-backup_plan-daily`, etc.
- Combined plan: `prod-critical-backup_plan`
- DR plans (if separate): `prod-critical-backup_plan-dr-hourly`, `prod-critical-backup_plan-dr-daily`

### IAM Role
- `prod-critical-backup_plan-backup-selection-role`

### Backup Selections
- Individual: `prod-critical-backup_plan-hourly-selection`, `prod-critical-backup_plan-daily-selection`
- Combined: `prod-critical-backup_plan-selection`

### Automatic Tags
All resources get tagged with:
- `"prod-critical" = "true"`
- Plus any tags you specify in the `tags` variable

## Server Selection Tag Examples

### Different Tag Formats You Can Use

```hcl
# Example 1: Plan_A = true
module "plan_a" {
  server_selection_tag   = "Plan_A"
  server_selection_value = "true"
}

# Example 2: BackupPlanB = Yes  
module "plan_b" {
  server_selection_tag   = "BackupPlanB"
  server_selection_value = "Yes"
}

# Example 3: PlanC = enabled
module "plan_c" {
  server_selection_tag   = "PlanC"
  server_selection_value = "enabled"
}

# Example 4: ProductionBackup = TRUE
module "prod" {
  server_selection_tag   = "ProductionBackup"
  server_selection_value = "TRUE"
}

# Example 5: backup-group-5 = active
module "group5" {
  server_selection_tag   = "backup-group-5"
  server_selection_value = "active"
}
```

### Tagging Your Servers

```hcl
# Servers need matching tags
resource "aws_instance" "example" {
  tags = {
    Name   = "WebServer"
    Plan_A = "true"  # Will be backed up by plan_a module above
  }
}

# Multiple backup plans
resource "aws_instance" "important" {
  tags = {
    Name             = "ImportantServer"
    Plan_A           = "true"      # Backed up by Plan A
    ProductionBackup = "TRUE"      # Also backed up by Production plan
  }
}
```

## Real-World Examples

### Example 1: Multiple Plans for Different Departments

```hcl
# Finance Department - Strict compliance requirements
module "finance_backups" {
  source      = "../"
  name        = "backups"
  plan_prefix = "finance-dept"
  
  enable_daily_plan     = true
  daily_retention_days  = 90    # 3 months for audit
  
  enable_monthly_plan    = true
  monthly_retention_days = 2555  # 7 years for compliance
  
  enable_daily_dr_copy = true
  enable_monthly_dr_copy = true
}

# Engineering Department - Flexible backup needs
module "engineering_backups" {
  source      = "../"
  name        = "backups"
  plan_prefix = "eng-dept"
  
  enable_hourly_plan    = true
  hourly_retention_days = 3     # Short retention for dev
  
  enable_daily_plan     = true
  daily_retention_days  = 14    # 2 weeks
}

# Marketing Department - Standard backups
module "marketing_backups" {
  source      = "../"
  name        = "backups"
  plan_prefix = "mkt-dept"
  
  enable_daily_plan     = true
  daily_retention_days  = 30
  
  enable_weekly_plan    = true
  weekly_retention_days = 90
}
```

### Example 2: Environment-Based Plans

```hcl
# Production - Maximum protection
module "prod_backups" {
  source      = "../"
  name        = "env-backups"
  plan_prefix = "prod"
  
  enable_hourly_plan  = true
  enable_daily_plan   = true
  enable_weekly_plan  = true
  enable_monthly_plan = true
  
  # Enable DR for all
  enable_hourly_dr_copy  = true
  enable_daily_dr_copy   = true
  enable_weekly_dr_copy  = true
  enable_monthly_dr_copy = true
}

# Staging - Moderate protection
module "staging_backups" {
  source      = "../"
  name        = "env-backups"
  plan_prefix = "staging"
  
  enable_daily_plan  = true
  enable_weekly_plan = true
  
  # No DR for staging
}

# Development - Minimal protection
module "dev_backups" {
  source      = "../"
  name        = "env-backups"
  plan_prefix = "dev"
  
  enable_daily_plan    = true
  daily_retention_days = 7  # Only 1 week
}
```

## Default Schedule Times

- **Hourly**: Every hour on the hour (`cron(0 * ? * * *)`)
- **Daily**: 5:00 AM daily (`cron(0 5 ? * * *)`)
- **Weekly**: 5:00 AM every Monday (`cron(0 5 ? * 1 *)`)
- **Monthly**: 5:00 AM on the 1st (`cron(0 5 1 * ? *)`)
- **Yearly**: 5:00 AM on January 1st (`cron(0 5 1 1 ? *)`)

## Default Retention Periods

- **Hourly**: 7 days
- **Daily**: 30 days
- **Weekly**: 90 days
- **Monthly**: 365 days
- **Yearly**: 2555 days (7 years)

## Requirements

| Name | Version |
|------|---------|
| terraform | >= 1.0.0 |
| aws | >= 4.0.0 |

## Outputs

| Name | Description |
|------|-------------|
| `plan_prefix` | The prefix used for all plan names |
| `plan_base_name` | The base name used for all plans (includes prefix) |
| `individual_plan_ids` | Map of plan IDs by schedule type |
| `individual_plan_arns` | Map of plan ARNs by schedule type |
| `dr_plan_ids` | Map of DR plan IDs (if using separate DR plans) |
| `dr_plan_arns` | Map of DR plan ARNs (if using separate DR plans) |
| `backup_selection_role_arn` | ARN of the IAM role for selections |
| `enabled_schedules` | List of enabled schedule types |
| `enabled_dr_schedules` | List of enabled DR schedule types |