terraform {
  required_version = ">= 1.0.0"
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = ">= 4.0.0"
    }
  }
}

###############################################################
# Data Sources
###############################################################

data "aws_caller_identity" "current" {}
data "aws_region" "current" {}

###############################################################
# KMS Encryption Key
###############################################################

# Creates a KMS (Key Management Service) key for encrypting backups in the primary region
# This key is used to encrypt all backup vaults and their contents for security
# Only created when var.create_kms_key is true, otherwise an existing key ARN must be provided
resource "aws_kms_key" "backup_key" {
  count                              = var.create_kms_key ? 1 : 0
  bypass_policy_lockout_safety_check = var.key_bypass_policy_lockout_safety_check
  customer_master_key_spec           = var.key_customer_master_key_spec
  description                        = var.key_description
  deletion_window_in_days            = var.key_deletion_window_in_days
  enable_key_rotation                = var.key_enable_key_rotation
  key_usage                          = var.key_usage
  is_enabled                         = var.key_is_enabled
  policy                             = var.key_policy
  tags                               = var.tags
}

# Creates a human-readable alias for the KMS key
# This makes it easier to reference the key in the AWS console and other resources
# Example: alias/aws-backup instead of a long key ID
resource "aws_kms_alias" "backup_alias" {
  count         = var.create_kms_key ? 1 : 0
  name          = "alias/${var.kms_alias_name}"
  target_key_id = aws_kms_key.backup_key[0].key_id
}

###############################################################
# IAM Role for AWS Backup
###############################################################

# Creates an IAM role that AWS Backup service will assume when performing backup operations
# This role allows the AWS Backup service to access and backup your AWS resources
# The trust policy allows only the backup.amazonaws.com service to assume this role
resource "aws_iam_role" "backup_role" {
  name               = var.backup_role_name
  assume_role_policy = <<POLICY
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Action": ["sts:AssumeRole"],
      "Effect": "Allow",
      "Principal": {
        "Service": ["backup.amazonaws.com"]
      }
    }
  ]
}
POLICY
  tags               = var.tags
}

# Attaches the AWS managed policy for backup operations to the IAM role
# This policy grants permissions to create backups, manage snapshots, and access resources
# Required for AWS Backup to perform backup operations on supported services
resource "aws_iam_role_policy_attachment" "backup_policy_attach" {
  role       = aws_iam_role.backup_role.name
  policy_arn = "arn:aws:iam::aws:policy/service-role/AWSBackupServiceRolePolicyForBackup"
}

# Attaches the AWS managed policy for restore operations to the IAM role
# This policy grants permissions to restore backups and create new resources from snapshots
# Required for AWS Backup to perform restore operations
resource "aws_iam_role_policy_attachment" "restore_policy_attach" {
  role       = aws_iam_role.backup_role.name
  policy_arn = "arn:aws:iam::aws:policy/service-role/AWSBackupServiceRolePolicyForRestores"
}

# Creates a custom IAM policy for tag-based resource selection
# This policy allows AWS Backup to discover and select resources based on their tags
# Essential for the tag-based backup selection strategy used throughout this module
resource "aws_iam_policy" "tag_based_backup_policy" {
  name        = "TagBasedBackupPolicy"
  description = "Policy to allow AWS Backup to select resources based on tags"
  policy      = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Effect": "Allow",
      "Action": [
        "tag:GetResources",
        "tag:GetTagKeys",
        "tag:GetTagValues"
      ],
      "Resource": "*"
    }
  ]
}
EOF
}

# Attaches the custom tag-based selection policy to the backup role
# This enables the backup selections to find resources by their tags
# Without this, tag-based selections would fail
resource "aws_iam_role_policy_attachment" "tag_policy_attach" {
  role       = aws_iam_role.backup_role.name
  policy_arn = aws_iam_policy.tag_based_backup_policy.arn
}


###############################################################
# Local variables for configuration logic
###############################################################

