terraform {
  required_version = ">= 0.12.0"
}

###############################################################
# KMS Encryption Key
###############################################################

resource "aws_kms_key" "key" {
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

resource "aws_kms_alias" "alias" {
  name          = var.key_name
  target_key_id = aws_kms_key.key.key_id
}

###############################################################
# Backup Vaults
###############################################################

### Hourly
resource "aws_backup_vault" "vault_prod_hourly" {
  name        = var.vault_prod_hourly_name
  kms_key_arn = var.kms_key_arn
  tags        = var.tags
}

resource "aws_backup_vault" "vault_dr_hourly" {
  name        = var.vault_dr_hourly_name
  kms_key_arn = var.kms_key_arn
  tags        = var.tags
}

### Daily
resource "aws_backup_vault" "vault_prod_daily" {
  name        = var.vault_prod_daily_name
  kms_key_arn = var.kms_key_arn
  tags        = var.tags
}

### Monthly
resource "aws_backup_vault" "vault_prod_monthly" {
  name        = var.vault_prod_monthly_name
  kms_key_arn = var.kms_key_arn
  tags        = var.tags
}

###############################################################
# Backup Vault Policy
###############################################################
# To be added

###############################################################
# Backup Plans
###############################################################

resource "aws_backup_plan" "plan" {
  name = var.backup_plan_name
  tags = var.tags

  rule {
    rule_name                = "hourly_backup_rule"
    target_vault_name        = aws_backup_vault.vault_prod_hourly.name
    schedule                 = "cron(20 * * * ? *)"
    enable_continuous_backup = false
    start_window             = ""
    completion_window        = ""
    copy_action {
      lifecycle             = 3
      destination_vault_arn = aws_backup_vault.vault_dr_hourly.arn
    }
    lifecycle {
      cold_storage_after = ""
      delete_after       = var.hourly_backup_retention
    }
  }

  rule {
    rule_name         = "daily_backup_rule"
    target_vault_name = aws_backup_vault.vault_prod_daily.name
    schedule                 = "cron(20 7 * * ? *)"
    enable_continuous_backup = false
    start_window             = ""
    completion_window        = ""
    lifecycle {
      cold_storage_after = ""
      delete_after       = var.daily_backup_retention
    }
  }

  rule {
    rule_name         = "monthly_backup_rule"
    target_vault_name = aws_backup_vault.vault_prod_monthly.name
    schedule                 = "cron(20 7 1 * ? *)"
    enable_continuous_backup = false
    start_window             = ""
    completion_window        = ""
    lifecycle {
      cold_storage_after = ""
      delete_after       = var.monthly_backup_retention
    }
  }

  advanced_backup_setting {
    backup_options = {
      WindowsVSS = "enabled"
    }
    resource_type = "EC2"
  }
}

###############################################################
# Backup Selection
###############################################################

###############################################################
# Backup Notifications
###############################################################
# To be added