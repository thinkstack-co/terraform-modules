terraform {
  required_version = ">= 1.0.0"
  required_providers {
    aws = {
      source                = "hashicorp/aws"
      version               = ">= 4.0.0"
      configuration_aliases = [aws.aws_prod_region, aws.aws_dr_region]
    }
  }
}

###############################################################
# KMS Encryption Key
###############################################################

# Production region key
resource "aws_kms_key" "key" {
  provider                           = aws.aws_prod_region
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
  provider      = aws.aws_prod_region
  name          = var.key_name
  target_key_id = aws_kms_key.key.key_id
}

# Disaster recovery region key
resource "aws_kms_key" "dr_key" {
  provider                           = aws.aws_dr_region
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

resource "aws_kms_alias" "dr_alias" {
  provider      = aws.aws_dr_region
  name          = var.key_name
  target_key_id = aws_kms_key.dr_key.key_id
}

###############################################################
# IAM
###############################################################
# Assume Role
resource "aws_iam_role" "backup" {
  provider           = aws.aws_prod_region
  name               = "aws_backup_role"
  assume_role_policy = <<POLICY
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Action": ["sts:AssumeRole"],
      "Effect": "allow",
      "Principal": {
        "Service": ["backup.amazonaws.com"]
      }
    }
  ]
}
POLICY
}

# Policy Attachment
resource "aws_iam_role_policy_attachment" "backup" {
  provider   = aws.aws_prod_region
  policy_arn = "arn:aws:iam::aws:policy/service-role/AWSBackupServiceRolePolicyForBackup"
  role       = aws_iam_role.backup.name
}

resource "aws_iam_role_policy_attachment" "restores" {
  provider   = aws.aws_prod_region
  policy_arn = "arn:aws:iam::aws:policy/service-role/AWSBackupServiceRolePolicyForRestores"
  role       = aws_iam_role.backup.name
}

###############################################################
# Backup Vaults
###############################################################

### Hourly
resource "aws_backup_vault" "vault_prod_hourly" {
  provider    = aws.aws_prod_region
  name        = var.vault_prod_hourly_name
  kms_key_arn = aws_kms_key.key.arn
  tags        = var.tags
}

### Daily
resource "aws_backup_vault" "vault_prod_daily" {
  provider    = aws.aws_prod_region
  name        = var.vault_prod_daily_name
  kms_key_arn = aws_kms_key.key.arn
  tags        = var.tags
}

### Monthly
resource "aws_backup_vault" "vault_prod_monthly" {
  provider    = aws.aws_prod_region
  name        = var.vault_prod_monthly_name
  kms_key_arn = aws_kms_key.key.arn
  tags        = var.tags
}

### Disaster Recovery
resource "aws_backup_vault" "vault_disaster_recovery" {
  provider    = aws.aws_dr_region
  name        = var.vault_disaster_recovery_name
  kms_key_arn = aws_kms_key.dr_key.arn
  tags        = var.tags
}

###############################################################
# Backup Vault Policy
###############################################################

resource "aws_backup_vault_policy" "vault_prod_hourly" {
  provider          = aws.aws_prod_region
  backup_vault_name = aws_backup_vault.vault_prod_hourly.name
  policy            = <<POLICY
{
  "Version": "2012-10-17",
  "Id": "default",
  "Statement": [
    {
      "Sid": "deny_all_delete",
      "Effect": "Deny",
      "Principal": {
        "AWS": "*"
      },
      "Action": [
        "backup:DeleteBackupVault",
        "backup:DeleteRecoveryPoint",
        "backup:UpdateRecoveryPointLifecycle"
      ],
      "Resource": "${aws_backup_vault.vault_prod_hourly.arn}"
    }
  ]
}
POLICY
}

resource "aws_backup_vault_policy" "vault_prod_daily" {
  provider          = aws.aws_prod_region
  backup_vault_name = aws_backup_vault.vault_prod_daily.name
  policy            = <<POLICY
{
  "Version": "2012-10-17",
  "Id": "default",
  "Statement": [
    {
      "Sid": "deny_all_delete",
      "Effect": "Deny",
      "Principal": {
        "AWS": "*"
      },
      "Action": [
        "backup:DeleteBackupVault",
        "backup:DeleteRecoveryPoint",
        "backup:UpdateRecoveryPointLifecycle"
      ],
      "Resource": "${aws_backup_vault.vault_prod_daily.arn}"
    }
  ]
}
POLICY
}

resource "aws_backup_vault_policy" "vault_prod_monthly" {
  provider          = aws.aws_prod_region
  backup_vault_name = aws_backup_vault.vault_prod_monthly.name
  policy            = <<POLICY
{
  "Version": "2012-10-17",
  "Id": "default",
  "Statement": [
    {
      "Sid": "deny_all_delete",
      "Effect": "Deny",
      "Principal": {
        "AWS": "*"
      },
      "Action": [
        "backup:DeleteBackupVault",
        "backup:DeleteRecoveryPoint",
        "backup:UpdateRecoveryPointLifecycle"
      ],
      "Resource": "${aws_backup_vault.vault_prod_monthly.arn}"
    }
  ]
}
POLICY
}