locals {
  # Determine which vaults should be created based on enabled backup plans
  create_daily_vault   = var.create_daily_plan
  create_weekly_vault  = var.create_weekly_plan
  create_monthly_vault = var.create_monthly_plan
  create_yearly_vault  = var.create_yearly_plan
  create_hourly_vault  = var.create_hourly_plan


  # Map of vault names to their creation status
  vault_map = {
    "daily"   = local.create_daily_vault
    "weekly"  = local.create_weekly_vault
    "monthly" = local.create_monthly_vault
    "yearly"  = local.create_yearly_vault
    "hourly"  = local.create_hourly_vault
  }

  # Map of plan names to their enabled status
  plan_enabled_map = {
    "hourly"  = var.create_hourly_plan
    "daily"   = var.create_daily_plan
    "weekly"  = var.create_weekly_plan
    "monthly" = var.create_monthly_plan
    "yearly"  = var.create_yearly_plan
  }

  # Define all possible combinations of standard backup plans
  # We'll only create selections for combinations where all referenced plans are enabled
  standard_plan_combinations = {
    "hourly-daily" = {
      plans   = ["hourly", "daily"]
      enabled = var.create_hourly_plan && var.create_daily_plan
      hash    = substr(sha256("hourly-daily"), 0, 8)
    }
    "hourly-weekly" = {
      plans   = ["hourly", "weekly"]
      enabled = var.create_hourly_plan && var.create_weekly_plan
      hash    = substr(sha256("hourly-weekly"), 0, 8)
    }
    "hourly-monthly" = {
      plans   = ["hourly", "monthly"]
      enabled = var.create_hourly_plan && var.create_monthly_plan
      hash    = substr(sha256("hourly-monthly"), 0, 8)
    }
    "hourly-yearly" = {
      plans   = ["hourly", "yearly"]
      enabled = var.create_hourly_plan && var.create_yearly_plan
      hash    = substr(sha256("hourly-yearly"), 0, 8)
    }
    "daily-weekly" = {
      plans   = ["daily", "weekly"]
      enabled = var.create_daily_plan && var.create_weekly_plan
      hash    = substr(sha256("daily-weekly"), 0, 8)
    }
    "daily-monthly" = {
      plans   = ["daily", "monthly"]
      enabled = var.create_daily_plan && var.create_monthly_plan
      hash    = substr(sha256("daily-monthly"), 0, 8)
    }
    "daily-yearly" = {
      plans   = ["daily", "yearly"]
      enabled = var.create_daily_plan && var.create_yearly_plan
      hash    = substr(sha256("daily-yearly"), 0, 8)
    }
    "weekly-monthly" = {
      plans   = ["weekly", "monthly"]
      enabled = var.create_weekly_plan && var.create_monthly_plan
      hash    = substr(sha256("weekly-monthly"), 0, 8)
    }
    "weekly-yearly" = {
      plans   = ["weekly", "yearly"]
      enabled = var.create_weekly_plan && var.create_yearly_plan
      hash    = substr(sha256("weekly-yearly"), 0, 8)
    }
    "monthly-yearly" = {
      plans   = ["monthly", "yearly"]
      enabled = var.create_monthly_plan && var.create_yearly_plan
      hash    = substr(sha256("monthly-yearly"), 0, 8)
    }
    "hourly-daily-weekly" = {
      plans   = ["hourly", "daily", "weekly"]
      enabled = var.create_hourly_plan && var.create_daily_plan && var.create_weekly_plan
      hash    = substr(sha256("hourly-daily-weekly"), 0, 8)
    }
    "hourly-daily-monthly" = {
      plans   = ["hourly", "daily", "monthly"]
      enabled = var.create_hourly_plan && var.create_daily_plan && var.create_monthly_plan
      hash    = substr(sha256("hourly-daily-monthly"), 0, 8)
    }
    "hourly-daily-yearly" = {
      plans   = ["hourly", "daily", "yearly"]
      enabled = var.create_hourly_plan && var.create_daily_plan && var.create_yearly_plan
      hash    = substr(sha256("hourly-daily-yearly"), 0, 8)
    }
    "hourly-weekly-monthly" = {
      plans   = ["hourly", "weekly", "monthly"]
      enabled = var.create_hourly_plan && var.create_weekly_plan && var.create_monthly_plan
      hash    = substr(sha256("hourly-weekly-monthly"), 0, 8)
    }
    "hourly-weekly-yearly" = {
      plans   = ["hourly", "weekly", "yearly"]
      enabled = var.create_hourly_plan && var.create_weekly_plan && var.create_yearly_plan
      hash    = substr(sha256("hourly-weekly-yearly"), 0, 8)
    }
    "hourly-monthly-yearly" = {
      plans   = ["hourly", "monthly", "yearly"]
      enabled = var.create_hourly_plan && var.create_monthly_plan && var.create_yearly_plan
      hash    = substr(sha256("hourly-monthly-yearly"), 0, 8)
    }
    "daily-weekly-monthly" = {
      plans   = ["daily", "weekly", "monthly"]
      enabled = var.create_daily_plan && var.create_weekly_plan && var.create_monthly_plan
      hash    = substr(sha256("daily-weekly-monthly"), 0, 8)
    }
    "daily-weekly-yearly" = {
      plans   = ["daily", "weekly", "yearly"]
      enabled = var.create_daily_plan && var.create_weekly_plan && var.create_yearly_plan
      hash    = substr(sha256("daily-weekly-yearly"), 0, 8)
    }
    "daily-monthly-yearly" = {
      plans   = ["daily", "monthly", "yearly"]
      enabled = var.create_daily_plan && var.create_monthly_plan && var.create_yearly_plan
      hash    = substr(sha256("daily-monthly-yearly"), 0, 8)
    }
    "weekly-monthly-yearly" = {
      plans   = ["weekly", "monthly", "yearly"]
      enabled = var.create_weekly_plan && var.create_monthly_plan && var.create_yearly_plan
      hash    = substr(sha256("weekly-monthly-yearly"), 0, 8)
    }
    "hourly-daily-weekly-monthly" = {
      plans   = ["hourly", "daily", "weekly", "monthly"]
      enabled = var.create_hourly_plan && var.create_daily_plan && var.create_weekly_plan && var.create_monthly_plan
      hash    = substr(sha256("hourly-daily-weekly-monthly"), 0, 8)
    }
    "hourly-daily-weekly-yearly" = {
      plans   = ["hourly", "daily", "weekly", "yearly"]
      enabled = var.create_hourly_plan && var.create_daily_plan && var.create_weekly_plan && var.create_yearly_plan
      hash    = substr(sha256("hourly-daily-weekly-yearly"), 0, 8)
    }
    "hourly-daily-monthly-yearly" = {
      plans   = ["hourly", "daily", "monthly", "yearly"]
      enabled = var.create_hourly_plan && var.create_daily_plan && var.create_monthly_plan && var.create_yearly_plan
      hash    = substr(sha256("hourly-daily-monthly-yearly"), 0, 8)
    }
    "hourly-weekly-monthly-yearly" = {
      plans   = ["hourly", "weekly", "monthly", "yearly"]
      enabled = var.create_hourly_plan && var.create_weekly_plan && var.create_monthly_plan && var.create_yearly_plan
      hash    = substr(sha256("hourly-weekly-monthly-yearly"), 0, 8)
    }
    "daily-weekly-monthly-yearly" = {
      plans   = ["daily", "weekly", "monthly", "yearly"]
      enabled = var.create_daily_plan && var.create_weekly_plan && var.create_monthly_plan && var.create_yearly_plan
      hash    = substr(sha256("daily-weekly-monthly-yearly"), 0, 8)
    }
    "hourly-daily-weekly-monthly-yearly" = {
      plans   = ["hourly", "daily", "weekly", "monthly", "yearly"]
      enabled = var.create_hourly_plan && var.create_daily_plan && var.create_weekly_plan && var.create_monthly_plan && var.create_yearly_plan
      hash    = substr(sha256("hourly-daily-weekly-monthly-yearly"), 0, 8)
    }
  }

  # Filter to only include combinations where all referenced plans are enabled
  valid_plan_combinations = {
    for k, v in local.standard_plan_combinations :
    k => v if v.enabled
  }


  # Map of plan names to their DR inclusion status
  plan_dr_include_map = {
    "hourly"  = var.hourly_include_in_dr
    "daily"   = var.daily_include_in_dr
    "weekly"  = var.weekly_include_in_dr
    "monthly" = var.monthly_include_in_dr
    "yearly"  = var.yearly_include_in_dr
  }
}

###############################################################
# Backup Vaults
###############################################################

