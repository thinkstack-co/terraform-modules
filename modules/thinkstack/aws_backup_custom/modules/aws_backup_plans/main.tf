terraform {
  required_version = ">= 1.0.0"
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = ">= 4.0.0"
    }
  }
}

locals {
  # Construct plan name with optional prefix
  plan_name_base = var.plan_prefix != "" ? "${var.plan_prefix}-${var.name}" : var.name

  # Define backup schedules
  backup_schedules = {
    hourly  = "cron(0 * ? * * *)" # Every hour
    daily   = "cron(0 5 ? * * *)" # Daily at 5 AM
    weekly  = "cron(0 5 ? * 1 *)" # Weekly on Monday at 5 AM
    monthly = "cron(0 5 1 * ? *)" # Monthly on the 1st at 5 AM
    yearly  = "cron(0 5 1 1 ? *)" # Yearly on January 1st at 5 AM
  }

  # Smart default tag keys based on DR status
  default_tag_keys = {
    hourly  = var.enable_hourly_dr_copy ? "hourly_prod_dr_backups" : "hourly_prod_backups"
    daily   = var.enable_daily_dr_copy ? "daily_prod_dr_backups" : "daily_prod_backups"
    weekly  = var.enable_weekly_dr_copy ? "weekly_prod_dr_backups" : "weekly_prod_backups"
    monthly = var.enable_monthly_dr_copy ? "monthly_prod_dr_backups" : "monthly_prod_backups"
    yearly  = var.enable_yearly_dr_copy ? "yearly_prod_dr_backups" : "yearly_prod_backups"
  }

  # Use custom tag key if provided, otherwise use smart default
  selection_tag_keys = {
    hourly  = coalesce(var.hourly_selection_tag_key, local.default_tag_keys.hourly)
    daily   = coalesce(var.daily_selection_tag_key, local.default_tag_keys.daily)
    weekly  = coalesce(var.weekly_selection_tag_key, local.default_tag_keys.weekly)
    monthly = coalesce(var.monthly_selection_tag_key, local.default_tag_keys.monthly)
    yearly  = coalesce(var.yearly_selection_tag_key, local.default_tag_keys.yearly)
  }

  # Determine DR vault ARNs - support both ARN and name inputs
  dr_vault_configs = {
    hourly = var.enable_hourly_dr_copy ? {
      vault_input = coalesce(var.hourly_dr_vault_arn, var.hourly_dr_vault_name)
      is_arn      = can(regex("^arn:aws:backup:", coalesce(var.hourly_dr_vault_arn, var.hourly_dr_vault_name, "")))
    } : null
    daily = var.enable_daily_dr_copy ? {
      vault_input = coalesce(var.daily_dr_vault_arn, var.daily_dr_vault_name)
      is_arn      = can(regex("^arn:aws:backup:", coalesce(var.daily_dr_vault_arn, var.daily_dr_vault_name, "")))
    } : null
    weekly = var.enable_weekly_dr_copy ? {
      vault_input = coalesce(var.weekly_dr_vault_arn, var.weekly_dr_vault_name)
      is_arn      = can(regex("^arn:aws:backup:", coalesce(var.weekly_dr_vault_arn, var.weekly_dr_vault_name, "")))
    } : null
    monthly = var.enable_monthly_dr_copy ? {
      vault_input = coalesce(var.monthly_dr_vault_arn, var.monthly_dr_vault_name)
      is_arn      = can(regex("^arn:aws:backup:", coalesce(var.monthly_dr_vault_arn, var.monthly_dr_vault_name, "")))
    } : null
    yearly = var.enable_yearly_dr_copy ? {
      vault_input = coalesce(var.yearly_dr_vault_arn, var.yearly_dr_vault_name)
      is_arn      = can(regex("^arn:aws:backup:", coalesce(var.yearly_dr_vault_arn, var.yearly_dr_vault_name, "")))
    } : null
  }

  # Get DR vault ARNs - if input is already an ARN use it, otherwise it must be provided as full ARN
  dr_vault_arns = {
    for k, v in local.dr_vault_configs : k => v != null ? v.vault_input : null
  }
}

