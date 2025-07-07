# AWS Backup Vault Module

This module creates and manages AWS Backup vaults with support for scheduled vaults, disaster recovery (DR), and vault lock configurations.

## Features

- **Flexible Vault Creation**: Create a single custom vault or multiple scheduled vaults (hourly, daily, weekly, monthly, yearly)
- **Granular DR Control**: Enable DR globally, then choose which specific vaults should have DR copies
- **Cross-Region Support**: Automatic DR vault creation in a separate region with provider aliasing
- **Vault Lock**: Optional vault lock with configurable retention periods
- **Smart Naming**: Automatic vault naming with customizable prefixes

## Usage Patterns

### 1. Single Custom Vault (Simple)
For basic use cases where you need just one vault:

```hcl
module "backup_vault" {
  source = "github.com/thinkstack-co/terraform-modules//modules/thinkstack/aws_backup_custom/modules/aws_backup_vault?ref=v2.6.6"

  name        = "my-backup-vault"
  kms_key_arn = aws_kms_key.backup.arn
  
  enable_vault_lock             = true
  vault_lock_min_retention_days = 7
  
  tags = {
    Environment = "production"
  }
}
```

### 2. Scheduled Vaults (Recommended)
Create multiple vaults based on backup schedules:

```hcl
module "backup_vaults" {
  source = "github.com/thinkstack-co/terraform-modules//modules/thinkstack/aws_backup_custom/modules/aws_backup_vault?ref=v2.6.6"

  create_single_vault = false  # Disable single vault mode
  vault_name_prefix   = "prod"  # Results in: prod-daily, prod-weekly, etc.
  
  # Choose which scheduled vaults to create
  enable_hourly_vault  = false  # No hourly vault
  enable_daily_vault   = true   # Creates prod-daily
  enable_weekly_vault  = true   # Creates prod-weekly
  enable_monthly_vault = true   # Creates prod-monthly
  enable_yearly_vault  = false  # No yearly vault
  
  kms_key_arn       = aws_kms_key.backup.arn
  enable_vault_lock = true
  
  tags = {
    Environment = "production"
  }
}
```

### 3. With Selective DR (Advanced)
Enable DR functionality with granular control over which vaults get DR copies:

```hcl
# Define providers
provider "aws" {
  region = "us-east-1"
}

provider "aws" {
  alias  = "dr"
  region = "us-west-2"
}

module "backup_vaults_with_dr" {
  source = "github.com/thinkstack-co/terraform-modules//modules/thinkstack/aws_backup_custom/modules/aws_backup_vault?ref=v2.6.6"
  
  providers = {
    aws    = aws
    aws.dr = aws.dr
  }

  create_single_vault = false
  vault_name_prefix   = "prod"
  
  # Primary vault configuration
  enable_hourly_vault  = true
  enable_daily_vault   = true
  enable_weekly_vault  = true
  enable_monthly_vault = true
  enable_yearly_vault  = true
  
  # DR configuration - Master switch
  enable_dr            = true
  dr_vault_name_prefix = "prod-dr"
  dr_kms_key_arn       = aws_kms_key.dr_backup.arn
  
  # Granular DR control - Choose which vaults get DR copies
  enable_hourly_dr_vault  = false  # No DR for hourly (too frequent)
  enable_daily_dr_vault   = true   # DR for daily
  enable_weekly_dr_vault  = true   # DR for weekly  
  enable_monthly_dr_vault = true   # DR for monthly
  enable_yearly_dr_vault  = false  # No DR for yearly (too large)
  
  kms_key_arn = aws_kms_key.backup.arn
  
  tags = {
    Environment = "production"
  }
}
```

## How DR Works

The module uses a two-level control system for DR vaults:

1. **Global DR Enable**: Set `enable_dr = true` to activate DR functionality
2. **Per-Vault Control**: Use individual flags to control which vaults get DR copies

### DR Vault Validation

The module includes built-in validation to prevent creating DR vaults without corresponding primary vaults. This prevents orphaned DR vaults and ensures your configuration is logical.

Example scenarios:

