# Migration Guide: From aws_backup_custom to Separated Modules

This guide helps you migrate from the monolithic `aws_backup_custom` module to the new separated modules.

## Why Migrate?

The separated modules provide:
- **Greater flexibility** in backup configurations
- **Reusability** of components across different setups
- **Easier customization** of backup strategies
- **Better separation of concerns**

## Module Mapping

| Old Module Component | New Module |
|---------------------|------------|
| KMS Key | Use native `aws_kms_key` resource |
| IAM Role | `aws_backup_iam_role` |
| Backup Vaults | `aws_backup_vault` |
| Backup Plans | `aws_backup_plans` |
| Backup Selections | `aws_backup_selection` |

## Migration Steps

### Step 1: Replace IAM Role

**Old:**
```hcl
module "aws_backup_custom" {
  source = "./modules/thinkstack/aws_backup_custom"
  
  backup_role_name = "my-backup-role"
  # ... other config ...
}
```

**New:**
```hcl
module "backup_iam_role" {
  source = "./modules/thinkstack/aws_backup_iam_role"
  
  role_name                  = "my-backup-role"
  enable_tag_based_selection = true
  tags                       = var.tags
}
```

### Step 2: Create Vaults Separately

**Old:**
```hcl
module "aws_backup_custom" {
  # Vaults were created automatically based on enabled plans
  create_daily_plan = true
  create_weekly_plan = true
  # ... other config ...
}
```

**New:**
```hcl
module "daily_vault" {
  source = "./modules/thinkstack/aws_backup_vault"
  
  name                          = "daily"
  kms_key_arn                   = aws_kms_key.backup.arn
  enable_vault_lock             = var.enable_vault_lock
  vault_lock_min_retention_days = 7
  tags                          = var.tags
}

module "weekly_vault" {
  source = "./modules/thinkstack/aws_backup_vault"
  
  name                          = "weekly"
  kms_key_arn                   = aws_kms_key.backup.arn
  enable_vault_lock             = var.enable_vault_lock
  vault_lock_min_retention_days = 30
  tags                          = var.tags
}
```

### Step 3: Create Backup Plans

**Old:**
```hcl
module "aws_backup_custom" {
  create_daily_plan    = true
  daily_schedule       = "cron(0 1 * * ? *)"
  daily_retention_days = 7
  # ... other config ...
}
```

**New:**
```hcl
module "daily_backup_plan" {
  source = "./modules/thinkstack/aws_backup_plans"
  
  name = "daily-backup-plan"
  
  rules = [
    {
      rule_name         = "daily-backup-rule"
      target_vault_name = module.daily_vault.name
      schedule          = "cron(0 1 * * ? *)"
      start_window      = 60
      completion_window = 1440
      
      lifecycle = {
        delete_after = 7
      }
    }
  ]
  
  tags = var.tags
}
```

### Step 4: Create Backup Selections

**Old:**
```hcl
module "aws_backup_custom" {
  standard_backup_tag_key = "backup_schedule"
  # Selections were created automatically
}
```

**New:**
```hcl
module "daily_backup_selection" {
  source = "./modules/thinkstack/aws_backup_selection"
  
  name         = "daily-selection"
  iam_role_arn = module.backup_iam_role.role_arn
  plan_id      = module.daily_backup_plan.id
  
  selection_tags = [
    {
      type  = "STRINGEQUALS"
      key   = "backup_schedule"
      value = "daily"
    }
  ]
}
```

## Advanced Migration Scenarios

### Migrating DR Configuration

**Old:**
```hcl
module "aws_backup_custom" {
  enable_dr            = true
  dr_region            = "us-west-2"
  daily_include_in_dr  = true
  # ... other config ...
}
```

**New:**
```hcl
module "backup_plan_with_dr" {
  source = "./modules/thinkstack/aws_backup_plans"
  
  name = "daily-with-dr"
  
  rules = [
    {
      rule_name         = "daily-backup-rule"
      target_vault_name = module.daily_vault.name
      schedule          = "cron(0 1 * * ? *)"
      
      lifecycle = {
        delete_after = 7
      }
      
      copy_actions = [
        {
          destination_vault_arn = "arn:aws:backup:us-west-2:${data.aws_caller_identity.current.account_id}:backup-vault:dr-vault"
          lifecycle = {
            delete_after = 7
          }
        }
      ]
    }
  ]
}
```

### Migrating Windows VSS Support

**Old:**
```hcl
module "aws_backup_custom" {
  enable_windows_vss = true
  daily_windows_vss  = true
  # ... other config ...
}
```

**New:**
```hcl
module "backup_plan_with_vss" {
  source = "./modules/thinkstack/aws_backup_plans"
  
  name = "daily-with-vss"
  
  rules = [
    # ... rule config ...
  ]
  
  advanced_backup_settings = [
    {
      backup_options = {
        WindowsVSS = "enabled"
      }
      resource_type = "EC2"
    }
  ]
}
```

## Benefits After Migration

1. **Mix and Match**: Use different vaults for different plans
2. **Share Components**: One IAM role can be used by multiple plans
3. **Custom Schedules**: Create any schedule pattern, not limited to predefined ones
4. **Complex Selections**: Build sophisticated selection criteria
5. **Better Testing**: Test individual components separately

## Need Help?

For complex migrations or questions, please refer to the example in `examples/aws_backup_separated/` directory.