# Data sources
data "aws_caller_identity" "current" {}

data "aws_region" "current" {}

locals {
  # Build plan configurations based on enabled flags
  plan_configs = {
    hourly = var.enable_hourly_plan ? {
      enabled                  = true
      schedule                 = coalesce(var.hourly_schedule, local.backup_schedules.hourly)
      retention_days           = var.hourly_retention_days
      vault_name               = var.hourly_vault_name
      enable_continuous_backup = var.hourly_enable_continuous_backup
      start_window             = var.hourly_start_window
      completion_window        = var.hourly_completion_window
      cold_storage_after       = var.hourly_cold_storage_after
      enable_dr_copy           = var.enable_hourly_dr_copy
      dr_vault_arn             = local.dr_vault_arns.hourly
      dr_retention_days        = var.hourly_dr_retention_days
      dr_cold_storage_after    = var.hourly_dr_cold_storage_after
    } : null

    daily = var.enable_daily_plan ? {
      enabled                  = true
      schedule                 = coalesce(var.daily_schedule, local.backup_schedules.daily)
      retention_days           = var.daily_retention_days
      vault_name               = var.daily_vault_name
      enable_continuous_backup = var.daily_enable_continuous_backup
      start_window             = var.daily_start_window
      completion_window        = var.daily_completion_window
      cold_storage_after       = var.daily_cold_storage_after
      enable_dr_copy           = var.enable_daily_dr_copy
      dr_vault_arn             = local.dr_vault_arns.daily
      dr_retention_days        = var.daily_dr_retention_days
      dr_cold_storage_after    = var.daily_dr_cold_storage_after
    } : null

    weekly = var.enable_weekly_plan ? {
      enabled                  = true
      schedule                 = coalesce(var.weekly_schedule, local.backup_schedules.weekly)
      retention_days           = var.weekly_retention_days
      vault_name               = var.weekly_vault_name
      enable_continuous_backup = var.weekly_enable_continuous_backup
      start_window             = var.weekly_start_window
      completion_window        = var.weekly_completion_window
      cold_storage_after       = var.weekly_cold_storage_after
      enable_dr_copy           = var.enable_weekly_dr_copy
      dr_vault_arn             = local.dr_vault_arns.weekly
      dr_retention_days        = var.weekly_dr_retention_days
      dr_cold_storage_after    = var.weekly_dr_cold_storage_after
    } : null

    monthly = var.enable_monthly_plan ? {
      enabled                  = true
      schedule                 = coalesce(var.monthly_schedule, local.backup_schedules.monthly)
      retention_days           = var.monthly_retention_days
      vault_name               = var.monthly_vault_name
      enable_continuous_backup = var.monthly_enable_continuous_backup
      start_window             = var.monthly_start_window
      completion_window        = var.monthly_completion_window
      cold_storage_after       = var.monthly_cold_storage_after
      enable_dr_copy           = var.enable_monthly_dr_copy
      dr_vault_arn             = local.dr_vault_arns.monthly
      dr_retention_days        = var.monthly_dr_retention_days
      dr_cold_storage_after    = var.monthly_dr_cold_storage_after
    } : null

    yearly = var.enable_yearly_plan ? {
      enabled                  = true
      schedule                 = coalesce(var.yearly_schedule, local.backup_schedules.yearly)
      retention_days           = var.yearly_retention_days
      vault_name               = var.yearly_vault_name
      enable_continuous_backup = var.yearly_enable_continuous_backup
      start_window             = var.yearly_start_window
      completion_window        = var.yearly_completion_window
      cold_storage_after       = var.yearly_cold_storage_after
      enable_dr_copy           = var.enable_yearly_dr_copy
      dr_vault_arn             = local.dr_vault_arns.yearly
      dr_retention_days        = var.yearly_dr_retention_days
      dr_cold_storage_after    = var.yearly_dr_cold_storage_after
    } : null
  }

  # Filter out null values
  enabled_plans = { for k, v in local.plan_configs : k => v if v != null }

  # Convert to list for dynamic block
  plan_rules = flatten([
    for plan_type, config in local.enabled_plans : {
      rule_name                = "${local.plan_name_base}-${plan_type}"
      target_vault_name        = config.vault_name
      schedule                 = config.schedule
      enable_continuous_backup = config.enable_continuous_backup
      start_window             = config.start_window
      completion_window        = config.completion_window
      lifecycle = config.retention_days != null || config.cold_storage_after != null ? {
        delete_after       = config.retention_days
        cold_storage_after = config.cold_storage_after
      } : null
      copy_actions = config.enable_dr_copy && config.dr_vault_arn != null ? [{
        destination_vault_arn = config.dr_vault_arn
        lifecycle = config.dr_retention_days != null || config.dr_cold_storage_after != null ? {
          delete_after       = config.dr_retention_days
          cold_storage_after = config.dr_cold_storage_after
        } : null
      }] : []
    }
  ])
}

