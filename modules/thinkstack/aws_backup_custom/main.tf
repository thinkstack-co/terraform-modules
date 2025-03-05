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
# Backup Vaults
###############################################################

resource "aws_backup_vault" "daily_vault" {
  count       = var.create_daily_plan ? 1 : 0
  name        = "daily"
  kms_key_arn = var.create_kms_key ? aws_kms_key.backup_key[0].arn : null
  tags        = merge(var.tags, { backup_type = "daily" })
}

resource "aws_backup_vault" "weekly_vault" {
  count       = var.create_weekly_plan ? 1 : 0
  name        = "weekly"
  kms_key_arn = var.create_kms_key ? aws_kms_key.backup_key[0].arn : null
  tags        = merge(var.tags, { backup_type = "weekly" })
}

resource "aws_backup_vault" "monthly_vault" {
  count       = var.create_monthly_plan ? 1 : 0
  name        = "monthly"
  kms_key_arn = var.create_kms_key ? aws_kms_key.backup_key[0].arn : null
  tags        = merge(var.tags, { backup_type = "monthly" })
}

resource "aws_backup_vault" "yearly_vault" {
  count       = var.create_yearly_plan ? 1 : 0
  name        = "yearly"
  kms_key_arn = var.create_kms_key ? aws_kms_key.backup_key[0].arn : null
  tags        = merge(var.tags, { backup_type = "yearly" })
}

###############################################################
# Backup Plans
###############################################################

# Daily Backup Plan
resource "aws_backup_plan" "daily_backup_plan" {
  count = var.create_daily_plan ? 1 : 0
  name  = var.daily_plan_name
  tags  = var.tags

  rule {
    rule_name                = "daily_backup_rule"
    target_vault_name        = aws_backup_vault.daily_vault[0].name
    schedule                 = var.daily_schedule
    enable_continuous_backup = var.daily_enable_continuous_backup
    start_window             = var.backup_start_window
    completion_window        = var.backup_completion_window

    lifecycle {
      delete_after = var.daily_retention_days
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
    target_vault_name        = aws_backup_vault.weekly_vault[0].name
    schedule                 = var.weekly_schedule
    enable_continuous_backup = var.weekly_enable_continuous_backup
    start_window             = var.backup_start_window
    completion_window        = var.backup_completion_window

    lifecycle {
      delete_after = var.weekly_retention_days
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
    target_vault_name        = aws_backup_vault.monthly_vault[0].name
    schedule                 = var.monthly_schedule
    enable_continuous_backup = var.monthly_enable_continuous_backup
    start_window             = var.backup_start_window
    completion_window        = var.backup_completion_window

    lifecycle {
      delete_after = var.monthly_retention_days
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
    target_vault_name        = aws_backup_vault.yearly_vault[0].name
    schedule                 = var.yearly_schedule
    enable_continuous_backup = var.yearly_enable_continuous_backup
    start_window             = var.backup_start_window
    completion_window        = var.backup_completion_window

    lifecycle {
      delete_after = var.yearly_retention_days
    }
  }
}

###############################################################
# Backup Selections (Tag-Based)
###############################################################

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

# Local map to reference vaults by name
locals {
  vault_map = {
    daily   = var.create_daily_plan ? aws_backup_vault.daily_vault[0].name : null
    weekly  = var.create_weekly_plan ? aws_backup_vault.weekly_vault[0].name : null
    monthly = var.create_monthly_plan ? aws_backup_vault.monthly_vault[0].name : null
    yearly  = var.create_yearly_plan ? aws_backup_vault.yearly_vault[0].name : null
  }
  
  # Filter custom backup plans to only include those with valid vault references
  valid_custom_plans = {
    for k, v in var.custom_backup_plans : k => v
    if contains(keys(local.vault_map), v.vault_name) && local.vault_map[v.vault_name] != null
  }
}

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
    for_each = each.value.resource_type == "EC2" ? [1] : []
    content {
      backup_options = {
        WindowsVSS = "enabled"
      }
      resource_type = "EC2"
    }
  }
}

# Custom Backup Selections
resource "aws_backup_selection" "custom_selections" {
  for_each     = local.valid_custom_plans
  name         = "${each.key}-selection"
  iam_role_arn = aws_iam_role.backup_role.arn
  plan_id      = aws_backup_plan.custom_backup_plans[each.key].id

  selection_tag {
    type  = "STRINGEQUALS"
    key   = each.value.tag_key != "" ? each.value.tag_key : var.default_custom_backup_tag_key
    value = each.value.tag_value
  }
}
