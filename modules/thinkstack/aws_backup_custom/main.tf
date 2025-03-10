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

resource "aws_kms_alias" "backup_alias" {
  count         = var.create_kms_key ? 1 : 0
  name          = "alias/${var.kms_alias_name}"
  target_key_id = aws_kms_key.backup_key[0].key_id
}

###############################################################
# IAM Role for AWS Backup
###############################################################

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

resource "aws_iam_role_policy_attachment" "backup_policy_attach" {
  role       = aws_iam_role.backup_role.name
  policy_arn = "arn:aws:iam::aws:policy/service-role/AWSBackupServiceRolePolicyForBackup"
}

resource "aws_iam_role_policy_attachment" "restore_policy_attach" {
  role       = aws_iam_role.backup_role.name
  policy_arn = "arn:aws:iam::aws:policy/service-role/AWSBackupServiceRolePolicyForRestores"
}

# Add custom policy to allow tag-based selection
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

  # Filter custom backup plans to only include those referencing existing vaults
  valid_custom_plans = {
    for k, v in var.custom_backup_plans :
    k => v if lookup(local.vault_map, v.vault_name, false)
  }
}

###############################################################
# Backup Vaults
###############################################################

# Daily Backup Vault
resource "aws_backup_vault" "daily" {
  count         = local.create_daily_vault ? 1 : 0
  name          = "daily"
  kms_key_arn   = var.create_kms_key ? aws_kms_key.backup_key[0].arn : var.kms_key_arn
  force_destroy = var.force_destroy
  tags          = merge(var.tags, { Name = "daily" })
}

resource "aws_backup_vault_lock_configuration" "daily" {
  count        = local.create_daily_vault && var.enable_vault_lock ? 1 : 0
  backup_vault_name = aws_backup_vault.daily[0].name
  
  # Use the configurable vault lock parameters
  changeable_for_days = var.vault_lock_changeable_for_days
  max_retention_days  = var.vault_lock_max_retention_days
  min_retention_days  = var.daily_retention_days
}

# Hourly Backup Vault
resource "aws_backup_vault" "hourly" {
  count         = local.create_hourly_vault ? 1 : 0
  name          = "hourly"
  kms_key_arn   = var.create_kms_key ? aws_kms_key.backup_key[0].arn : var.kms_key_arn
  force_destroy = var.force_destroy
  tags          = merge(var.tags, { Name = "hourly" })
}

resource "aws_backup_vault_lock_configuration" "hourly" {
  count        = local.create_hourly_vault && var.enable_vault_lock ? 1 : 0
  backup_vault_name = aws_backup_vault.hourly[0].name
  
  # Use the configurable vault lock parameters
  changeable_for_days = var.vault_lock_changeable_for_days
  max_retention_days  = var.vault_lock_max_retention_days
  min_retention_days  = var.hourly_retention_days
}

# Weekly Backup Vault
resource "aws_backup_vault" "weekly" {
  count         = local.create_weekly_vault ? 1 : 0
  name          = "weekly"
  kms_key_arn   = var.create_kms_key ? aws_kms_key.backup_key[0].arn : var.kms_key_arn
  force_destroy = var.force_destroy
  tags          = merge(var.tags, { Name = "weekly" })
}

resource "aws_backup_vault_lock_configuration" "weekly" {
  count        = local.create_weekly_vault && var.enable_vault_lock ? 1 : 0
  backup_vault_name = aws_backup_vault.weekly[0].name
  
  # Use the configurable vault lock parameters
  changeable_for_days = var.vault_lock_changeable_for_days
  max_retention_days  = var.vault_lock_max_retention_days
  min_retention_days  = var.weekly_retention_days
}

# Monthly Backup Vault
resource "aws_backup_vault" "monthly" {
  count         = local.create_monthly_vault ? 1 : 0
  name          = "monthly"
  kms_key_arn   = var.create_kms_key ? aws_kms_key.backup_key[0].arn : var.kms_key_arn
  force_destroy = var.force_destroy
  tags          = merge(var.tags, { Name = "monthly" })
}

resource "aws_backup_vault_lock_configuration" "monthly" {
  count        = local.create_monthly_vault && var.enable_vault_lock ? 1 : 0
  backup_vault_name = aws_backup_vault.monthly[0].name
  
  # Use the configurable vault lock parameters
  changeable_for_days = var.vault_lock_changeable_for_days
  max_retention_days  = var.vault_lock_max_retention_days
  min_retention_days  = var.monthly_retention_days
}