# Create individual backup plans when use_individual_plans is true
resource "aws_backup_plan" "individual" {
  for_each = var.use_individual_plans ? local.enabled_plans : {}

  name = "${local.plan_name_base}-${each.key}"
  tags = merge(
    var.tags,
    {
      Schedule = each.key
      Type     = "backup-plan"
    },
    var.plan_prefix != "" ? { (var.plan_prefix) = "true" } : {}
  )

  rule {
    rule_name                = "${local.plan_name_base}-${each.key}-rule"
    target_vault_name        = each.value.vault_name
    schedule                 = each.value.schedule
    enable_continuous_backup = each.value.enable_continuous_backup
    start_window             = each.value.start_window
    completion_window        = each.value.completion_window

    dynamic "lifecycle" {
      for_each = each.value.retention_days != null || each.value.cold_storage_after != null ? [1] : []
      content {
        cold_storage_after = each.value.cold_storage_after
        delete_after       = each.value.retention_days
      }
    }

    dynamic "copy_action" {
      for_each = each.value.enable_dr_copy && each.value.dr_vault_arn != null ? [1] : []
      content {
        destination_vault_arn = each.value.dr_vault_arn

        dynamic "lifecycle" {
          for_each = each.value.dr_retention_days != null || each.value.dr_cold_storage_after != null ? [1] : []
          content {
            cold_storage_after = each.value.dr_cold_storage_after
            delete_after       = each.value.dr_retention_days
          }
        }
      }
    }
  }

  dynamic "advanced_backup_setting" {
    for_each = var.advanced_backup_settings
    content {
      backup_options = advanced_backup_setting.value.backup_options
      resource_type  = advanced_backup_setting.value.resource_type
    }
  }
}

# Create a single combined backup plan when use_individual_plans is false
resource "aws_backup_plan" "combined" {
  count = !var.use_individual_plans && length(local.enabled_plans) > 0 ? 1 : 0

  name = local.plan_name_base
  tags = merge(
    var.tags,
    var.plan_prefix != "" ? { (var.plan_prefix) = "true" } : {}
  )

  dynamic "rule" {
    for_each = local.plan_rules
    content {
      rule_name                = rule.value.rule_name
      target_vault_name        = rule.value.target_vault_name
      schedule                 = rule.value.schedule
      enable_continuous_backup = rule.value.enable_continuous_backup
      start_window             = rule.value.start_window
      completion_window        = rule.value.completion_window

      dynamic "lifecycle" {
        for_each = rule.value.lifecycle != null ? [rule.value.lifecycle] : []
        content {
          cold_storage_after = lifecycle.value.cold_storage_after
          delete_after       = lifecycle.value.delete_after
        }
      }

      dynamic "copy_action" {
        for_each = rule.value.copy_actions
        content {
          destination_vault_arn = copy_action.value.destination_vault_arn

          dynamic "lifecycle" {
            for_each = copy_action.value.lifecycle != null ? [copy_action.value.lifecycle] : []
            content {
              cold_storage_after = lifecycle.value.cold_storage_after
              delete_after       = lifecycle.value.delete_after
            }
          }
        }
      }
    }
  }

  dynamic "advanced_backup_setting" {
    for_each = var.advanced_backup_settings
    content {
      backup_options = advanced_backup_setting.value.backup_options
      resource_type  = advanced_backup_setting.value.resource_type
    }
  }
}

