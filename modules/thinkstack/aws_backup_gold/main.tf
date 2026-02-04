terraform {
  required_version = ">= 1.0.0"
  required_providers {
    aws = {
      # AWS provider for backup resources
      source  = "hashicorp/aws"
      version = ">= 4.0.0"
    }
  }
}

# NOTE: This is an experimental module used to design a "Gold" backup plan
# that combines multiple schedules (hourly, daily, monthly) into a single
# AWS Backup plan, similar to the original thinkstack/aws_backup module.
#
# We will incrementally add resources here as the design is validated.

resource "aws_backup_plan" "gold" {
  # Single AWS Backup plan that contains all schedules for this tag-defined group
  name = var.plan_name
  tags = var.tags

  # Hourly backups for high-frequency protection (optional)
  dynamic "rule" {
    for_each = var.enable_hourly_rule ? [1] : []
    content {
      rule_name         = "hourly-backup"
      target_vault_name = var.primary_vault_name
      schedule          = var.hourly_schedule
      start_window      = var.start_window
      completion_window = var.completion_window

      lifecycle {
        # Retention for hourly backups in the primary vault
        delete_after = var.hourly_retention_days
      }

      dynamic "copy_action" {
        # Optional copy of hourly backups to a DR vault with its own retention
        for_each = var.hourly_copy_to_dr && var.dr_vault_arn != "" ? [1] : []
        content {
          destination_vault_arn = var.dr_vault_arn

          lifecycle {
            # Retention for hourly backups in the DR vault
            delete_after = var.hourly_dr_retention_days
          }
        }
      }
    }
  }

  # Daily backups for standard protection (optional)
  dynamic "rule" {
    for_each = var.enable_daily_rule ? [1] : []
    content {
      rule_name         = "daily-backup"
      target_vault_name = var.primary_vault_name
      schedule          = var.daily_schedule
      start_window      = var.start_window
      completion_window = var.completion_window

      lifecycle {
        # Retention for daily backups in the primary vault
        delete_after = var.daily_retention_days
      }

      dynamic "copy_action" {
        # Optional copy of daily backups to a DR vault with its own retention
        for_each = var.daily_copy_to_dr && var.dr_vault_arn != "" ? [1] : []
        content {
          destination_vault_arn = var.dr_vault_arn

          lifecycle {
            # Retention for daily backups in the DR vault
            delete_after = var.daily_dr_retention_days
          }
        }
      }
    }
  }

  # Weekly backups for intermediate retention (optional)
  dynamic "rule" {
    for_each = var.enable_weekly_rule ? [1] : []
    content {
      rule_name         = "weekly-backup"
      target_vault_name = var.primary_vault_name
      schedule          = var.weekly_schedule
      start_window      = var.start_window
      completion_window = var.completion_window

      lifecycle {
        # Retention for weekly backups in the primary vault
        delete_after = var.weekly_retention_days
      }

      dynamic "copy_action" {
        # Optional copy of weekly backups to a DR vault with its own retention
        for_each = var.weekly_copy_to_dr && var.dr_vault_arn != "" ? [1] : []
        content {
          destination_vault_arn = var.dr_vault_arn

          lifecycle {
            # Retention for weekly backups in the DR vault
            delete_after = var.weekly_dr_retention_days
          }
        }
      }
    }
  }

  # Monthly backups for long-term retention (optional)
  dynamic "rule" {
    for_each = var.enable_monthly_rule ? [1] : []
    content {
      rule_name         = "monthly-backup"
      target_vault_name = var.primary_vault_name
      schedule          = var.monthly_schedule
      start_window      = var.start_window
      completion_window = var.completion_window

      lifecycle {
        # Retention for monthly backups in the primary vault
        delete_after = var.monthly_retention_days
      }

      dynamic "copy_action" {
        # Optional copy of monthly backups to a DR vault with its own retention
        for_each = var.monthly_copy_to_dr && var.dr_vault_arn != "" ? [1] : []
        content {
          destination_vault_arn = var.dr_vault_arn

          lifecycle {
            # Retention for monthly backups in the DR vault
            delete_after = var.monthly_dr_retention_days
          }
        }
      }
    }
  }

  # Yearly backups for archive retention (optional)
  dynamic "rule" {
    for_each = var.enable_yearly_rule ? [1] : []
    content {
      rule_name         = "yearly-backup"
      target_vault_name = var.primary_vault_name
      schedule          = var.yearly_schedule
      start_window      = var.start_window
      completion_window = var.completion_window

      lifecycle {
        # Retention for yearly backups in the primary vault
        delete_after = var.yearly_retention_days
      }

      dynamic "copy_action" {
        # Optional copy of yearly backups to a DR vault with its own retention
        for_each = var.yearly_copy_to_dr && var.dr_vault_arn != "" ? [1] : []
        content {
          destination_vault_arn = var.dr_vault_arn

          lifecycle {
            # Retention for yearly backups in the DR vault
            delete_after = var.yearly_dr_retention_days
          }
        }
      }
    }
  }
}

resource "aws_backup_selection" "gold_tag_selection" {
  # Tag-based selection that sends matching resources to the Gold plan
  name         = "${var.plan_name}-tag-selection"
  iam_role_arn = var.backup_role_arn
  plan_id      = aws_backup_plan.gold.id

  selection_tag {
    # Custom tag that defines which resources belong to this plan
    type  = "STRINGEQUALS"
    key   = var.selection_tag_key
    value = var.selection_tag_value
  }
}