resource "aws_backup_vault_policy" "vault_disaster_recovery" {
  provider          = aws.aws_dr_region
  backup_vault_name = aws_backup_vault.vault_disaster_recovery.name
  policy            = <<POLICY
{
  "Version": "2012-10-17",
  "Id": "default",
  "Statement": [
    {
      "Sid": "deny_all_delete",
      "Effect": "Deny",
      "Principal": {
        "AWS": "*"
      },
      "Action": [
        "backup:DeleteBackupVault",
        "backup:DeleteRecoveryPoint",
        "backup:UpdateRecoveryPointLifecycle"
      ],
      "Resource": "${aws_backup_vault.vault_disaster_recovery.arn}"
    }
  ]
}
POLICY
}

###############################################################
# Backup Vault Lock
###############################################################

resource "aws_backup_vault_lock_configuration" "vault_prod_hourly" {
  provider            = aws.aws_prod_region
  backup_vault_name   = aws_backup_vault.vault_prod_hourly.name
  changeable_for_days = 3
}

resource "aws_backup_vault_lock_configuration" "vault_prod_daily" {
  provider            = aws.aws_prod_region
  backup_vault_name   = aws_backup_vault.vault_prod_daily.name
  changeable_for_days = 3
}

resource "aws_backup_vault_lock_configuration" "vault_prod_monthly" {
  provider            = aws.aws_prod_region
  backup_vault_name   = aws_backup_vault.vault_prod_monthly.name
  changeable_for_days = 3
}

resource "aws_backup_vault_lock_configuration" "vault_disaster_recovery" {
  provider            = aws.aws_dr_region
  backup_vault_name   = aws_backup_vault.vault_disaster_recovery.name
  changeable_for_days = 3
}

###############################################################
# Backup Plans
###############################################################

#######################################
# Primary Backup
#######################################
# The following plan and selection are for all services except EC2 instances or AMI backups
resource "aws_backup_plan" "plan" {
  provider = aws.aws_prod_region
  name     = var.backup_plan_name
  tags     = var.tags

  rule {
    rule_name                = "hourly_backup_rule"
    target_vault_name        = aws_backup_vault.vault_prod_hourly.name
    schedule                 = "cron(20 * * * ? *)"
    enable_continuous_backup = false
    start_window             = var.backup_plan_start_window
    completion_window        = var.backup_plan_completion_window
    lifecycle {
      delete_after = var.hourly_backup_retention
    }
  }

  rule {
    rule_name                = "daily_backup_rule"
    target_vault_name        = aws_backup_vault.vault_prod_daily.name
    schedule                 = "cron(20 7 * * ? *)"
    enable_continuous_backup = false
    start_window             = var.backup_plan_start_window
    completion_window        = var.backup_plan_completion_window
    copy_action {
      destination_vault_arn = aws_backup_vault.vault_disaster_recovery.arn
      lifecycle {
        delete_after = var.dr_backup_retention
      }
    }
    lifecycle {
      delete_after = var.daily_backup_retention
    }
  }

  rule {
    rule_name                = "monthly_backup_rule"
    target_vault_name        = aws_backup_vault.vault_prod_monthly.name
    schedule                 = "cron(20 7 1 * ? *)"
    enable_continuous_backup = false
    start_window             = var.backup_plan_start_window
    completion_window        = var.backup_plan_completion_window
    lifecycle {
      # cold_storage_after = "90"
      delete_after = var.monthly_backup_retention
    }
  }

  advanced_backup_setting {
    backup_options = {
      WindowsVSS = "enabled"
    }
    resource_type = "EC2"
  }
}

#######################################
# Backup Selection
#######################################

resource "aws_backup_selection" "all_resources" {
  provider     = aws.aws_prod_region
  iam_role_arn = aws_iam_role.backup.arn
  name         = "all_except_ec2_and_s3"
  plan_id      = aws_backup_plan.plan.id
  resources = [
    "*"
  ]
  not_resources = [
    "arn:aws:ec2:*:*:instance/*",
    "arn:aws:s3:*"
  ]
}

#######################################
# EC2 AMI Backup
#######################################
# The following plan and selection are for EC2 AMI
resource "aws_backup_plan" "ec2_plan" {
  provider = aws.aws_prod_region
  name     = var.ec2_backup_plan_name
  tags     = var.tags

  rule {
    rule_name                = "daily_backup_rule"
    target_vault_name        = aws_backup_vault.vault_prod_daily.name
    schedule                 = "cron(20 9 * * ? *)"
    enable_continuous_backup = false
    start_window             = var.backup_plan_start_window
    completion_window        = var.backup_plan_completion_window
    copy_action {
      destination_vault_arn = aws_backup_vault.vault_disaster_recovery.arn
      lifecycle {
        delete_after = var.dr_backup_retention
      }
    }
    lifecycle {
      delete_after = var.daily_backup_retention
    }
  }

  advanced_backup_setting {
    backup_options = {
      WindowsVSS = "enabled"
    }
    resource_type = "EC2"
  }
}

#######################################
# Backup Selection
#######################################

resource "aws_backup_selection" "all_ec2" {
  provider     = aws.aws_prod_region
  iam_role_arn = aws_iam_role.backup.arn
  name         = "all_ec2"
  plan_id      = aws_backup_plan.ec2_plan.id
  resources = [
    "arn:aws:ec2:*:*:instance/*"
  ]
}

###############################################################
# Backup Notifications
###############################################################
# To be added