# Creates a backup vault for storing daily backups
# Vaults are encrypted storage locations for backup recovery points
# Each vault is encrypted with either the module-created KMS key or a provided key
# Only created when daily backup plan is enabled
resource "aws_backup_vault" "daily" {
  count         = local.create_daily_vault ? 1 : 0
  name          = "daily"
  kms_key_arn   = var.create_kms_key ? aws_kms_key.backup_key[0].arn : var.kms_key_arn
  force_destroy = var.force_destroy
  tags          = merge(var.tags, { Name = "daily" })
}

# Configures vault lock for the daily backup vault to prevent deletion of backups
# Vault lock provides additional protection against accidental or malicious deletion
# Once locked, backups cannot be deleted before min_retention_days
# Only created when vault lock is enabled globally
resource "aws_backup_vault_lock_configuration" "daily" {
  count             = local.create_daily_vault && var.enable_vault_lock ? 1 : 0
  backup_vault_name = aws_backup_vault.daily[0].name

  # Use the configurable vault lock parameters
  changeable_for_days = var.vault_lock_changeable_for_days
  max_retention_days  = var.vault_lock_max_retention_days
  min_retention_days  = var.daily_retention_days
}

# Creates a backup vault for storing hourly backups
# Separate vault for hourly backups allows different retention and access policies
# Typically used for high-frequency backups of critical resources
# Only created when hourly backup plan is enabled
resource "aws_backup_vault" "hourly" {
  count         = local.create_hourly_vault ? 1 : 0
  name          = "hourly"
  kms_key_arn   = var.create_kms_key ? aws_kms_key.backup_key[0].arn : var.kms_key_arn
  force_destroy = var.force_destroy
  tags          = merge(var.tags, { Name = "hourly" })
}

resource "aws_backup_vault_lock_configuration" "hourly" {
  count             = local.create_hourly_vault && var.enable_vault_lock ? 1 : 0
  backup_vault_name = aws_backup_vault.hourly[0].name

  # Use the configurable vault lock parameters
  changeable_for_days = var.vault_lock_changeable_for_days
  max_retention_days  = var.vault_lock_max_retention_days
  min_retention_days  = var.hourly_retention_days
}

# Creates a backup vault for storing weekly backups
# Weekly vaults typically store backups for medium-term retention (weeks to months)
# Separate vault allows for different access controls and lifecycle policies
# Only created when weekly backup plan is enabled
resource "aws_backup_vault" "weekly" {
  count         = local.create_weekly_vault ? 1 : 0
  name          = "weekly"
  kms_key_arn   = var.create_kms_key ? aws_kms_key.backup_key[0].arn : var.kms_key_arn
  force_destroy = var.force_destroy
  tags          = merge(var.tags, { Name = "weekly" })
}

resource "aws_backup_vault_lock_configuration" "weekly" {
  count             = local.create_weekly_vault && var.enable_vault_lock ? 1 : 0
  backup_vault_name = aws_backup_vault.weekly[0].name

  # Use the configurable vault lock parameters
  changeable_for_days = var.vault_lock_changeable_for_days
  max_retention_days  = var.vault_lock_max_retention_days
  min_retention_days  = var.weekly_retention_days
}

# Creates a backup vault for storing monthly backups
# Monthly vaults are used for longer-term retention (months to years)
# Often used for compliance requirements or historical data preservation
# Only created when monthly backup plan is enabled
resource "aws_backup_vault" "monthly" {
  count         = local.create_monthly_vault ? 1 : 0
  name          = "monthly"
  kms_key_arn   = var.create_kms_key ? aws_kms_key.backup_key[0].arn : var.kms_key_arn
  force_destroy = var.force_destroy
  tags          = merge(var.tags, { Name = "monthly" })
}

resource "aws_backup_vault_lock_configuration" "monthly" {
  count             = local.create_monthly_vault && var.enable_vault_lock ? 1 : 0
  backup_vault_name = aws_backup_vault.monthly[0].name

  # Use the configurable vault lock parameters
  changeable_for_days = var.vault_lock_changeable_for_days
  max_retention_days  = var.vault_lock_max_retention_days
  min_retention_days  = var.monthly_retention_days
}

# Creates a backup vault for storing yearly backups
# Yearly vaults are used for long-term archival and compliance requirements
# These backups are typically kept for multiple years for audit purposes
# Only created when yearly backup plan is enabled
resource "aws_backup_vault" "yearly" {
  count         = local.create_yearly_vault ? 1 : 0
  name          = "yearly"
  kms_key_arn   = var.create_kms_key ? aws_kms_key.backup_key[0].arn : var.kms_key_arn
  force_destroy = var.force_destroy
  tags          = merge(var.tags, { Name = "yearly" })
}

resource "aws_backup_vault_lock_configuration" "yearly" {
  count             = local.create_yearly_vault && var.enable_vault_lock ? 1 : 0
  backup_vault_name = aws_backup_vault.yearly[0].name

  # Use the configurable vault lock parameters
  changeable_for_days = var.vault_lock_changeable_for_days
  max_retention_days  = var.vault_lock_max_retention_days
  min_retention_days  = var.yearly_retention_days
}


# Creates a KMS key in the DR region for encrypting cross-region backup copies
# This is a separate key from the primary region key due to KMS regional limitations
# Only created when both DR is enabled and KMS key creation is requested
resource "aws_kms_key" "dr_backup_key" {
  count                    = var.enable_dr && var.create_kms_key ? 1 : 0
  provider                 = aws.dr
  description              = "DR region KMS key for AWS Backup (copied from prod)"
  deletion_window_in_days  = var.key_deletion_window_in_days
  enable_key_rotation      = var.key_enable_key_rotation
  is_enabled               = var.key_is_enabled
  key_usage                = var.key_usage
  customer_master_key_spec = var.key_customer_master_key_spec
  policy                   = var.key_policy
  tags                     = merge(var.tags, var.dr_tags, { Name = "dr-backup-key" })
}

# Creates an alias for the DR region KMS key
# Uses the same base name as primary with '-dr' suffix for consistency
# Makes it easy to identify DR keys in the AWS console
resource "aws_kms_alias" "dr_backup_alias" {
  count         = var.enable_dr && var.create_kms_key ? 1 : 0
  provider      = aws.dr
  name          = "alias/${var.kms_alias_name}-dr"
  target_key_id = aws_kms_key.dr_backup_key[0].key_id
}