# Yearly Backup Vault
resource "aws_backup_vault" "yearly" {
  count         = local.create_yearly_vault ? 1 : 0
  name          = "yearly"
  kms_key_arn   = var.create_kms_key ? aws_kms_key.backup_key[0].arn : var.kms_key_arn
  force_destroy = var.force_destroy
  tags          = merge(var.tags, { Name = "yearly" })
}

resource "aws_backup_vault_lock_configuration" "yearly" {
  count        = local.create_yearly_vault && var.enable_vault_lock ? 1 : 0
  backup_vault_name = aws_backup_vault.yearly[0].name
  
  # Use the configurable vault lock parameters
  changeable_for_days = var.vault_lock_changeable_for_days
  max_retention_days  = var.vault_lock_max_retention_days
  min_retention_days  = var.yearly_retention_days
}

###############################################################
# Backup Plans
###############################################################

# Hourly Backup Plan
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

# Daily Backup Plan
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

# Weekly Backup Plan
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

# Monthly Backup Plan
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

# Yearly Backup Plan
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

# Hourly Backup Selection
resource "aws_backup_selection" "hourly_selection" {
  count        = var.create_hourly_plan ? 1 : 0
  name         = "hourly-tag-selection"
  iam_role_arn = aws_iam_role.backup_role.arn
  plan_id      = aws_backup_plan.hourly_backup_plan[0].id

  selection_tag {
    type  = "STRINGEQUALS"
    key   = var.standard_backup_tag_key
    value = "hourly"
  }
}

# Hourly Backup Selection - For comma-separated values
resource "aws_backup_selection" "hourly_selection_csv" {
  for_each = var.create_hourly_plan ? toset([
    "hourly,daily", "hourly,weekly", "hourly,monthly", "hourly,yearly",
    "hourly,daily,weekly", "hourly,daily,monthly", "hourly,daily,yearly",
    "hourly,weekly,monthly", "hourly,weekly,yearly", "hourly,monthly,yearly",
    "hourly,daily,weekly,monthly", "hourly,daily,weekly,yearly", "hourly,daily,monthly,yearly",
    "hourly,weekly,monthly,yearly", "hourly,daily,weekly,monthly,yearly",
    "daily,hourly", "weekly,hourly", "monthly,hourly", "yearly,hourly",
    "daily,weekly,hourly", "daily,monthly,hourly", "daily,yearly,hourly",
    "weekly,monthly,hourly", "weekly,yearly,hourly", "monthly,yearly,hourly",
    "daily,weekly,monthly,hourly", "daily,weekly,yearly,hourly", "daily,monthly,yearly,hourly",
    "weekly,monthly,yearly,hourly", "daily,weekly,monthly,yearly,hourly"
  ]) : toset([])

  # Generate a shorter name using a hash of the combination
  name         = "h-sel-${substr(md5(each.key), 0, 8)}"
  iam_role_arn = aws_iam_role.backup_role.arn
  plan_id      = aws_backup_plan.hourly_backup_plan[0].id

  selection_tag {
    type  = "STRINGEQUALS"
    key   = var.standard_backup_tag_key
    value = each.key
  }
}

# Daily Backup Selection
resource "aws_backup_selection" "daily_selection" {
  count        = var.create_daily_plan ? 1 : 0
  name         = "daily-tag-selection"
  iam_role_arn = aws_iam_role.backup_role.arn
  plan_id      = aws_backup_plan.daily_backup_plan[0].id

  selection_tag {
    type  = "STRINGEQUALS"
    key   = var.standard_backup_tag_key
    value = "daily"
  }
}

# Daily Backup Selection - For comma-separated values
resource "aws_backup_selection" "daily_selection_csv" {
  for_each = var.create_daily_plan ? toset([
    "daily,weekly", "daily,monthly", "daily,yearly",
    "daily,weekly,monthly", "daily,weekly,yearly", "daily,monthly,yearly",
    "daily,weekly,monthly,yearly",
    "weekly,daily", "monthly,daily", "yearly,daily",
    "weekly,monthly,daily", "weekly,yearly,daily", "monthly,yearly,daily",
    "weekly,monthly,yearly,daily"
  ]) : toset([])

  # Generate a shorter name using a hash of the combination
  name         = "d-sel-${substr(md5(each.key), 0, 8)}"
  iam_role_arn = aws_iam_role.backup_role.arn
  plan_id      = aws_backup_plan.daily_backup_plan[0].id

  selection_tag {
    type  = "STRINGEQUALS"
    key   = var.standard_backup_tag_key
    value = each.key
  }
}