| Primary Vault | DR Master | Individual DR Flag | Result |
|---------------|-----------|-------------------|---------|
| `enable_daily_vault = true` | `enable_dr = true` | `enable_daily_dr_vault = true` | ✅ Both primary and DR daily vaults created |
| `enable_daily_vault = true` | `enable_dr = true` | `enable_daily_dr_vault = false` | ✅ Only primary daily vault created |
| `enable_daily_vault = true` | `enable_dr = false` | `enable_daily_dr_vault = true` | ✅ Only primary daily vault created |
| `enable_daily_vault = false` | `enable_dr = true` | `enable_daily_dr_vault = true` | ❌ **ERROR**: Cannot create DR vault without primary |

### Validation Error Example

If you try to enable a DR vault without its primary vault:

```hcl
module "invalid_config" {
  source = "..."
  
  enable_daily_vault     = false  # Primary daily disabled
  enable_dr              = true   
  enable_daily_dr_vault  = true   # Trying to enable DR daily
  
  # This will fail with:
  # Error: Resource precondition failed
  # Cannot enable daily DR vault without primary daily vault. 
  # Set enable_daily_vault = true or enable_daily_dr_vault = false.
}
```

## Vault Naming Convention

Vaults are named based on the configuration:

**Primary Region:**
- With prefix: `{prefix}-{schedule}` (e.g., `prod-daily`)
- Without prefix: `{schedule}` (e.g., `daily`)

**DR Region:**
- With prefix: `{dr_prefix}-{schedule}` (e.g., `prod-dr-daily`)
- Without prefix: `dr-{schedule}` (e.g., `dr-daily`)

## Requirements

| Name | Version |
|------|---------|
| terraform | >= 1.0.0 |
| aws | >= 4.0.0 |

## Providers

| Name | Version | Required |
|------|---------|----------|
| aws | >= 4.0.0 | Yes |
| aws.dr | >= 4.0.0 | Only when `enable_dr = true` |

## Inputs

### Core Configuration

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| `create_single_vault` | Whether to create a single custom vault (set to false for scheduled vaults) | `bool` | `true` | no |
| `name` | Name of the single vault (used when create_single_vault = true) | `string` | `""` | no |
| `vault_name_prefix` | Prefix for scheduled vault names (e.g., 'prod' results in 'prod-daily', 'prod-weekly', etc.) | `string` | `""` | no |
| `kms_key_arn` | The server-side encryption key ARN that is used to protect your backups | `string` | n/a | yes |
| `force_destroy` | A boolean that indicates whether all recovery points stored in the vault should be deleted so that the vault can be destroyed without error. USE WITH CAUTION! | `bool` | `false` | no |
| `tags` | A mapping of tags to assign to all resources | `map(string)` | `{}` | no |

### Scheduled Vault Enable/Disable

Control which scheduled vaults are created:

| Name | Description | Type | Default |
|------|-------------|------|---------|
| `enable_hourly_vault` | Whether to create an hourly backup vault | `bool` | `false` |
| `enable_daily_vault` | Whether to create a daily backup vault | `bool` | `false` |
| `enable_weekly_vault` | Whether to create a weekly backup vault | `bool` | `false` |
| `enable_monthly_vault` | Whether to create a monthly backup vault | `bool` | `false` |
| `enable_yearly_vault` | Whether to create a yearly backup vault | `bool` | `false` |

### Vault Lock Configuration

Vault lock prevents deletion of recovery points before the minimum retention period:

| Name | Description | Type | Default | Notes |
|------|-------------|------|---------|--------|
| `enable_vault_lock` | Whether to enable vault lock on all vaults | `bool` | `false` | Once enabled, vault lock cannot be disabled |
| `vault_lock_changeable_for_days` | The number of days before the lock configuration becomes immutable | `number` | `3` | Set to 0 for immediate lock |
| `vault_lock_max_retention_days` | The maximum retention period that the vault retains recovery points | `number` | `1200` | Maximum allowed is 36500 (100 years) |
| `vault_lock_min_retention_days` | The minimum retention period for the single vault (when create_single_vault = true) | `number` | `7` | Must be <= max_retention_days |