# Creates the disaster recovery vault in the DR region
# This vault receives cross-region copies of backups from the primary region
# All DR-enabled backups are copied to this single vault regardless of schedule type
# Only created when DR is enabled
resource "aws_backup_vault" "dr" {
  count         = var.enable_dr ? 1 : 0
  provider      = aws.dr
  name          = var.dr_vault_name
  kms_key_arn   = var.create_kms_key ? aws_kms_key.dr_backup_key[0].arn : var.kms_key_arn
  force_destroy = var.force_destroy
  tags          = merge(var.tags, var.dr_tags, { Name = var.dr_vault_name })
}

###############################################################
# Backup Plans
###############################################################

# Creates an hourly backup plan for high-frequency backups
# This plan runs every hour and is typically used for critical databases or applications
# Backups are stored in the hourly vault with short retention (default 1 day)
# Always created when hourly backups are enabled, regardless of DR settings
resource "aws_backup_plan" "hourly_backup_plan" {
  count = var.create_hourly_plan ? 1 : 0
  name  = var.hourly_plan_name

  rule {
    rule_name                = "hourly-backup-rule"
    target_vault_name        = aws_backup_vault.hourly[0].name
    schedule                 = var.hourly_schedule
    enable_continuous_backup = var.hourly_enable_continuous_backup
    start_window             = var.backup_start_window
    completion_window        = var.backup_completion_window

    lifecycle {
      delete_after = var.hourly_retention_days
    }

  }

  dynamic "advanced_backup_setting" {
    for_each = var.enable_windows_vss && var.hourly_windows_vss ? [1] : []
    content {
      backup_options = {
        WindowsVSS = "enabled"
      }
      resource_type = "EC2"
    }
  }

  tags = merge(var.tags, { Name = var.hourly_plan_name })
}


# Creates a daily backup plan for regular backups
# This is the most common backup frequency for production resources
# Runs once per day at the specified time (default 1 AM UTC)
# Always created when daily backups are enabled, regardless of DR settings
resource "aws_backup_plan" "daily_backup_plan" {
  count = var.create_daily_plan ? 1 : 0
  name  = var.daily_plan_name
  tags  = var.tags

  rule {
    rule_name                = "daily_backup_rule"
    target_vault_name        = aws_backup_vault.daily[0].name
    schedule                 = var.daily_schedule
    enable_continuous_backup = var.daily_enable_continuous_backup
    start_window             = var.backup_start_window
    completion_window        = var.backup_completion_window

    lifecycle {
      delete_after = var.daily_retention_days
    }

  }

  dynamic "advanced_backup_setting" {
    for_each = var.enable_windows_vss && var.daily_windows_vss ? [1] : []
    content {
      backup_options = {
        WindowsVSS = "enabled"
      }
      resource_type = "EC2"
    }
  }
}


# Creates a weekly backup plan for less frequent backups
# Typically runs on Sundays for week-end backups
# Used for resources that don't change frequently or need medium-term retention
# Always created when weekly backups are enabled, regardless of DR settings
resource "aws_backup_plan" "weekly_backup_plan" {
  count = var.create_weekly_plan ? 1 : 0
  name  = var.weekly_plan_name
  tags  = var.tags

  rule {
    rule_name                = "weekly_backup_rule"
    target_vault_name        = aws_backup_vault.weekly[0].name
    schedule                 = var.weekly_schedule
    enable_continuous_backup = var.weekly_enable_continuous_backup
    start_window             = var.backup_start_window
    completion_window        = var.backup_completion_window

    lifecycle {
      delete_after = var.weekly_retention_days
    }

  }

  dynamic "advanced_backup_setting" {
    for_each = var.enable_windows_vss && var.weekly_windows_vss ? [1] : []
    content {
      backup_options = {
        WindowsVSS = "enabled"
      }
      resource_type = "EC2"
    }
  }
}


# Creates a monthly backup plan for long-term retention
# Runs on the first day of each month
# Often used for compliance or archival purposes
# Always created when monthly backups are enabled, regardless of DR settings
resource "aws_backup_plan" "monthly_backup_plan" {
  count = var.create_monthly_plan ? 1 : 0
  name  = var.monthly_plan_name
  tags  = var.tags

  rule {
    rule_name                = "monthly_backup_rule"
    target_vault_name        = aws_backup_vault.monthly[0].name
    schedule                 = var.monthly_schedule
    enable_continuous_backup = var.monthly_enable_continuous_backup
    start_window             = var.backup_start_window
    completion_window        = var.backup_completion_window

    lifecycle {
      delete_after = var.monthly_retention_days
    }

  }

  dynamic "advanced_backup_setting" {
    for_each = var.enable_windows_vss && var.monthly_windows_vss ? [1] : []
    content {
      backup_options = {
        WindowsVSS = "enabled"
      }
      resource_type = "EC2"
    }
  }
}


# Creates a yearly backup plan for long-term archival
# Runs once per year on January 1st
# Used for compliance, legal holds, or historical preservation
# Always created when yearly backups are enabled, regardless of DR settings
resource "aws_backup_plan" "yearly_backup_plan" {
  count = var.create_yearly_plan ? 1 : 0
  name  = var.yearly_plan_name
  tags  = var.tags

  rule {
    rule_name                = "yearly_backup_rule"
    target_vault_name        = aws_backup_vault.yearly[0].name
    schedule                 = var.yearly_schedule
    enable_continuous_backup = var.yearly_enable_continuous_backup
    start_window             = var.backup_start_window
    completion_window        = var.backup_completion_window

    lifecycle {
      delete_after = var.yearly_retention_days
    }

  }

  dynamic "advanced_backup_setting" {
    for_each = var.enable_windows_vss && var.yearly_windows_vss ? [1] : []
    content {
      backup_options = {
        WindowsVSS = "enabled"
      }
      resource_type = "EC2"
    }
  }
}


###############################################################
# Backup Selections (Tag-Based)
###############################################################

