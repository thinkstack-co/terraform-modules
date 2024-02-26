terraform {
  required_version = ">= 1.0.0"
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = ">= 4.0.0"
    }
  }
}

provider "aws" {
  region = var.backup_region
}

#################
# IAM Role
#################

resource "aws_iam_role" "backup_role" {
  name = "AWSBackupDefaultServiceRole"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = "sts:AssumeRole"
        Effect = "Allow"
        Principal = {
          Service = "backup.amazonaws.com"
        }
      },
    ]
  })

  tags = {
    Purpose = "AWS Backup"
  }
}

resource "aws_iam_role_policy_attachment" "backup_role_policy" {
  role       = aws_iam_role.backup_role.name
  policy_arn = "arn:aws:iam::aws:policy/service-role/AWSBackupServiceRolePolicyForBackup"
}

#####################
# KMS
#####################

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

##################
# Backups
##################

resource "aws_backup_vault" "this" {
  name        = var.backup_vault_name
  kms_key_arn = aws.aws_kms_key.key.arn
  tags        = var.tags
}

resource "aws_backup_plan" "this" {
  name = var.backup_plan_name

  rule {
    rule_name         = var.backup_rule_name
    target_vault_name = aws_backup_vault.this.name
    schedule          = var.schedule
    lifecycle {
      cold_storage_after = var.cold_storage_after_days # days after creation when a recovery point is moved to cold storage
      delete_after       = var.delete_after_days       # days after creation when a recovery point is deleted
    }
  }
}

resource "aws_backup_selection" "this" {
  iam_role_arn = aws_iam_role.backup_role.arn
  name         = "${var.backup_plan_name}-selection"
  plan_id      = aws_backup_plan.this.id

  resources = var.instance_ids
}

resource "aws_backup_vault_lock_configuration" "this" {
  backup_vault_name   = aws_backup_vault.this.name
  changeable_for_days = 3
}