### Schedule-Specific Minimum Retention Days

When vault lock is enabled, these define the minimum retention for each vault type:

| Name | Description | Type | Default | Typical Use Case |
|------|-------------|------|---------|------------------|
| `hourly_min_retention_days` | Minimum retention days for hourly vault lock | `number` | `1` | 1-3 days for rapid recovery |
| `daily_min_retention_days` | Minimum retention days for daily vault lock | `number` | `7` | 7-30 days for operational recovery |
| `weekly_min_retention_days` | Minimum retention days for weekly vault lock | `number` | `30` | 30-90 days for monthly reporting |
| `monthly_min_retention_days` | Minimum retention days for monthly vault lock | `number` | `365` | 365-730 days for compliance |
| `yearly_min_retention_days` | Minimum retention days for yearly vault lock | `number` | `2555` | 7-10 years for long-term archive |

### Disaster Recovery (DR) Configuration

Configure cross-region disaster recovery vaults:

| Name | Description | Type | Default | Notes |
|------|-------------|------|---------|--------|
| `enable_dr` | Master switch to enable DR functionality | `bool` | `false` | Requires aws.dr provider |
| `dr_vault_name` | Name for the single DR vault (used when create_single_vault = true) | `string` | `""` | Defaults to "dr-{name}" |
| `dr_vault_name_prefix` | Prefix for DR vault names (e.g., 'prod-dr' results in 'prod-dr-daily', etc.) | `string` | `""` | Defaults to "dr-{schedule}" |
| `dr_kms_key_arn` | The KMS key ARN for the DR region | `string` | `null` | Uses primary region key if not specified |
| `dr_tags` | Additional tags to apply to DR resources | `map(string)` | `{}` | Merged with primary tags |

### Granular DR Vault Control

Control which scheduled vaults get DR copies (requires enable_dr = true):

| Name | Description | Type | Default | Validation |
|------|-------------|------|---------|------------|
| `enable_hourly_dr_vault` | Whether to create a DR vault for hourly backups | `bool` | `true` | Requires enable_hourly_vault = true |
| `enable_daily_dr_vault` | Whether to create a DR vault for daily backups | `bool` | `true` | Requires enable_daily_vault = true |
| `enable_weekly_dr_vault` | Whether to create a DR vault for weekly backups | `bool` | `true` | Requires enable_weekly_vault = true |
| `enable_monthly_dr_vault` | Whether to create a DR vault for monthly backups | `bool` | `true` | Requires enable_monthly_vault = true |
| `enable_yearly_dr_vault` | Whether to create a DR vault for yearly backups | `bool` | `true` | Requires enable_yearly_vault = true |

### Common Configuration Patterns

#### Minimal Configuration
```hcl
# Single vault with defaults
module "simple_vault" {
  source      = "..."
  name        = "my-vault"
  kms_key_arn = aws_kms_key.backup.arn
}
```

#### Production with Selective DR
```hcl
# Multiple vaults with selective DR
module "prod_vaults" {
  source = "..."
  
  create_single_vault = false
  vault_name_prefix   = "prod"
  
  # Enable specific vaults
  enable_daily_vault   = true
  enable_weekly_vault  = true
  enable_monthly_vault = true
  
  # Enable vault lock with custom retention
  enable_vault_lock          = true
  daily_min_retention_days   = 14    # 2 weeks minimum
  weekly_min_retention_days  = 60    # 2 months minimum
  monthly_min_retention_days = 730   # 2 years minimum
  
  # Enable DR for critical vaults only
  enable_dr               = true
  dr_vault_name_prefix    = "prod-dr"
  enable_daily_dr_vault   = true
  enable_weekly_dr_vault  = true
  enable_monthly_dr_vault = false    # Save costs, no DR for monthly
  
  kms_key_arn = aws_kms_key.backup.arn
}
```