# Creates backup selections for resources tagged with combination schedules
# This handles tags like "daily-weekly" or "daily-monthly-yearly"
# For each combination tag, it creates multiple selections linking to each individual plan
# Example: "daily-weekly" tag creates two selections - one for daily plan, one for weekly plan
# This allows a single resource to be backed up by multiple schedules
resource "aws_backup_selection" "multi_plan_selections" {
  for_each = {
    for item in flatten([
      for combo_name, combo in local.valid_plan_combinations : [
        for plan in combo.plans : {
          combo_name = combo_name
          combo      = combo
          plan       = plan
          key        = "${combo_name}-${plan}"
        } if lookup(local.plan_enabled_map, plan, false)
      ]
    ]) : item.key => item
  }

  name         = "multi-${each.value.combo.hash}-${each.value.plan}"
  iam_role_arn = aws_iam_role.backup_role.arn

  # Use the appropriate plan ID based on the current plan
  plan_id = lookup({
    "hourly"  = var.create_hourly_plan ? aws_backup_plan.hourly_backup_plan[0].id : null,
    "daily"   = var.create_daily_plan ? aws_backup_plan.daily_backup_plan[0].id : null,
    "weekly"  = var.create_weekly_plan ? aws_backup_plan.weekly_backup_plan[0].id : null,
    "monthly" = var.create_monthly_plan ? aws_backup_plan.monthly_backup_plan[0].id : null,
    "yearly"  = var.create_yearly_plan ? aws_backup_plan.yearly_backup_plan[0].id : null
  }, each.value.plan)

  selection_tag {
    type  = "STRINGEQUALS"
    key   = var.standard_backup_tag_key
    value = each.value.combo_name
  }
}

# Creates backup selection for resources tagged with backup_schedule="hourly"
# This selection links hourly-tagged resources to the hourly backup plan
# Resources with this tag will be backed up every hour
# Only created when the hourly backup plan is enabled
resource "aws_backup_selection" "hourly_selection" {
  for_each     = var.create_hourly_plan ? toset(["hourly"]) : toset([])
  name         = "hourly-tag-selection"
  iam_role_arn = aws_iam_role.backup_role.arn
  plan_id      = aws_backup_plan.hourly_backup_plan[0].id

  selection_tag {
    type  = "STRINGEQUALS"
    key   = var.standard_backup_tag_key
    value = each.key
  }
}

# Creates backup selection for resources tagged with backup_schedule="daily"
# This is typically the most commonly used backup selection
# Links daily-tagged resources to the daily backup plan
# Only created when the daily backup plan is enabled
resource "aws_backup_selection" "daily_selection" {
  for_each     = var.create_daily_plan ? toset(["daily"]) : toset([])
  name         = "daily-tag-selection"
  iam_role_arn = aws_iam_role.backup_role.arn
  plan_id      = aws_backup_plan.daily_backup_plan[0].id

  selection_tag {
    type  = "STRINGEQUALS"
    key   = var.standard_backup_tag_key
    value = each.key
  }
}

# Creates backup selection for resources tagged with backup_schedule="weekly"
# Used for resources that need less frequent backups
# Links weekly-tagged resources to the weekly backup plan
# Only created when the weekly backup plan is enabled
resource "aws_backup_selection" "weekly_selection" {
  for_each     = var.create_weekly_plan ? toset(["weekly"]) : toset([])
  name         = "weekly-tag-selection"
  iam_role_arn = aws_iam_role.backup_role.arn
  plan_id      = aws_backup_plan.weekly_backup_plan[0].id

  selection_tag {
    type  = "STRINGEQUALS"
    key   = var.standard_backup_tag_key
    value = each.key
  }
}

# Creates backup selection for resources tagged with backup_schedule="monthly"
# Used for resources requiring long-term retention
# Links monthly-tagged resources to the monthly backup plan
# Only created when the monthly backup plan is enabled
resource "aws_backup_selection" "monthly_selection" {
  for_each     = var.create_monthly_plan ? toset(["monthly"]) : toset([])
  name         = "monthly-tag-selection"
  iam_role_arn = aws_iam_role.backup_role.arn
  plan_id      = aws_backup_plan.monthly_backup_plan[0].id

  selection_tag {
    type  = "STRINGEQUALS"
    key   = var.standard_backup_tag_key
    value = each.key
  }
}

# Creates backup selection for resources tagged with backup_schedule="yearly"
# Used for archival and compliance requirements
# Links yearly-tagged resources to the yearly backup plan
# Only created when the yearly backup plan is enabled
resource "aws_backup_selection" "yearly_selection" {
  for_each     = var.create_yearly_plan ? toset(["yearly"]) : toset([])
  name         = "yearly-tag-selection"
  iam_role_arn = aws_iam_role.backup_role.arn
  plan_id      = aws_backup_plan.yearly_backup_plan[0].id

  selection_tag {
    type  = "STRINGEQUALS"
    key   = var.standard_backup_tag_key
    value = each.key
  }
}

# Creates backup selections for resources tagged with backup_schedule="all"
# The "all" tag is a convenience feature that includes resources in ALL enabled backup plans
# A resource tagged with "all" will be backed up hourly, daily, weekly, monthly, and yearly
# Each selection below links "all"-tagged resources to their respective backup plan
resource "aws_backup_selection" "hourly_selection_all" {
  for_each     = var.create_hourly_plan ? toset(["all"]) : toset([])
  name         = "hourly-all-selection"
  iam_role_arn = aws_iam_role.backup_role.arn
  plan_id      = aws_backup_plan.hourly_backup_plan[0].id

  selection_tag {
    type  = "STRINGEQUALS"
    key   = var.standard_backup_tag_key
    value = each.key
  }
}

resource "aws_backup_selection" "daily_selection_all" {
  for_each     = var.create_daily_plan ? toset(["all"]) : toset([])
  name         = "daily-all-selection"
  iam_role_arn = aws_iam_role.backup_role.arn
  plan_id      = aws_backup_plan.daily_backup_plan[0].id

  selection_tag {
    type  = "STRINGEQUALS"
    key   = var.standard_backup_tag_key
    value = each.key
  }
}

resource "aws_backup_selection" "weekly_selection_all" {
  for_each     = var.create_weekly_plan ? toset(["all"]) : toset([])
  name         = "weekly-all-selection"
  iam_role_arn = aws_iam_role.backup_role.arn
  plan_id      = aws_backup_plan.weekly_backup_plan[0].id

  selection_tag {
    type  = "STRINGEQUALS"
    key   = var.standard_backup_tag_key
    value = each.key
  }
}

