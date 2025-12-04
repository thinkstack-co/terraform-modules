# AWS Backup Vault Module for Gold Backup Plan
# Creates backup vaults in primary and optionally DR regions

terraform {
  required_version = ">= 1.0.0"
  required_providers {
    aws = {
      source                = "hashicorp/aws"
      version               = ">= 4.0.0"
      configuration_aliases = [aws.dr]
    }
  }
}

###################################################
# KMS Keys
###################################################

# KMS Key for primary region vault encryption
resource "aws_kms_key" "backup" {
  count                   = var.create_kms_key ? 1 : 0
  description             = var.kms_key_description
  deletion_window_in_days = var.kms_key_deletion_window
  enable_key_rotation     = var.kms_key_enable_rotation

  tags = merge(
    var.tags,
    {
      Name = "${var.vault_name}-backup-key"
      Type = "backup-encryption"
    }
  )
}

# KMS Key alias for primary region
resource "aws_kms_alias" "backup" {
  count         = var.create_kms_key ? 1 : 0
  name          = "alias/${var.vault_name}-backup"
  target_key_id = aws_kms_key.backup[0].key_id
}

# KMS Key for DR region vault encryption
resource "aws_kms_key" "dr_backup" {
  count                   = var.enable_dr && var.create_dr_kms_key ? 1 : 0
  provider                = aws.dr
  description             = var.dr_kms_key_description
  deletion_window_in_days = var.kms_key_deletion_window
  enable_key_rotation     = var.kms_key_enable_rotation

  tags = merge(
    var.tags,
    var.dr_tags,
    {
      Name = "${var.dr_vault_name}-backup-key"
      Type = "dr-backup-encryption"
    }
  )
}

# KMS Key alias for DR region
resource "aws_kms_alias" "dr_backup" {
  count         = var.enable_dr && var.create_dr_kms_key ? 1 : 0
  provider      = aws.dr
  name          = "alias/${var.dr_vault_name}-backup"
  target_key_id = aws_kms_key.dr_backup[0].key_id
}

###################################################
# Locals
###################################################

locals {
  # Determine which KMS key ARN to use (null means use AWS-managed key)
  kms_key_arn    = var.create_kms_key ? aws_kms_key.backup[0].arn : var.kms_key_arn
  dr_kms_key_arn = var.enable_dr ? (var.create_dr_kms_key ? aws_kms_key.dr_backup[0].arn : var.dr_kms_key_arn) : null
}

###################################################
# Primary Vault
###################################################

# Primary backup vault
resource "aws_backup_vault" "primary" {
  name          = var.vault_name
  kms_key_arn   = local.kms_key_arn
  force_destroy = var.force_destroy

  tags = merge(
    var.tags,
    {
      Name = var.vault_name
      Type = "primary"
    }
  )
}

# Vault lock configuration for primary vault
resource "aws_backup_vault_lock_configuration" "primary" {
  count             = var.enable_vault_lock ? 1 : 0
  backup_vault_name = aws_backup_vault.primary.name

  changeable_for_days = var.vault_lock_changeable_for_days
  max_retention_days  = var.vault_lock_max_retention_days
  min_retention_days  = var.vault_lock_min_retention_days
}

###################################################
# DR Vault
###################################################

# DR backup vault (in separate region)
resource "aws_backup_vault" "dr" {
  count    = var.enable_dr ? 1 : 0
  provider = aws.dr

  name          = var.dr_vault_name
  kms_key_arn   = local.dr_kms_key_arn
  force_destroy = var.force_destroy

  tags = merge(
    var.tags,
    var.dr_tags,
    {
      Name = var.dr_vault_name
      Type = "DR"
    }
  )
}

# Vault lock configuration for DR vault
resource "aws_backup_vault_lock_configuration" "dr" {
  count    = var.enable_dr && var.enable_vault_lock ? 1 : 0
  provider = aws.dr

  backup_vault_name = aws_backup_vault.dr[0].name

  changeable_for_days = var.vault_lock_changeable_for_days
  max_retention_days  = var.vault_lock_max_retention_days
  min_retention_days  = var.vault_lock_min_retention_days
}