# Support for custom rules (backward compatibility)
resource "aws_backup_plan" "custom" {
  count = length(var.rules) > 0 ? 1 : 0

  name = "${local.plan_name_base}-custom"
  tags = merge(
    var.tags,
    { Type = "custom-backup-plan" },
    var.plan_prefix != "" ? { (var.plan_prefix) = "true" } : {}
  )

  dynamic "rule" {
    for_each = var.rules
    content {
      rule_name                = rule.value.rule_name
      target_vault_name        = rule.value.target_vault_name
      schedule                 = rule.value.schedule
      enable_continuous_backup = lookup(rule.value, "enable_continuous_backup", false)
      start_window             = lookup(rule.value, "start_window", 60)
      completion_window        = lookup(rule.value, "completion_window", 1440)

      dynamic "lifecycle" {
        for_each = lookup(rule.value, "lifecycle", null) != null ? [rule.value.lifecycle] : []
        content {
          cold_storage_after = lookup(lifecycle.value, "cold_storage_after", null)
          delete_after       = lookup(lifecycle.value, "delete_after", null)
        }
      }

      dynamic "copy_action" {
        for_each = lookup(rule.value, "copy_actions", [])
        content {
          destination_vault_arn = copy_action.value.destination_vault_arn

          dynamic "lifecycle" {
            for_each = lookup(copy_action.value, "lifecycle", null) != null ? [copy_action.value.lifecycle] : []
            content {
              cold_storage_after = lookup(lifecycle.value, "cold_storage_after", null)
              delete_after       = lookup(lifecycle.value, "delete_after", null)
            }
          }
        }
      }
    }
  }

  dynamic "advanced_backup_setting" {
    for_each = var.advanced_backup_settings
    content {
      backup_options = advanced_backup_setting.value.backup_options
      resource_type  = advanced_backup_setting.value.resource_type
    }
  }
}


# Backup Selection Resources
# IAM role for backup selection
resource "aws_iam_role" "backup_selection" {
  count = var.create_backup_selection ? 1 : 0

  name = "${local.plan_name_base}-backup-selection-role"
  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = "sts:AssumeRole"
        Effect = "Allow"
        Principal = {
          Service = "backup.amazonaws.com"
        }
      }
    ]
  })

  tags = merge(
    var.tags,
    {
      Name = "${local.plan_name_base}-backup-selection-role"
      Type = "backup-selection"
    }
  )
}

resource "aws_iam_role_policy_attachment" "backup_selection" {
  count = var.create_backup_selection ? 1 : 0

  policy_arn = "arn:aws:iam::aws:policy/service-role/AWSBackupServiceRolePolicyForBackup"
  role       = aws_iam_role.backup_selection[0].name
}

resource "aws_iam_role_policy_attachment" "backup_selection_s3" {
  count = var.create_backup_selection && var.enable_s3_backup ? 1 : 0

  policy_arn = "arn:aws:iam::aws:policy/AWSBackupServiceRolePolicyForS3Backup"
  role       = aws_iam_role.backup_selection[0].name
}