resource "aws_backup_selection" "monthly_selection_all" {
  for_each     = var.create_monthly_plan ? toset(["all"]) : toset([])
  name         = "monthly-all-selection"
  iam_role_arn = aws_iam_role.backup_role.arn
  plan_id      = aws_backup_plan.monthly_backup_plan[0].id

  selection_tag {
    type  = "STRINGEQUALS"
    key   = var.standard_backup_tag_key
    value = each.key
  }
}

resource "aws_backup_selection" "yearly_selection_all" {
  for_each     = var.create_yearly_plan ? toset(["all"]) : toset([])
  name         = "yearly-all-selection"
  iam_role_arn = aws_iam_role.backup_role.arn
  plan_id      = aws_backup_plan.yearly_backup_plan[0].id

  selection_tag {
    type  = "STRINGEQUALS"
    key   = var.standard_backup_tag_key
    value = each.key
  }
}

###############################################################
# DR Backup Plans with Copy Actions
###############################################################

# These plans are for resources that have BOTH backup_schedule AND add_to_dr tags
# They include copy_action to replicate backups to DR region

# Creates an hourly backup plan with cross-region disaster recovery
# This plan creates backups in the primary region and automatically copies them to the DR region
# Only resources tagged with BOTH backup_schedule="hourly" AND add_to_dr="true" use this plan
# The copy_action ensures backups are replicated for disaster recovery scenarios
resource "aws_backup_plan" "hourly_backup_plan_dr" {
  count = var.create_hourly_plan && var.enable_dr && var.hourly_include_in_dr ? 1 : 0
  name  = "${var.hourly_plan_name}-dr"

  rule {
    rule_name                = "hourly-backup-rule-dr"
    target_vault_name        = aws_backup_vault.hourly[0].name
    schedule                 = var.hourly_schedule
    enable_continuous_backup = var.hourly_enable_continuous_backup
    start_window             = var.backup_start_window
    completion_window        = var.backup_completion_window

    lifecycle {
      delete_after = var.hourly_retention_days
    }

    copy_action {
      destination_vault_arn = "arn:aws:backup:${var.dr_region}:${data.aws_caller_identity.current.account_id}:backup-vault:${var.dr_vault_name}"
      lifecycle {
        delete_after = var.hourly_dr_retention_days != null ? var.hourly_dr_retention_days : var.hourly_retention_days
      }
    }
  }

  dynamic "advanced_backup_setting" {
    for_each = var.enable_windows_vss && var.hourly_windows_vss ? [1] : []
    content {
      backup_options = {
        WindowsVSS = "enabled"
      }
      resource_type = "EC2"
    }
  }

  tags = merge(var.tags, { Name = "${var.hourly_plan_name}-dr" })
}

# Creates a daily backup plan with cross-region disaster recovery
# Runs daily backups and copies them to the DR region for geographic redundancy
# Used for critical resources that need both local and remote backup copies
# Only applies to resources explicitly tagged for DR inclusion
resource "aws_backup_plan" "daily_backup_plan_dr" {
  count = var.create_daily_plan && var.enable_dr && var.daily_include_in_dr ? 1 : 0
  name  = "${var.daily_plan_name}-dr"

  rule {
    rule_name                = "daily-backup-rule-dr"
    target_vault_name        = aws_backup_vault.daily[0].name
    schedule                 = var.daily_schedule
    enable_continuous_backup = var.daily_enable_continuous_backup
    start_window             = var.backup_start_window
    completion_window        = var.backup_completion_window

    lifecycle {
      delete_after = var.daily_retention_days
    }

    copy_action {
      destination_vault_arn = "arn:aws:backup:${var.dr_region}:${data.aws_caller_identity.current.account_id}:backup-vault:${var.dr_vault_name}"
      lifecycle {
        delete_after = var.daily_dr_retention_days != null ? var.daily_dr_retention_days : var.daily_retention_days
      }
    }
  }

  dynamic "advanced_backup_setting" {
    for_each = var.enable_windows_vss && var.daily_windows_vss ? [1] : []
    content {
      backup_options = {
        WindowsVSS = "enabled"
      }
      resource_type = "EC2"
    }
  }

  tags = merge(var.tags, { Name = "${var.daily_plan_name}-dr" })
}

# Creates a weekly backup plan with cross-region disaster recovery
# Provides weekly snapshots with off-site copies for disaster scenarios
# Balances storage costs with recovery point objectives for less critical resources
# Requires explicit DR tagging to include resources
resource "aws_backup_plan" "weekly_backup_plan_dr" {
  count = var.create_weekly_plan && var.enable_dr && var.weekly_include_in_dr ? 1 : 0
  name  = "${var.weekly_plan_name}-dr"

  rule {
    rule_name                = "weekly-backup-rule-dr"
    target_vault_name        = aws_backup_vault.weekly[0].name
    schedule                 = var.weekly_schedule
    enable_continuous_backup = var.weekly_enable_continuous_backup
    start_window             = var.backup_start_window
    completion_window        = var.backup_completion_window

    lifecycle {
      delete_after = var.weekly_retention_days
    }

    copy_action {
      destination_vault_arn = "arn:aws:backup:${var.dr_region}:${data.aws_caller_identity.current.account_id}:backup-vault:${var.dr_vault_name}"
      lifecycle {
        delete_after = var.weekly_dr_retention_days != null ? var.weekly_dr_retention_days : var.weekly_retention_days
      }
    }
  }

  dynamic "advanced_backup_setting" {
    for_each = var.enable_windows_vss && var.weekly_windows_vss ? [1] : []
    content {
      backup_options = {
        WindowsVSS = "enabled"
      }
      resource_type = "EC2"
    }
  }

  tags = merge(var.tags, { Name = "${var.weekly_plan_name}-dr" })
}