# Weekly Backup Selection
resource "aws_backup_selection" "weekly_selection" {
  count        = var.create_weekly_plan ? 1 : 0
  name         = "weekly-tag-selection"
  iam_role_arn = aws_iam_role.backup_role.arn
  plan_id      = aws_backup_plan.weekly_backup_plan[0].id

  selection_tag {
    type  = "STRINGEQUALS"
    key   = var.standard_backup_tag_key
    value = "weekly"
  }
}

# Weekly Backup Selection - For comma-separated values
resource "aws_backup_selection" "weekly_selection_csv" {
  for_each = var.create_weekly_plan ? toset([
    "weekly,monthly", "weekly,yearly",
    "weekly,monthly,yearly",
    "monthly,weekly", "yearly,weekly",
    "monthly,yearly,weekly"
  ]) : toset([])

  # Generate a shorter name using a hash of the combination
  name         = "w-sel-${substr(md5(each.key), 0, 8)}"
  iam_role_arn = aws_iam_role.backup_role.arn
  plan_id      = aws_backup_plan.weekly_backup_plan[0].id

  selection_tag {
    type  = "STRINGEQUALS"
    key   = var.standard_backup_tag_key
    value = each.key
  }
}

# Monthly Backup Selection
resource "aws_backup_selection" "monthly_selection" {
  count        = var.create_monthly_plan ? 1 : 0
  name         = "monthly-tag-selection"
  iam_role_arn = aws_iam_role.backup_role.arn
  plan_id      = aws_backup_plan.monthly_backup_plan[0].id

  selection_tag {
    type  = "STRINGEQUALS"
    key   = var.standard_backup_tag_key
    value = "monthly"
  }
}

# Monthly Backup Selection - For comma-separated values
resource "aws_backup_selection" "monthly_selection_csv" {
  for_each = var.create_monthly_plan ? toset([
    "monthly,yearly",
    "yearly,monthly"
  ]) : toset([])

  # Generate a shorter name using a hash of the combination
  name         = "m-sel-${substr(md5(each.key), 0, 8)}"
  iam_role_arn = aws_iam_role.backup_role.arn
  plan_id      = aws_backup_plan.monthly_backup_plan[0].id

  selection_tag {
    type  = "STRINGEQUALS"
    key   = var.standard_backup_tag_key
    value = each.key
  }
}

# Yearly Backup Selection
resource "aws_backup_selection" "yearly_selection" {
  count        = var.create_yearly_plan ? 1 : 0
  name         = "yearly-tag-selection"
  iam_role_arn = aws_iam_role.backup_role.arn
  plan_id      = aws_backup_plan.yearly_backup_plan[0].id

  selection_tag {
    type  = "STRINGEQUALS"
    key   = var.standard_backup_tag_key
    value = "yearly"
  }
}

###############################################################
# Custom Backup Plans
###############################################################

resource "aws_backup_plan" "custom_backup_plans" {
  for_each = local.valid_custom_plans
  name     = each.key
  tags     = merge(var.tags, each.value.tags)

  rule {
    rule_name                = "${each.key}_rule"
    target_vault_name        = local.vault_map[each.value.vault_name]
    schedule                 = each.value.schedule
    enable_continuous_backup = each.value.enable_continuous_backup
    start_window             = var.backup_start_window
    completion_window        = var.backup_completion_window

    lifecycle {
      delete_after = each.value.retention_days
    }
  }

  dynamic "advanced_backup_setting" {
    for_each = each.value.resource_type == "EC2" && var.enable_windows_vss && each.value.windows_vss ? [1] : []
    content {
      backup_options = {
        WindowsVSS = "enabled"
      }
      resource_type = "EC2"
    }
  }
}

# Custom Backup Selection
resource "aws_backup_selection" "custom_selection" {
  for_each     = local.valid_custom_plans
  name         = "${each.key}-tag-selection"
  iam_role_arn = aws_iam_role.backup_role.arn
  plan_id      = aws_backup_plan.custom_backup_plans[each.key].id

  selection_tag {
    type  = "STRINGEQUALS"
    key   = each.value.tag_key != "" ? each.value.tag_key : var.default_custom_backup_tag_key
    value = each.value.tag_value
  }
}