resource "aws_iam_role_policy_attachment" "backup_selection_restores" {
  count = var.create_backup_selection ? 1 : 0

  policy_arn = "arn:aws:iam::aws:policy/service-role/AWSBackupServiceRolePolicyForRestores"
  role       = aws_iam_role.backup_selection[0].name
}

# Additional policy for resource discovery
resource "aws_iam_role_policy" "backup_selection_resource_access" {
  count = var.create_backup_selection ? 1 : 0
  name  = "${local.plan_name_base}-resource-access"
  role  = aws_iam_role.backup_selection[0].id

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Sid    = "BackupResourceDiscovery"
        Effect = "Allow"
        Action = [
          # Tag permissions for resource discovery
          "tag:GetResources",
          "tag:GetTagKeys",
          "tag:GetTagValues",

          # EC2 permissions
          "ec2:DescribeInstances",
          "ec2:DescribeVolumes",
          "ec2:DescribeSnapshots",
          "ec2:DescribeTags",

          # RDS permissions
          "rds:DescribeDBInstances",
          "rds:DescribeDBClusters",
          "rds:ListTagsForResource",

          # EFS permissions
          "elasticfilesystem:DescribeFileSystems",

          # DynamoDB permissions
          "dynamodb:ListTables",
          "dynamodb:DescribeTable",
          "dynamodb:ListTagsOfResource",

          # S3 permissions
          "s3:ListAllMyBuckets",
          "s3:GetBucketTagging",

          # Backup permissions
          "backup:ListBackupVaults",
          "backup:DescribeBackupVault"
        ]
        Resource = "*"
      }
    ]
  })
}

# Backup selections for individual plans
resource "aws_backup_selection" "individual" {
  for_each = var.create_backup_selection && var.use_individual_plans ? local.enabled_plans : {}

  iam_role_arn = aws_iam_role.backup_selection[0].arn
  name         = "${local.plan_name_base}-${each.key}-selection"
  plan_id      = aws_backup_plan.individual[each.key].id

  # Primary server selection tag (if specified)
  dynamic "selection_tag" {
    for_each = var.server_selection_tag != null ? [1] : []
    content {
      type  = "STRINGEQUALS"
      key   = var.server_selection_tag
      value = var.server_selection_value
    }
  }

  # Additional selection tags
  dynamic "selection_tag" {
    for_each = var.backup_selection_tags
    content {
      type  = selection_tag.value.type
      key   = selection_tag.value.key
      value = selection_tag.value.value
    }
  }

  # Per-schedule tags using smart defaults (only if server_selection_tag not set)
  dynamic "selection_tag" {
    for_each = var.server_selection_tag == null ? [1] : []
    content {
      type = "STRINGEQUALS"
      key  = local.selection_tag_keys[each.key]
      value = (
        each.key == "hourly" ? var.hourly_selection_tag_value :
        each.key == "daily" ? var.daily_selection_tag_value :
        each.key == "weekly" ? var.weekly_selection_tag_value :
        each.key == "monthly" ? var.monthly_selection_tag_value :
        each.key == "yearly" ? var.yearly_selection_tag_value : "true"
      )
    }
  }

  # Additional resource ARNs
  resources = var.backup_selection_resources

  # Conditions
  dynamic "condition" {
    for_each = var.backup_selection_conditions
    content {
      dynamic "string_equals" {
        for_each = lookup(condition.value, "string_equals", [])
        content {
          key   = string_equals.value.key
          value = string_equals.value.value
        }
      }

      dynamic "string_not_equals" {
        for_each = lookup(condition.value, "string_not_equals", [])
        content {
          key   = string_not_equals.value.key
          value = string_not_equals.value.value
        }
      }

      dynamic "string_like" {
        for_each = lookup(condition.value, "string_like", [])
        content {
          key   = string_like.value.key
          value = string_like.value.value
        }
      }

      dynamic "string_not_like" {
        for_each = lookup(condition.value, "string_not_like", [])
        content {
          key   = string_not_like.value.key
          value = string_not_like.value.value
        }
      }
    }
  }

  # Not supported resources
  not_resources = var.backup_selection_not_resources
}