# Creates a monthly backup plan with cross-region disaster recovery
# Ideal for compliance data that requires long-term retention in multiple regions
# DR copies can have different retention than primary backups
# Only processes resources with explicit DR tags
resource "aws_backup_plan" "monthly_backup_plan_dr" {
  count = var.create_monthly_plan && var.enable_dr && var.monthly_include_in_dr ? 1 : 0
  name  = "${var.monthly_plan_name}-dr"

  rule {
    rule_name                = "monthly-backup-rule-dr"
    target_vault_name        = aws_backup_vault.monthly[0].name
    schedule                 = var.monthly_schedule
    enable_continuous_backup = var.monthly_enable_continuous_backup
    start_window             = var.backup_start_window
    completion_window        = var.backup_completion_window

    lifecycle {
      delete_after = var.monthly_retention_days
    }

    copy_action {
      destination_vault_arn = "arn:aws:backup:${var.dr_region}:${data.aws_caller_identity.current.account_id}:backup-vault:${var.dr_vault_name}"
      lifecycle {
        delete_after = var.monthly_dr_retention_days != null ? var.monthly_dr_retention_days : var.monthly_retention_days
      }
    }
  }

  dynamic "advanced_backup_setting" {
    for_each = var.enable_windows_vss && var.monthly_windows_vss ? [1] : []
    content {
      backup_options = {
        WindowsVSS = "enabled"
      }
      resource_type = "EC2"
    }
  }

  tags = merge(var.tags, { Name = "${var.monthly_plan_name}-dr" })
}

# Creates a yearly backup plan with cross-region disaster recovery
# Provides annual snapshots replicated to DR region for long-term archival
# Used for legal/compliance requirements that mandate multi-region storage
# Only backs up resources explicitly marked for DR
resource "aws_backup_plan" "yearly_backup_plan_dr" {
  count = var.create_yearly_plan && var.enable_dr && var.yearly_include_in_dr ? 1 : 0
  name  = "${var.yearly_plan_name}-dr"

  rule {
    rule_name                = "yearly-backup-rule-dr"
    target_vault_name        = aws_backup_vault.yearly[0].name
    schedule                 = var.yearly_schedule
    enable_continuous_backup = var.yearly_enable_continuous_backup
    start_window             = var.backup_start_window
    completion_window        = var.backup_completion_window

    lifecycle {
      delete_after = var.yearly_retention_days
    }

    copy_action {
      destination_vault_arn = "arn:aws:backup:${var.dr_region}:${data.aws_caller_identity.current.account_id}:backup-vault:${var.dr_vault_name}"
      lifecycle {
        delete_after = var.yearly_dr_retention_days != null ? var.yearly_dr_retention_days : var.yearly_retention_days
      }
    }
  }

  dynamic "advanced_backup_setting" {
    for_each = var.enable_windows_vss && var.yearly_windows_vss ? [1] : []
    content {
      backup_options = {
        WindowsVSS = "enabled"
      }
      resource_type = "EC2"
    }
  }

  tags = merge(var.tags, { Name = "${var.yearly_plan_name}-dr" })
}

###############################################################
# DR Backup Selections (for resources with BOTH tags)
###############################################################

# Creates DR backup selection for hourly backups
# Only selects resources with BOTH backup_schedule="hourly" AND add_to_dr="true"
# These resources get backed up by both regular and DR plans (additive approach)
# The DR plan includes cross-region copy for disaster recovery
resource "aws_backup_selection" "hourly_dr_selection" {
  count        = var.create_hourly_plan && var.enable_dr && var.hourly_include_in_dr ? 1 : 0
  name         = "hourly-dr-tag-selection"
  iam_role_arn = aws_iam_role.backup_role.arn
  plan_id      = aws_backup_plan.hourly_backup_plan_dr[0].id

  selection_tag {
    type  = "STRINGEQUALS"
    key   = var.standard_backup_tag_key
    value = "hourly"
  }

  selection_tag {
    type  = "STRINGEQUALS"
    key   = var.dr_tag_key
    value = var.dr_tag_value
  }
}

# Creates DR backup selection for daily backups
# Implements dual-tag selection requiring both backup and DR tags
# Resources must explicitly opt-in to DR with add_to_dr="true"
# Provides geographic redundancy for critical daily backups
resource "aws_backup_selection" "daily_dr_selection" {
  count        = var.create_daily_plan && var.enable_dr && var.daily_include_in_dr ? 1 : 0
  name         = "daily-dr-tag-selection"
  iam_role_arn = aws_iam_role.backup_role.arn
  plan_id      = aws_backup_plan.daily_backup_plan_dr[0].id

  selection_tag {
    type  = "STRINGEQUALS"
    key   = var.standard_backup_tag_key
    value = "daily"
  }

  selection_tag {
    type  = "STRINGEQUALS"
    key   = var.dr_tag_key
    value = var.dr_tag_value
  }
}

# Creates DR backup selection for weekly backups
# Selects resources that need both local and cross-region weekly backups
# Requires explicit DR tagging to prevent unnecessary replication costs
# Balances RPO requirements with storage costs
resource "aws_backup_selection" "weekly_dr_selection" {
  count        = var.create_weekly_plan && var.enable_dr && var.weekly_include_in_dr ? 1 : 0
  name         = "weekly-dr-tag-selection"
  iam_role_arn = aws_iam_role.backup_role.arn
  plan_id      = aws_backup_plan.weekly_backup_plan_dr[0].id

  selection_tag {
    type  = "STRINGEQUALS"
    key   = var.standard_backup_tag_key
    value = "weekly"
  }

  selection_tag {
    type  = "STRINGEQUALS"
    key   = var.dr_tag_key
    value = var.dr_tag_value
  }
}

# Creates DR backup selection for monthly backups
# Typically used for compliance data requiring multi-region storage
# Long-term retention with geographic redundancy
# Only backs up resources explicitly marked for DR
resource "aws_backup_selection" "monthly_dr_selection" {
  count        = var.create_monthly_plan && var.enable_dr && var.monthly_include_in_dr ? 1 : 0
  name         = "monthly-dr-tag-selection"
  iam_role_arn = aws_iam_role.backup_role.arn
  plan_id      = aws_backup_plan.monthly_backup_plan_dr[0].id

  selection_tag {
    type  = "STRINGEQUALS"
    key   = var.standard_backup_tag_key
    value = "monthly"
  }

  selection_tag {
    type  = "STRINGEQUALS"
    key   = var.dr_tag_key
    value = var.dr_tag_value
  }
}