#### Compliance-Focused Configuration
```hcl
# Long retention with vault lock
module "compliance_vaults" {
  source = "..."
  
  create_single_vault = false
  vault_name_prefix   = "compliance"
  
  # Only long-term vaults
  enable_monthly_vault = true
  enable_yearly_vault  = true
  
  # Strict vault lock
  enable_vault_lock              = true
  vault_lock_changeable_for_days = 0      # Immediate lock
  vault_lock_max_retention_days  = 10950  # 30 years
  monthly_min_retention_days     = 1095   # 3 years
  yearly_min_retention_days      = 3650   # 10 years
  
  kms_key_arn = aws_kms_key.backup.arn
  
  tags = {
    Compliance = "required"
    Retention  = "long-term"
  }
}
```

## Outputs

| Name | Description |
|------|-------------|
| `id` | ID of the single vault (if created) |
| `arn` | ARN of the single vault (if created) |
| `name` | Name of the single vault (if created) |
| `recovery_points` | Number of recovery points in single vault |
| `scheduled_vault_ids` | Map of schedule type to vault ID |
| `scheduled_vault_arns` | Map of schedule type to vault ARN |
| `scheduled_vault_names` | Map of schedule type to vault name |
| `dr_vault_ids` | Map of DR vault schedule type to ID |
| `dr_vault_arns` | Map of DR vault schedule type to ARN |
| `dr_vault_names` | Map of DR vault schedule type to name |
| `all_vault_arns` | Combined map of all vault ARNs |

## Examples

### Production Setup with Cost-Optimized DR
```hcl
module "production_vaults" {
  source = "github.com/thinkstack-co/terraform-modules//modules/thinkstack/aws_backup_custom/modules/aws_backup_vault?ref=v2.6.6"
  
  providers = {
    aws    = aws
    aws.dr = aws.dr
  }

  create_single_vault = false
  vault_name_prefix   = "prod"
  
  # Create all primary vaults
  enable_hourly_vault  = true
  enable_daily_vault   = true
  enable_weekly_vault  = true
  enable_monthly_vault = true
  enable_yearly_vault  = true
  
  # Enable DR but optimize costs
  enable_dr            = true
  dr_vault_name_prefix = "prod-dr"
  
  # Only critical backups go to DR
  enable_hourly_dr_vault  = false  # Too expensive for hourly DR
  enable_daily_dr_vault   = true   # Critical daily backups to DR
  enable_weekly_dr_vault  = true   # Weekly snapshots to DR
  enable_monthly_dr_vault = true   # Compliance requires monthly DR
  enable_yearly_dr_vault  = false  # Yearly archives stay in primary region
  
  kms_key_arn    = aws_kms_key.backup.arn
  dr_kms_key_arn = aws_kms_key.dr_backup.arn
  
  # Enable vault lock for compliance
  enable_vault_lock = true
  
  tags = {
    Environment = "production"
    CostCenter  = "infrastructure"
  }
}
```

### Development Environment (No DR)
```hcl
module "dev_vaults" {
  source = "github.com/thinkstack-co/terraform-modules//modules/thinkstack/aws_backup_custom/modules/aws_backup_vault?ref=v2.6.6"

  create_single_vault = false
  vault_name_prefix   = "dev"
  
  # Only daily and weekly for dev
  enable_hourly_vault  = false
  enable_daily_vault   = true
  enable_weekly_vault  = true
  enable_monthly_vault = false
  enable_yearly_vault  = false
  
  # No DR for development
  enable_dr = false
  
  kms_key_arn = aws_kms_key.backup.arn
  
  tags = {
    Environment = "development"
  }
}
```

## Best Practices

1. **Start Simple**: Begin with basic scheduled vaults, add DR later
2. **Cost Optimization**: Not all vaults need DR - be selective
3. **Retention Alignment**: Set vault lock minimum retention to match your backup retention
4. **KMS Keys**: Use separate KMS keys for DR region for better security isolation
5. **Naming Convention**: Use consistent prefixes across environments

## Migration from Single Vault

If migrating from single vault to scheduled vaults:

1. Create new scheduled vaults with `create_single_vault = false`
2. Update backup plans to use new vault names
3. Wait for retention period to expire on old vault
4. Delete old single vault