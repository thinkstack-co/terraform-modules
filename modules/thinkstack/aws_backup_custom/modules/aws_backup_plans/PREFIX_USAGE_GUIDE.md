# Prefix-Based Backup Plan Usage Guide

This guide explains how to use the prefix-based naming system for AWS Backup plans.

## Overview

The module now supports a `plan_prefix` variable that allows you to create multiple instances of the module with distinct naming conventions. This enables you to manage different backup strategies (Plan A, Plan B, etc.) while maintaining clear separation and organization.

## Key Features

1. **Prefix-Based Naming**: All resources created by the module will be prefixed with your chosen prefix
2. **Automatic Tagging**: Plans are automatically tagged with `{prefix} = "true"` for easy identification
3. **Flexible Scheduling**: Support for hourly, daily, weekly, monthly, and yearly backup schedules
4. **DR Options**: Can create DR copies within the same plan or as separate DR plans
5. **Per-Plan Customization**: Each plan can have different combinations of schedules and retention policies

## Usage Examples

### Basic Plan with Prefix

```hcl
module "backup_plan_a" {
  source = "../"

  name        = "backup_plan"
  plan_prefix = "plan-a"  # This will create resources like "plan-a-backup_plan-daily"

  # Enable the schedules you need
  enable_daily_plan     = true
  daily_retention_days  = 30

  enable_weekly_plan    = true
  weekly_retention_days = 90

  enable_monthly_plan    = true
  monthly_retention_days = 365
}
```

### Plan Naming Convention

When you set `plan_prefix = "plan-a"` and `name = "backup_plan"`, the module creates:

- Backup Plans: `plan-a-backup_plan-daily`, `plan-a-backup_plan-weekly`, etc.
- IAM Role: `plan-a-backup_plan-backup-selection-role`
- Selection: `plan-a-backup_plan-daily-selection`
- Tags: All resources tagged with `plan-a = "true"`

### DR Plan Options

#### Option 1: DR Copies within Main Plans
```hcl
module "backup_with_dr_copies" {
  source = "../"

  plan_prefix = "plan-b"

  enable_daily_plan     = true
  enable_daily_dr_copy  = true
  daily_dr_retention_days = 7
}
```

#### Option 2: Separate DR Plans
```hcl
module "backup_with_separate_dr" {
  source = "../"

  plan_prefix = "plan-c"
  create_separate_dr_plans = true  # Creates dedicated DR plans

  enable_daily_plan     = true
  enable_daily_dr_copy  = true
  daily_dr_retention_days = 7

  # Optional: Custom DR schedules
  dr_schedules = {
    daily = "cron(0 10 ? * * *)"  # DR backup at 10 AM
  }
}
```

This creates:
- Main plan: `plan-c-backup_plan-daily`
- DR plan: `plan-c-backup_plan-dr-daily`

### Multiple Plans Example

```hcl
# Plan A: Production critical with full backup schedule
module "plan_a" {
  source      = "../"
  plan_prefix = "plan-a"

  enable_daily_plan    = true
  enable_weekly_plan   = true
  enable_monthly_plan  = true

  # All plans get tagged with "plan-a" = "true"
}

# Plan B: Development with limited backups
module "plan_b" {
  source      = "../"
  plan_prefix = "plan-b"

  enable_daily_plan = true
  daily_retention_days = 7

  # All plans get tagged with "plan-b" = "true"
}

# Plan C: Archive with long retention
module "plan_c" {
  source      = "../"
  plan_prefix = "plan-c"

  enable_monthly_plan = true
  monthly_retention_days = 2555  # 7 years
  monthly_cold_storage_after = 90

  # All plans get tagged with "plan-c" = "true"
}
```

## Resource Selection

Each plan can target different resources using tags:

```hcl
module "backup_plan_a" {
  source = "../"
  plan_prefix = "plan-a"

  create_backup_selection = true
  backup_selection_tags = [
    {
      type  = "STRINGEQUALS"
      key   = "BackupPlan"
      value = "A"
    }
  ]
}
```

## Best Practices

1. **Consistent Naming**: Use a clear prefix scheme (e.g., plan-a, plan-b, env-prod, team-finance)
2. **Tag Resources**: Tag your AWS resources with the appropriate backup plan identifier
3. **Document Plans**: Maintain documentation of what each plan covers and why
4. **Test DR**: Regularly test your DR plans if using separate DR configurations
5. **Monitor Costs**: Different retention policies have different cost implications

## Common Patterns

### Pattern 1: Environment-Based
```hcl
plan_prefix = "prod"    # Production backups
plan_prefix = "staging" # Staging backups
plan_prefix = "dev"     # Development backups
```

### Pattern 2: Compliance-Based
```hcl
plan_prefix = "hipaa"   # HIPAA compliant retention
plan_prefix = "pci"     # PCI compliant retention
plan_prefix = "standard" # Standard retention
```

### Pattern 3: Team-Based
```hcl
plan_prefix = "team-finance"
plan_prefix = "team-engineering"
plan_prefix = "team-marketing"
```