# Creates DR backup selection for yearly backups
# Provides annual archive copies in multiple regions
# Used for legal/regulatory compliance requiring long-term multi-region storage
# Requires both backup_schedule="yearly" and add_to_dr="true" tags
resource "aws_backup_selection" "yearly_dr_selection" {
  count        = var.create_yearly_plan && var.enable_dr && var.yearly_include_in_dr ? 1 : 0
  name         = "yearly-dr-tag-selection"
  iam_role_arn = aws_iam_role.backup_role.arn
  plan_id      = aws_backup_plan.yearly_backup_plan_dr[0].id

  selection_tag {
    type  = "STRINGEQUALS"
    key   = var.standard_backup_tag_key
    value = "yearly"
  }

  selection_tag {
    type  = "STRINGEQUALS"
    key   = var.dr_tag_key
    value = var.dr_tag_value
  }
}

# Creates DR backup selections for combination schedule tags
# Handles complex scenarios like resources tagged with "daily-weekly" + add_to_dr="true"
# Creates separate DR selections for each plan in the combination
# Ensures resources with multi-schedule tags can also benefit from DR protection
resource "aws_backup_selection" "multi_plan_dr_selections" {
  for_each = {
    for item in flatten([
      for combo_name, combo in local.valid_plan_combinations : [
        for plan in combo.plans : {
          combo_name = combo_name
          combo      = combo
          plan       = plan
          key        = "${combo_name}-${plan}-dr"
          plan_id = lookup({
            "hourly"  = var.create_hourly_plan && var.enable_dr && var.hourly_include_in_dr ? aws_backup_plan.hourly_backup_plan_dr[0].id : null,
            "daily"   = var.create_daily_plan && var.enable_dr && var.daily_include_in_dr ? aws_backup_plan.daily_backup_plan_dr[0].id : null,
            "weekly"  = var.create_weekly_plan && var.enable_dr && var.weekly_include_in_dr ? aws_backup_plan.weekly_backup_plan_dr[0].id : null,
            "monthly" = var.create_monthly_plan && var.enable_dr && var.monthly_include_in_dr ? aws_backup_plan.monthly_backup_plan_dr[0].id : null,
            "yearly"  = var.create_yearly_plan && var.enable_dr && var.yearly_include_in_dr ? aws_backup_plan.yearly_backup_plan_dr[0].id : null
          }, plan)
        } if lookup(local.plan_enabled_map, plan, false) && var.enable_dr && lookup(local.plan_dr_include_map, plan, false)
      ]
    ]) : item.key => item if item.plan_id != null
  }

  name         = "multi-${each.value.combo.hash}-${each.value.plan}-dr"
  iam_role_arn = aws_iam_role.backup_role.arn
  plan_id      = each.value.plan_id

  selection_tag {
    type  = "STRINGEQUALS"
    key   = var.standard_backup_tag_key
    value = each.value.combo_name
  }

  selection_tag {
    type  = "STRINGEQUALS"
    key   = var.dr_tag_key
    value = var.dr_tag_value
  }
}

# Creates DR backup selections for resources tagged with backup_schedule="all"
# These selections require BOTH "all" tag AND add_to_dr="true"
# Provides comprehensive backup coverage with DR for the most critical resources
# Each plan type gets its own DR selection to maintain separation
resource "aws_backup_selection" "hourly_dr_selection_all" {
  count        = var.create_hourly_plan && var.enable_dr && var.hourly_include_in_dr ? 1 : 0
  name         = "hourly-all-dr-selection"
  iam_role_arn = aws_iam_role.backup_role.arn
  plan_id      = aws_backup_plan.hourly_backup_plan_dr[0].id

  selection_tag {
    type  = "STRINGEQUALS"
    key   = var.standard_backup_tag_key
    value = "all"
  }

  selection_tag {
    type  = "STRINGEQUALS"
    key   = var.dr_tag_key
    value = var.dr_tag_value
  }
}

resource "aws_backup_selection" "daily_dr_selection_all" {
  count        = var.create_daily_plan && var.enable_dr && var.daily_include_in_dr ? 1 : 0
  name         = "daily-all-dr-selection"
  iam_role_arn = aws_iam_role.backup_role.arn
  plan_id      = aws_backup_plan.daily_backup_plan_dr[0].id

  selection_tag {
    type  = "STRINGEQUALS"
    key   = var.standard_backup_tag_key
    value = "all"
  }

  selection_tag {
    type  = "STRINGEQUALS"
    key   = var.dr_tag_key
    value = var.dr_tag_value
  }
}

resource "aws_backup_selection" "weekly_dr_selection_all" {
  count        = var.create_weekly_plan && var.enable_dr && var.weekly_include_in_dr ? 1 : 0
  name         = "weekly-all-dr-selection"
  iam_role_arn = aws_iam_role.backup_role.arn
  plan_id      = aws_backup_plan.weekly_backup_plan_dr[0].id

  selection_tag {
    type  = "STRINGEQUALS"
    key   = var.standard_backup_tag_key
    value = "all"
  }

  selection_tag {
    type  = "STRINGEQUALS"
    key   = var.dr_tag_key
    value = var.dr_tag_value
  }
}

resource "aws_backup_selection" "monthly_dr_selection_all" {
  count        = var.create_monthly_plan && var.enable_dr && var.monthly_include_in_dr ? 1 : 0
  name         = "monthly-all-dr-selection"
  iam_role_arn = aws_iam_role.backup_role.arn
  plan_id      = aws_backup_plan.monthly_backup_plan_dr[0].id

  selection_tag {
    type  = "STRINGEQUALS"
    key   = var.standard_backup_tag_key
    value = "all"
  }

  selection_tag {
    type  = "STRINGEQUALS"
    key   = var.dr_tag_key
    value = var.dr_tag_value
  }
}

resource "aws_backup_selection" "yearly_dr_selection_all" {
  count        = var.create_yearly_plan && var.enable_dr && var.yearly_include_in_dr ? 1 : 0
  name         = "yearly-all-dr-selection"
  iam_role_arn = aws_iam_role.backup_role.arn
  plan_id      = aws_backup_plan.yearly_backup_plan_dr[0].id

  selection_tag {
    type  = "STRINGEQUALS"
    key   = var.standard_backup_tag_key
    value = "all"
  }

  selection_tag {
    type  = "STRINGEQUALS"
    key   = var.dr_tag_key
    value = var.dr_tag_value
  }
}