# Backup selection for combined plan
resource "aws_backup_selection" "combined" {
  count = var.create_backup_selection && !var.use_individual_plans && length(local.enabled_plans) > 0 ? 1 : 0

  iam_role_arn = aws_iam_role.backup_selection[0].arn
  name         = "${local.plan_name_base}-selection"
  plan_id      = aws_backup_plan.combined[0].id

  # Primary server selection tag (if specified)
  dynamic "selection_tag" {
    for_each = var.server_selection_tag != null ? [1] : []
    content {
      type  = "STRINGEQUALS"
      key   = var.server_selection_tag
      value = var.server_selection_value
    }
  }

  # Additional selection tags
  dynamic "selection_tag" {
    for_each = var.backup_selection_tags
    content {
      type  = selection_tag.value.type
      key   = selection_tag.value.key
      value = selection_tag.value.value
    }
  }

  # Additional resource ARNs
  resources = var.backup_selection_resources

  # Conditions
  dynamic "condition" {
    for_each = var.backup_selection_conditions
    content {
      dynamic "string_equals" {
        for_each = lookup(condition.value, "string_equals", [])
        content {
          key   = string_equals.value.key
          value = string_equals.value.value
        }
      }

      dynamic "string_not_equals" {
        for_each = lookup(condition.value, "string_not_equals", [])
        content {
          key   = string_not_equals.value.key
          value = string_not_equals.value.value
        }
      }

      dynamic "string_like" {
        for_each = lookup(condition.value, "string_like", [])
        content {
          key   = string_like.value.key
          value = string_like.value.value
        }
      }

      dynamic "string_not_like" {
        for_each = lookup(condition.value, "string_not_like", [])
        content {
          key   = string_not_like.value.key
          value = string_not_like.value.value
        }
      }
    }
  }

  # Not supported resources
  not_resources = var.backup_selection_not_resources
}

# Backup selection for custom plan
resource "aws_backup_selection" "custom" {
  count = var.create_backup_selection && length(var.rules) > 0 ? 1 : 0

  iam_role_arn = aws_iam_role.backup_selection[0].arn
  name         = "${local.plan_name_base}-custom-selection"
  plan_id      = aws_backup_plan.custom[0].id

  # Primary server selection tag (if specified)
  dynamic "selection_tag" {
    for_each = var.server_selection_tag != null ? [1] : []
    content {
      type  = "STRINGEQUALS"
      key   = var.server_selection_tag
      value = var.server_selection_value
    }
  }

  # Additional selection tags
  dynamic "selection_tag" {
    for_each = var.backup_selection_tags
    content {
      type  = selection_tag.value.type
      key   = selection_tag.value.key
      value = selection_tag.value.value
    }
  }

  # Additional resource ARNs
  resources = var.backup_selection_resources

  # Conditions
  dynamic "condition" {
    for_each = var.backup_selection_conditions
    content {
      dynamic "string_equals" {
        for_each = lookup(condition.value, "string_equals", [])
        content {
          key   = string_equals.value.key
          value = string_equals.value.value
        }
      }

      dynamic "string_not_equals" {
        for_each = lookup(condition.value, "string_not_equals", [])
        content {
          key   = string_not_equals.value.key
          value = string_not_equals.value.value
        }
      }

      dynamic "string_like" {
        for_each = lookup(condition.value, "string_like", [])
        content {
          key   = string_like.value.key
          value = string_like.value.value
        }
      }

      dynamic "string_not_like" {
        for_each = lookup(condition.value, "string_not_like", [])
        content {
          key   = string_not_like.value.key
          value = string_not_like.value.value
        }
      }
    }
  }

  # Not supported resources
  not_resources = var.backup_selection_not_resources
}
